import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:rxdart/rxdart.dart';

import '../kai_engine.dart';

/// Base orchestrator for chat interactions
/// override to add more configuration
/// [TEntity] is the type of the message object which can use to translate to the backend
abstract base class ChatControllerBase<TEntity> {
  final QueryEngineBase? _queryEngine;
  final ConversationManager<TEntity> _conversationManager;
  final GenerationServiceBase _generationService;
  final PostResponseEngineBase? _postResponseEngine;
  final CancelToken _cancelToken;

  ChatControllerBase({
    required GenerationServiceBase generationService,
    required ConversationManager<TEntity> conversationManager,
    QueryEngineBase? queryEngine,
    PostResponseEngineBase? postResponseEngine,
  }) : _queryEngine = queryEngine,
       _conversationManager = conversationManager,
       _generationService = generationService,
       _postResponseEngine = postResponseEngine,
       _cancelToken = CancelToken();

  /// Handle generation state updates
  final _generationStateController = BehaviorSubject<GenerationState<GenerationResult>>.seeded(
    GenerationState.initial(),
  );

  ContextEngine build();

  /// Provide custom generative config in addition to default configuration of generative service base on the prompt which will send to server
  GenerationExecuteConfig generativeConfigs(IList<CoreMessage> prompts) =>
      GenerationExecuteConfig.none();

  /// Submit user input for processing and generation
  /// [revertInputOnError] indicates whether to revert user input if error occurs, by default it is false
  /// which means the user input will be retained even if an error occurs
  Future<GenerationState<GenerationResult>> submit(
    String input, {
    bool revertInputOnError = false,
  }) async {
    var userMessage = CoreMessage.user(content: input);

    try {
      // Reset cancel token for new generation
      _cancelToken.reset();

      _setState(GenerationState.loading());

      // Variable to store the final generation result
      late GenerationResult generationResult;

      final insertedUserMessageFuture = _conversationManager
          .addMessages([userMessage].lock)
          .then((inserted) => inserted.first);

      unawaited(
        insertedUserMessageFuture.then((inserted) {
          userMessage = inserted;
        }),
      );

      // Phase 1: Query Processing
      _setLoadingPhase(LoadingPhase.processingQuery());
      final queryInput = QueryEngineInput(
        rawInput: input,
        session: _conversationManager.session,
        // Exclude the current user message from history, by natural flow user message is happening after query input
        // but to trickly show message in UI faster, we trickly hide this
        histories: await _conversationManager.getMessages().then(
          (messages) => messages.whereNot((m) => m.messageId == userMessage.messageId).toIList(),
        ),
      );

      QueryContext queryContext;
      if (_queryEngine == null) {
        queryContext = QueryContext(
          session: _conversationManager.session,
          originalQuery: input,
          processedQuery: input.trim(),
        );
      } else {
        queryContext = await _queryEngine.execute(queryInput);
      }

      // Phase 2: Context Building
      _setLoadingPhase(LoadingPhase.buildContext());
      final contextInput = ContextEngineInput(
        inputQuery: queryContext,
        conversationMessages: await _conversationManager.getMessages(),
        providedUserMessage: userMessage,
      );
      final contextResult = await build().execute(contextInput);

      // Persist any input revision (PromptTemplate.input(revision: ...)) back into the stored user message.
      final insertedUserMessage = await insertedUserMessageFuture;
      userMessage = insertedUserMessage;
      if (contextResult.userMessage.content != insertedUserMessage.content) {
        final revised = insertedUserMessage.copyWith(content: contextResult.userMessage.content);
        await _conversationManager.updateMessages(IList([revised]));
        userMessage = revised;
      }

      // Phase 3: AI Generation
      final configs = generativeConfigs(contextResult.prompts);
      _setLoadingPhase(LoadingPhase.generatingResponse());
      onPromptsReady(contextResult.prompts);

      final aiGenerationInput = AIGenerationInput(
        prompts: contextResult.prompts,
        cancelToken: _cancelToken,
        tools: configs.tools,
        config: configs.config,
        onStateUpdate: (state) => _generationStateController.add(state),
      );

      generationResult = await AIGenerationPhase(_generationService).execute(aiGenerationInput);

      // Save the AI-generated messages to the conversation
      if (generationResult.generatedMessages.isNotEmpty) {
        final addedMessages = await _conversationManager
            .addMessages(generationResult.generatedMessages)
            .then((items) {
              // Prevent from mistake in conversation manager which might lead to duplicate message being added
              final originalIds = generationResult.generatedMessages
                  .map((e) => e.messageId)
                  .toSet();
              return items.where((e) => originalIds.contains(e.messageId)).toIList();
            });

        // Make sure generated message is updated to date with required metadata
        // before pass to other below service
        generationResult = generationResult.copyWith(generatedMessages: addedMessages);
      }

      if (_postResponseEngine != null) {
        // Phase 4: Post-Response Processing
        final postResponseInput = PostResponseEngineInput(
          input: queryContext,
          initialRequestMessageId: userMessage.messageId,
          requestMessages: contextResult.prompts,
          result: generationResult,
          conversationManager: _conversationManager,
        );

        await _postResponseEngine.execute(postResponseInput);
      }
      final generationState = GenerationState<GenerationResult>.complete(generationResult);
      _generationStateController.add(generationState);
      return generationState;
    } catch (error, stackTrace) {
      if (revertInputOnError) {
        await _conversationManager.removeMessages([userMessage].lock);
      }

      final errorState = GenerationState<GenerationResult>.error(
        KaiException.exception(error.toString(), stackTrace),
      );
      _setState(errorState);
      return errorState;
    }
  }

  Future<void> cancel() async {
    _cancelToken.cancel();
    _setState(GenerationState.error(KaiException.cancelled()));
  }

  Stream<IList<CoreMessage>> get messagesStream => _conversationManager.messagesStream;
  Future<IList<CoreMessage>> getAllMessages() => _conversationManager.getMessages();

  Stream<GenerationState<GenerationResult>> get generationStateStream =>
      _generationStateController.stream;

  /// Extends [ChatControllerBase] must call dispose to close streams otherwise memory leaks may occur
  void dispose() {
    _generationStateController.close();
    _cancelToken.cancel();
  }

  void _setState(GenerationState<GenerationResult> state) {
    _generationStateController.add(state);
    onStateChange(state);
  }

  void _setLoadingPhase(LoadingPhase phase) => _setState(GenerationState.loading(phase));

  /// Callback to listen for state changes, this helpful for implementing custom logic or log the
  /// state provide more flexible. default to do nothing
  void onStateChange(GenerationState<GenerationResult> state) {}

  /// Execute before the final generation step, allow to track what being send for generation
  /// this allow to track what being sent for generation. this helpful for logging etc
  void onPromptsReady(IList<CoreMessage> messages) {}
}

/// A ready-to-use chat controller implementation for AI-powered conversations.
///
/// `KaiChatController` is the primary entry point for integrating AI chat functionality
/// into your application. It extends [ChatControllerBase] with sensible defaults
/// and a convenient factory constructor for quick setup.
///
/// ## Features
/// - **Simple initialization**: Use [create] factory for async setup with minimal configuration
/// - **Flexible storage**: Supports both in-memory and persistent message storage
/// - **Customizable context**: Configure system prompts or provide custom [ContextEngine]
/// - **Extensible pipeline**: Add query preprocessing and post-response processing
///
/// ## Basic Usage
/// ```dart
/// final controller = await KaiChatController.create(
///   generationService: myGenerationService,
///   systemPrompt: 'You are a helpful assistant.',
/// );
///
/// // Submit user input and get AI response
/// final result = await controller.submit('Hello!');
///
/// // Listen to message updates
/// controller.messagesStream.listen((messages) {
///   print('Messages: $messages');
/// });
/// ```
///
/// ## With Persistent Storage
/// ```dart
/// final controller = await KaiChatController.create(
///   sessionId: 'user-123-session-1',
///   generationService: myGenerationService,
///   repository: MyFirebaseMessageRepository(),
///   systemPrompt: 'You are a helpful assistant.',
/// );
/// ```
///
/// ## With Custom Context Engine
/// ```dart
/// final controller = await KaiChatController.create(
///   generationService: myGenerationService,
///   contextEngine: ContextEngine.builder([
///     PromptTemplate.system('You are an expert coder.'),
///     PromptTemplate.buildParallel(UserProfileContext()),
///     PromptTemplate.buildSequential(HistoryContext()),
///     PromptTemplate.input(),
///   ]),
/// );
/// ```
///
/// See also:
/// - [ChatControllerBase] for the underlying orchestration logic
/// - [ContextEngine] for customizing prompt construction
/// - [ConversationManager] for message persistence details
final class KaiChatController extends ChatControllerBase<CoreMessage> {
  final ContextEngine _contextEngine;
  final void Function(IList<CoreMessage> messages)? _onPromptsReady;
  final void Function(GenerationState<GenerationResult> state)? _onStateChange;

  KaiChatController._({
    required ContextEngine contextEngine,
    required super.conversationManager,
    required super.queryEngine,
    required super.generationService,
    required super.postResponseEngine,
    void Function(IList<CoreMessage> messages)? onPromptsReady,
    void Function(GenerationState<GenerationResult> state)? onStateChange,
  }) : _contextEngine = contextEngine,
       _onPromptsReady = onPromptsReady,
       _onStateChange = onStateChange;

  @override
  ContextEngine build() => _contextEngine;

  /// Creates a new [KaiChatController] with async initialization.
  ///
  /// This factory method handles all the setup required for a functional chat controller,
  /// including creating the conversation session and loading existing messages from storage.
  ///
  /// ## Parameters
  ///
  /// - **[sessionId]**: Unique identifier for the conversation session. Defaults to `'default'`.
  ///   Use different session IDs to maintain separate conversation threads.
  ///
  /// - **[generationService]**: Required. The AI generation service that handles
  ///   communication with the AI backend (e.g., OpenAI, Gemini, Claude).
  ///
  /// - **[repository]**: Optional message repository for persistent storage.
  ///   If not provided, uses [InMemoryMessageRepository] (messages lost on app restart).
  ///   Implement [CoreMessageRepository] for custom persistence (Firebase, SQLite, etc.).
  ///
  /// - **[contextEngine]**: Optional custom context engine for advanced prompt construction.
  ///   Mutually exclusive with [systemPrompt] - provide one or the other, not both.
  ///
  /// - **[systemPrompt]**: Optional system prompt text for simple use cases.
  ///   Creates a [SimpleContextEngine] internally. Cannot be used with [contextEngine].
  ///
  /// - **[queryEngine]**: Optional query preprocessor for input transformation,
  ///   intent detection, or query augmentation before context building.
  ///
  /// - **[postEngine]**: Optional post-response processor for actions after AI generation,
  ///   such as analytics, logging, or triggering side effects.
  ///
  /// - **[onPromptsReady]**: Optional callback invoked when prompts are ready for generation.
  ///   Receives the list of messages that will be sent to the AI service.
  ///
  /// - **[onStateChange]**: Optional callback invoked when the generation state changes.
  ///   Receives the current [GenerationState] for tracking progress.
  ///
  /// ## Returns
  /// A fully initialized [KaiChatController] ready for use.
  ///
  /// ## Throws
  /// - [AssertionError] if both [contextEngine] and [systemPrompt] are provided.
  ///
  /// ## Example
  /// ```dart
  /// final controller = await KaiChatController.create(
  ///   sessionId: 'chat-${DateTime.now().millisecondsSinceEpoch}',
  ///   generationService: GeminiGenerationService(apiKey: 'your-key'),
  ///   repository: FirebaseMessageRepository(userId: currentUser.id),
  ///   systemPrompt: 'You are a friendly cooking assistant.',
  /// );
  /// ```
  static Future<KaiChatController> create({
    String sessionId = 'default',
    required GenerationServiceBase generationService,
    CoreMessageRepository? repository,
    ContextEngine? contextEngine,
    String? systemPrompt,
    QueryEngineBase? queryEngine,
    PostResponseEngineBase? postEngine,
    void Function(IList<CoreMessage> messages)? onPromptsReady,
    void Function(GenerationState<GenerationResult> state)? onStateChange,
  }) async {
    assert(
      contextEngine == null || systemPrompt == null,
      'Cannot provide both contextEngine and systemPrompt. Use contextEngine for custom prompt building, or systemPrompt for simple cases.',
    );

    final session = ConversationSession.withCurrentTime(id: sessionId);

    final conversation = await ConversationManager.create(
      repository: repository ?? InMemoryMessageRepository(),
      session: session,
      messageAdapter: CoreMessageAdapter(),
    );

    return KaiChatController._(
      contextEngine: contextEngine ?? SimpleContextEngine(systemPrompt: systemPrompt),
      conversationManager: conversation,
      queryEngine: queryEngine,
      postResponseEngine: postEngine,
      generationService: generationService,
      onPromptsReady: onPromptsReady,
      onStateChange: onStateChange,
    );
  }

  @override
  void onPromptsReady(IList<CoreMessage> messages) {
    super.onPromptsReady(messages);
    _onPromptsReady?.call(messages);
  }

  @override
  void onStateChange(GenerationState<GenerationResult> state) {
    super.onStateChange(state);
    _onStateChange?.call(state);
  }
}
