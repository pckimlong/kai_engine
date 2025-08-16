import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:mocktail/mocktail.dart';

// Helper function to create GenerationResult with a working displayMessage
GenerationResult createTestGenerationResult({
  required IList<CoreMessage> messages,
  Map<String, dynamic>? extensions,
}) {
  return GenerationResult(
    generatedMessage: messages,
    extensions: extensions,
    requestMessage: messages.last,
  );
}

// Fake classes
// ConversationSession is a sealed class, so we can't extend it directly
// We'll use registerFallbackValue with a real instance instead

// Mock classes
final class MockConversationManager extends Mock implements ConversationManager<TestMessage> {
  @override
  ConversationSession get session => const ConversationSession(id: 'test_session');
}

class MockGenerationService extends Mock implements GenerationServiceBase {}

class MockQueryEngine extends Mock implements QueryEngine {}

class MockPostResponseEngine extends Mock implements PostResponseEngine {}

class MockKaiLogger extends Mock implements KaiLogger {}

// Test implementation of ContextEngine
final class TestContextEngine extends ContextEngine {
  Future<(CoreMessage, IList<CoreMessage>)> Function({
    required IList<CoreMessage> source,
    required QueryContext inputQuery,
    void Function(String name)? onStageStart,
  })?
  _generateFunction;

  TestContextEngine({
    Future<(CoreMessage, IList<CoreMessage>)> Function({
      required IList<CoreMessage> source,
      required QueryContext inputQuery,
      void Function(String name)? onStageStart,
    })?
    generateFunction,
  }) : _generateFunction = generateFunction;

  void setGenerateFunction(Future<(CoreMessage, IList<CoreMessage>)> Function({
    required IList<CoreMessage> source,
    required QueryContext inputQuery,
    void Function(String name)? onStageStart,
  }) generateFunction) {
    _generateFunction = generateFunction;
  }

  @override
  List<PromptTemplate> get promptBuilder => [];

  @override
  Future<(CoreMessage, IList<CoreMessage>)> generate({
    required IList<CoreMessage> source,
    required QueryContext inputQuery,
    void Function(String name)? onStageStart,
  }) {
    if (_generateFunction != null) {
      return _generateFunction!(
        source: source,
        inputQuery: inputQuery,
        onStageStart: onStageStart,
      );
    }
    // Default implementation
    return Future.value((
      CoreMessage.user(content: inputQuery.processedQuery),
      IList([CoreMessage.user(content: inputQuery.processedQuery)]),
    ));
  }
}

// Test message classes
class TestMessage {
  final String id;
  final String content;
  final String type;

  TestMessage({required this.id, required this.content, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ type.hashCode;
}

// Test implementation of ChatControllerBase
final class TestChatController extends ChatControllerBase<TestMessage> {
  final TestContextEngine _testContextEngine;

  TestChatController({
    required super.conversationManager,
    required super.generationService,
    required super.queryEngine,
    required super.postResponseEngine,
    super.logger,
    required TestContextEngine testContextEngine,
  }) : _testContextEngine = testContextEngine;

  @override
  ContextEngine build() => _testContextEngine;

  @override
  GenerationExecuteConfig generativeConfigs(IList<CoreMessage> prompts) {
    return (tools: [], config: {'temperature': 0.7});
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ConversationSession(id: 'test_session'));
    registerFallbackValue(
      const QueryContext(
        originalQuery: 'test',
        processedQuery: 'test',
        session: ConversationSession(id: 'test_session'),
      ),
    );
    registerFallbackValue(IList<CoreMessage>(const []));
    registerFallbackValue(CancelToken());
    registerFallbackValue(CoreMessage.user(content: 'test'));
    registerFallbackValue(
      createTestGenerationResult(
        messages: IList([CoreMessage.ai(content: 'test')]),
      ),
    );
    registerFallbackValue(<ToolSchema>[]);
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(MockConversationManager());
  });

  group('ChatControllerBase', () {
    late MockConversationManager mockConversationManager;
    late MockGenerationService mockGenerationService;
    late MockQueryEngine mockQueryEngine;
    late MockPostResponseEngine mockPostResponseEngine;
    late MockKaiLogger mockLogger;
    late TestContextEngine testContextEngine;
    late TestChatController controller;

    setUp(() {
      mockConversationManager = MockConversationManager();
      mockGenerationService = MockGenerationService();
      mockQueryEngine = MockQueryEngine();
      mockPostResponseEngine = MockPostResponseEngine();
      mockLogger = MockKaiLogger();
      testContextEngine = TestContextEngine();

      // Setup default mocks BEFORE creating controller
      when(
        () => mockLogger.logInfo(any(), data: any(named: 'data')),
      ).thenAnswer((_) async {});
      when(
        () => mockLogger.logError(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).thenAnswer((_) async {});

      controller = TestChatController(
        conversationManager: mockConversationManager,
        generationService: mockGenerationService,
        queryEngine: mockQueryEngine,
        postResponseEngine: mockPostResponseEngine,
        logger: mockLogger,
        testContextEngine: testContextEngine,
      );
    });

    group('constructor', () {
      test('should use NoOpKaiLogger when logger is not provided', () {
        final controllerWithoutLogger = TestChatController(
          conversationManager: mockConversationManager,
          generationService: mockGenerationService,
          queryEngine: mockQueryEngine,
          postResponseEngine: mockPostResponseEngine,
          testContextEngine: testContextEngine,
        );

        expect(controllerWithoutLogger, isNotNull);
      });

      test('should use provided logger', () {
        expect(controller, isNotNull);
        // Logger should be used in subsequent operations
      });
    });

    group('submit', () {
      setUp(() {
        // Setup basic successful flow
        when(
          () => mockConversationManager.addPlaceholderUserMessage(any()),
        ).thenReturn(
          CoreMessage.user(messageId: 'placeholder', content: 'Hello'),
        );

        when(
          () => mockQueryEngine.process(
            any(),
            session: any(named: 'session'),
            onStageStart: any(named: 'onStageStart'),
          ),
        ).thenAnswer(
          (_) async => const QueryContext(
            originalQuery: 'Hello',
            processedQuery: 'Hello',
            session: ConversationSession(id: 'test_session'),
          ),
        );

        when(
          () => mockConversationManager.getMessages(),
        ).thenAnswer((_) async => IList<CoreMessage>(const []));

        testContextEngine = TestContextEngine(
          generateFunction:
              ({
                required IList<CoreMessage> source,
                required QueryContext inputQuery,
                void Function(String name)? onStageStart,
              }) async => (
                CoreMessage.user(messageId: 'user-1', content: 'Hello'),
                IList([
                  CoreMessage.user(messageId: 'user-1', content: 'Hello'),
                ]),
              ),
        );

        when(
          () => mockConversationManager.replacePlaceholderMessage(any(), any()),
        ).thenAnswer((_) async {});

        when(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) {
          final controller = StreamController<GenerationState<GenerationResult>>();
          final result = createTestGenerationResult(
            messages: IList([
              CoreMessage.ai(messageId: 'ai-1', content: 'Hi there'),
            ]),
          );

          Future.microtask(() {
            controller.add(GenerationState.complete(result));
            controller.close();
          });

          return controller.stream;
        });

        when(
          () => mockConversationManager.addMessages(any()),
        ).thenAnswer((_) async {});

        when(
          () => mockPostResponseEngine.process(
            prompts: any(named: 'prompts'),
            result: any(named: 'result'),
            conversationManager: any(named: 'conversationManager'),
          ),
        ).thenAnswer((_) async {});
      });

      test('should complete successful submission flow', () async {
        final result = await controller.submit('Hello');

        expect(result, isA<GenerationCompleteState<CoreMessage>>());

        // Verify logging
        verify(
          () => mockLogger.logInfo(
            'Chat submission started',
            data: any(named: 'data'),
          ),
        ).called(1);
        verify(
          () => mockLogger.logInfo('Chat submission completed successfully'),
        ).called(1);

        // Verify flow
        verify(
          () => mockConversationManager.addPlaceholderUserMessage('Hello'),
        ).called(1);
        verify(
          () => mockQueryEngine.process(
            'Hello',
            session: any(named: 'session'),
            onStageStart: any(named: 'onStageStart'),
          ),
        ).called(1);
        // Context engine generate should have been called (verified by successful execution)
        verify(
          () => mockConversationManager.replacePlaceholderMessage(any(), any()),
        ).called(1);
        verify(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            config: any(named: 'config'),
          ),
        ).called(1);
        verify(() => mockConversationManager.addMessages(any())).called(1);
        verify(
          () => mockPostResponseEngine.process(
            prompts: any(named: 'prompts'),
            result: any(named: 'result'),
            conversationManager: any(named: 'conversationManager'),
          ),
        ).called(1);
      });

      test('should handle query engine failure', () async {
        when(
          () => mockQueryEngine.process(
            any(),
            session: any(named: 'session'),
            onStageStart: any(named: 'onStageStart'),
          ),
        ).thenThrow(Exception('Query processing failed'));

        final result = await controller.submit('Hello');

        expect(result, isA<GenerationErrorState<CoreMessage>>());

        // Should log error
        verify(
          () => mockLogger.logError(
            'Chat submission failed',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);

        // Should not proceed to generation
        verifyNever(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            config: any(named: 'config'),
          ),
        );
      });

      test('should handle context engine failure', () async {
        // Create a new controller with a failing context engine
        final failingContextEngine = TestContextEngine(
          generateFunction:
              ({
                required IList<CoreMessage> source,
                required QueryContext inputQuery,
                void Function(String name)? onStageStart,
              }) async => throw Exception('Context generation failed'),
        );

        final failingController = TestChatController(
          conversationManager: mockConversationManager,
          generationService: mockGenerationService,
          queryEngine: mockQueryEngine,
          postResponseEngine: mockPostResponseEngine,
          logger: mockLogger,
          testContextEngine: failingContextEngine,
        );

        final result = await failingController.submit('Hello');

        expect(result, isA<GenerationErrorState<CoreMessage>>());

        // Should log error
        verify(
          () => mockLogger.logError(
            'Chat submission failed',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      });

      test('should handle generation service failure', () async {
        when(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) {
          final controller = StreamController<GenerationState<GenerationResult>>();

          Future.microtask(() {
            controller.addError(Exception('Generation failed'));
          });

          return controller.stream;
        });

        final result = await controller.submit('Hello');

        expect(result, isA<GenerationErrorState<CoreMessage>>());

        // Should log error
        verify(
          () => mockLogger.logError(
            'Chat submission failed',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      });

      test('should handle null final state error', () async {
        when(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) {
          final controller = StreamController<GenerationState<GenerationResult>>();

          Future.microtask(() {
            controller.close(); // Close without emitting final state
          });

          return controller.stream;
        });

        final result = await controller.submit('Hello');

        expect(result, isA<GenerationErrorState<CoreMessage>>());
        final errorState = result as GenerationErrorState<CoreMessage>;
        expect(
          errorState.exception.toString(),
          contains('Response stream completed without emitting a final state'),
        );
      });

      test('should handle post response engine failure gracefully', () async {
        // Create a delayed error that won't block the main submission flow
        when(
          () => mockPostResponseEngine.process(
            prompts: any(named: 'prompts'),
            result: any(named: 'result'),
            conversationManager: any(named: 'conversationManager'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 10));
          throw Exception('Post response failed');
        });

        final result = await controller.submit('Hello');

        // Should still complete successfully (post-response is background task)
        expect(result, isA<GenerationCompleteState<CoreMessage>>());

        // Give some time for the background task to fail and log
        await Future.delayed(Duration(milliseconds: 50));

        // Should log the post-response error
        verify(
          () => mockLogger.logError(
            'Post response processing failed',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      });

      test(
        'should revert input on error when revertInputOnError is true',
        () async {
          when(
            () => mockQueryEngine.process(
              any(),
              session: any(named: 'session'),
              onStageStart: any(named: 'onStageStart'),
            ),
          ).thenThrow(Exception('Query failed'));

          when(
            () => mockConversationManager.removeMessages(any()),
          ).thenAnswer((_) async {});

          final result = await controller.submit(
            'Hello',
            revertInputOnError: true,
          );

          expect(result, isA<GenerationErrorState<CoreMessage>>());

          // Should remove placeholder
          verify(() => mockConversationManager.removeMessages(any())).called(1);
        },
      );

      test(
        'should revert persisted message on error when revertInputOnError is true',
        () async {
          // Setup successful flow up to generation failure
          when(
            () => mockGenerationService.stream(
              any(),
              cancelToken: any(named: 'cancelToken'),
              tools: any(named: 'tools'),
              config: any(named: 'config'),
            ),
          ).thenThrow(Exception('Generation failed'));

          when(
            () => mockConversationManager.removeMessages(any()),
          ).thenAnswer((_) async {});

          final result = await controller.submit(
            'Hello',
            revertInputOnError: true,
          );

          expect(result, isA<GenerationErrorState<CoreMessage>>());

          // Should remove persisted user message
          verify(() => mockConversationManager.removeMessages(any())).called(1);
        },
      );

      test(
        'should not revert input on error when revertInputOnError is false',
        () async {
          when(
            () => mockQueryEngine.process(
              any(),
              session: any(named: 'session'),
              onStageStart: any(named: 'onStageStart'),
            ),
          ).thenThrow(Exception('Query failed'));

          final result = await controller.submit(
            'Hello',
            revertInputOnError: false,
          );

          expect(result, isA<GenerationErrorState<CoreMessage>>());

          // Should not remove messages
          verifyNever(() => mockConversationManager.removeMessages(any()));
        },
      );

      test(
        'should pass custom generative configs to generation service',
        () async {
          await controller.submit('Hello');

          verify(
            () => mockGenerationService.stream(
              any(),
              cancelToken: any(named: 'cancelToken'),
              tools: [],
              config: {'temperature': 0.7},
            ),
          ).called(1);
        },
      );

      test(
        'should handle stream error states and revert input when revertInputOnError is true',
        () async {
          when(
            () => mockGenerationService.stream(
              any(),
              cancelToken: any(named: 'cancelToken'),
              tools: any(named: 'tools'),
              config: any(named: 'config'),
            ),
          ).thenAnswer((_) {
            final controller = StreamController<GenerationState<GenerationResult>>();

            Future.microtask(() {
              controller.add(
                GenerationState.error(
                  KaiException.exception('Stream generation failed'),
                ),
              );
              controller.close();
            });

            return controller.stream;
          });

          when(
            () => mockConversationManager.removeMessages(any()),
          ).thenAnswer((_) async {});

          final result = await controller.submit(
            'Hello',
            revertInputOnError: true,
          );

          expect(result, isA<GenerationErrorState<CoreMessage>>());

          // Should log stream error
          verify(
            () => mockLogger.logError(
              'Generation stream error',
              error: any(named: 'error'),
            ),
          ).called(1);

          // Should revert user message (not placeholder since userMessage is set by this point)
          verify(() => mockConversationManager.removeMessages(any())).called(1);
        },
      );

      test(
        'should handle stream error states without reverting when revertInputOnError is false',
        () async {
          when(
            () => mockGenerationService.stream(
              any(),
              cancelToken: any(named: 'cancelToken'),
              tools: any(named: 'tools'),
              config: any(named: 'config'),
            ),
          ).thenAnswer((_) {
            final controller = StreamController<GenerationState<GenerationResult>>();

            Future.microtask(() {
              controller.add(
                GenerationState.error(
                  KaiException.exception('Stream generation failed'),
                ),
              );
              controller.close();
            });

            return controller.stream;
          });

          final result = await controller.submit(
            'Hello',
            revertInputOnError: false,
          );

          expect(result, isA<GenerationErrorState<CoreMessage>>());

          // Should log stream error
          verify(
            () => mockLogger.logError(
              'Generation stream error',
              error: any(named: 'error'),
            ),
          ).called(1);

          // Should not revert messages
          verifyNever(() => mockConversationManager.removeMessages(any()));
        },
      );

      test('should emit states through stream during submission', () async {
        final states = <GenerationState<CoreMessage>>[];
        final subscription = controller.generationStateStream.listen(
          states.add,
        );

        await controller.submit('Hello');

        expect(states.length, greaterThan(1));
        expect(states.any((s) => s is GenerationLoadingState), isTrue);
        expect(states.any((s) => s is GenerationCompleteState), isTrue);

        await subscription.cancel();
      });
    });

    group('streams', () {
      test(
        'should provide messages stream from conversation manager',
        () async {
          final testMessages = IList([CoreMessage.user(content: 'Hello')]);

          when(
            () => mockConversationManager.messagesStream,
          ).thenAnswer((_) => Stream.value(testMessages));

          final messages = await controller.messagesStream.first;

          expect(messages.length, equals(1));
          expect(messages.first.content, equals('Hello'));
        },
      );
    });

    group('dispose', () {
      test('should dispose resources without errors', () {
        expect(() => controller.dispose(), returnsNormally);
      });
    });

  });
}
