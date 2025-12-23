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
  final _generationStateController =
      BehaviorSubject<GenerationState<GenerationResult>>.seeded(
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
          (messages) => messages
              .whereNot((m) => m.messageId == userMessage.messageId)
              .toIList(),
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
        final revised = insertedUserMessage.copyWith(
          content: contextResult.userMessage.content,
        );
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

      generationResult = await AIGenerationPhase(
        _generationService,
      ).execute(aiGenerationInput);

      // Save the AI-generated messages to the conversation
      if (generationResult.generatedMessages.isNotEmpty) {
        final addedMessages = await _conversationManager
            .addMessages(generationResult.generatedMessages)
            .then((items) {
              // Prevent from mistake in conversation manager which might lead to duplicate message being added
              final originalIds = generationResult.generatedMessages
                  .map((e) => e.messageId)
                  .toSet();
              return items
                  .where((e) => originalIds.contains(e.messageId))
                  .toIList();
            });

        // Make sure generated message is updated to date with required metadata
        // before pass to other below service
        generationResult = generationResult.copyWith(
          generatedMessages: addedMessages,
        );
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
      final generationState = GenerationState<GenerationResult>.complete(
        generationResult,
      );
      _generationStateController.add(generationState);
      return generationState;
    } catch (error, stackTrace) {
      if (revertInputOnError) {
        await _conversationManager.removeMessages([userMessage].lock);
      }

      final errorState = GenerationState<GenerationResult>.error(
        KaiException.exception(error.toString(), stackTrace),
      );
      _generationStateController.add(errorState);
      return errorState;
    }
  }

  Future<void> cancel() async {
    _cancelToken.cancel();
    _setState(GenerationState.error(KaiException.cancelled()));
  }

  Stream<IList<CoreMessage>> get messagesStream =>
      _conversationManager.messagesStream;
  Future<IList<CoreMessage>> getAllMessages() =>
      _conversationManager.getMessages();

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

  void _setLoadingPhase(LoadingPhase phase) =>
      _setState(GenerationState.loading(phase));

  /// Callback to listen for state changes, this helpful for implementing custom logic or log the
  /// state provide more flexible. default to do nothing
  void onStateChange(GenerationState<GenerationResult> state) {}

  /// Execute before the final generation step, allow to track what being send for generation
  /// this allow to track what being sent for generation. this helpful for logging etc
  void onPromptsReady(IList<CoreMessage> messages) {}
}
