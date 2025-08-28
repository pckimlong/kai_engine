import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/src/models/generation_execute_config.dart';
import 'package:rxdart/rxdart.dart';

import '../kai_engine.dart';

/// Base orchestrator for chat interactions
/// override to add more configuration
/// [TEntity] is the type of the message object which can use to translate to the backend
abstract base class ChatControllerBase<TEntity> {
  final QueryEngineBase _queryEngine;
  final ConversationManager<TEntity> _conversationManager;
  final GenerationServiceBase _generationService;
  final PostResponseEngineBase _postResponseEngine;
  final CancelToken _cancelToken;
  final KaiInspector _inspector;

  ChatControllerBase({
    required ConversationManager<TEntity> conversationManager,
    required GenerationServiceBase generationService,
    required QueryEngineBase queryEngine,
    required PostResponseEngineBase postResponseEngine,
    KaiInspector? inspector,
  }) : _queryEngine = queryEngine,
       _conversationManager = conversationManager,
       _generationService = generationService,
       _postResponseEngine = postResponseEngine,
       _cancelToken = CancelToken(),
       _inspector = inspector ?? NoOpKaiInspector();

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
  Future<GenerationState<CoreMessage>> submit(
    String input, {
    bool revertInputOnError = false,
  }) async {
    var userMessage = CoreMessage.user(content: input);

    // Use ConversationSession ID for inspector session and user message ID as timeline ID
    final sessionId = _conversationManager.session.id;
    final timelineId = userMessage.messageId; // Use user message ID to track this specific input

    await _inspector.startSession(sessionId);
    await _inspector.startTimeline(sessionId, timelineId, input);

    try {
      // Reset cancel token for new generation
      _cancelToken.reset();

      // Add initial log to the first phase (Query Processing)
      await _inspector.recordPhaseLog(
        sessionId,
        timelineId,
        'query-processing',
        TimelineLog(
          message: 'Chat submission started',
          timestamp: DateTime.now(),
          severity: TimelineLogSeverity.info,
          metadata: {'input': input},
        ),
      );

      _setState(GenerationState.loading());

      // Variable to store the final generation result
      late GenerationResult generationResult;

      unawaited(
        _conversationManager.addMessages([userMessage].lock).then((inserted) async {
          userMessage = inserted.first;
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
      final queryContext = await _inspector.inspectPhase<QueryEngineInput, QueryContext>(
        sessionId,
        timelineId,
        'Query Processing',
        _queryEngine,
        queryInput,
      );

      // Phase 2: Context Building
      _setLoadingPhase(LoadingPhase.buildContext());
      final contextInput = ContextEngineInput(
        inputQuery: queryContext,
        conversationMessages: await _conversationManager.getMessages(),
        providedUserMessage: userMessage,
      );
      final contextResult = await _inspector.inspectPhase(
        sessionId,
        timelineId,
        'Context Building',
        build(),
        contextInput,
      );

      // Log the actual prompt messages for debugging
      await _inspector.recordPromptMessagesLog(
        sessionId,
        timelineId,
        'Context Building',
        PromptMessagesLog(
          message:
              'Context building completed with ${contextResult.prompts.length} prompt messages',
          timestamp: DateTime.now(),
          promptMessages: contextResult.prompts.toList(),
          severity: TimelineLogSeverity.info,
          metadata: {'prompt_count': contextResult.prompts.length},
        ),
      );

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

      generationResult = await _inspector.inspectPhase(
        sessionId,
        timelineId,
        'AI Generation',
        AIGenerationPhase(_generationService),
        aiGenerationInput,
      );

      // Log the actual generated messages for debugging
      await _inspector.recordGeneratedMessagesLog(
        sessionId,
        timelineId,
        'AI Generation',
        GeneratedMessagesLog(
          message:
              'AI generation completed with ${generationResult.generatedMessages.length} generated messages',
          timestamp: DateTime.now(),
          generatedMessages: generationResult.generatedMessages.toList(),
          severity: TimelineLogSeverity.info,
          metadata: {
            'generated_count': generationResult.generatedMessages.length,
            'total_tokens': generationResult.usage?.tokenCount,
          },
        ),
      );

      // Save the AI-generated messages to the conversation
      if (generationResult.generatedMessages.isNotEmpty) {
        final addedMessages = await _conversationManager.addMessages(
          generationResult.generatedMessages,
        );

        // Make sure generated message is updated to date with required metadata
        // before pass to other below service
        generationResult = generationResult.copyWith(generatedMessages: addedMessages);
      }

      // Phase 4: Post-Response Processing
      final postResponseInput = PostResponseEngineInput(
        input: queryContext,
        requestMessages: contextResult.prompts,
        result: generationResult,
        conversationManager: _conversationManager,
      );

      await _inspector.inspectPhase(
        sessionId,
        timelineId,
        'Post-Response Processing',
        _postResponseEngine,
        postResponseInput,
      );

      // Extract AI response text from the generation result
      final aiResponse = generationResult.displayMessage.content;

      await _inspector.endTimeline(sessionId, timelineId, aiResponse: aiResponse);
      final generationState = GenerationState<GenerationResult>.complete(generationResult);
      _generationStateController.add(generationState);
      return _mapGenerationState(generationState);
    } catch (error, stackTrace) {
      await _inspector.endTimeline(sessionId, timelineId, status: TimelineStatus.failed);

      if (revertInputOnError) {
        await _conversationManager.removeMessages([userMessage].lock);
      }

      final errorState = GenerationState<GenerationResult>.error(
        KaiException.exception(error.toString(), stackTrace),
      );
      _generationStateController.add(errorState);
      return _mapGenerationState(errorState);
    }
  }

  Future<void> cancel() async {
    _cancelToken.cancel();
    _setState(GenerationState.error(KaiException.cancelled()));
  }

  Stream<IList<CoreMessage>> get messagesStream => _conversationManager.messagesStream;
  Future<IList<CoreMessage>> getAllMessages() => _conversationManager.getMessages();

  Stream<GenerationState<CoreMessage>> get generationStateStream =>
      _generationStateController.stream.map(_mapGenerationState);

  /// Extends [ChatControllerBase] must call dispose to close streams otherwise memory leaks may occur
  void dispose() {
    _generationStateController.close();
    _cancelToken.cancel();
  }

  GenerationState<CoreMessage> _mapGenerationState(GenerationState<GenerationResult> state) {
    return state.map(
      loading: (l) => GenerationState.loading(l.phase),
      initial: (value) => GenerationState.initial(),
      streamingText: (text) => GenerationState.streamingText(text.text),
      complete: (c) {
        return GenerationState.complete(c.result.displayMessage);
      },
      error: (e) => GenerationState.error(e.exception),
      functionCalling: (f) => GenerationState.functionCalling(f.names),
    );
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
