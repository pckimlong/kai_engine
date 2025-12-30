import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:test/test.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:mocktail/mocktail.dart';

GenerationResult createTestGenerationResult({
  required IList<CoreMessage> messages,
  IList<CoreMessage>? requestMessages,
  Map<String, dynamic>? extensions,
}) {
  return GenerationResult(
    generatedMessages: messages,
    requestMessages: requestMessages ?? const IList.empty(),
    extensions: extensions,
    usage: null,
  );
}

final class MockConversationManager extends Mock
    implements ConversationManager<TestMessage> {
  @override
  ConversationSession get session =>
      const ConversationSession(id: 'test_session');
}

class MockGenerationService extends Mock implements GenerationServiceBase {}

final class FakeQueryEngine extends QueryEngineBase {
  Future<QueryContext> Function(QueryEngineInput input)? onExecute;
  bool executeCalled = false;
  int executeCallCount = 0;
  QueryEngineInput? lastInput;
  Exception? throwOnExecute;

  @override
  Future<QueryContext> execute(QueryEngineInput input) async {
    executeCalled = true;
    executeCallCount++;
    lastInput = input;
    if (throwOnExecute != null) {
      throw throwOnExecute!;
    }
    if (onExecute != null) {
      return onExecute!(input);
    }
    return QueryContext(
      originalQuery: input.rawInput,
      processedQuery: input.rawInput,
      session: input.session,
    );
  }

  void reset() {
    executeCalled = false;
    executeCallCount = 0;
    lastInput = null;
    onExecute = null;
    throwOnExecute = null;
  }
}

final class FakePostResponseEngine extends PostResponseEngineBase {
  Future<void> Function(PostResponseEngineInput input)? onExecute;
  bool executeCalled = false;
  int executeCallCount = 0;
  PostResponseEngineInput? lastInput;
  Exception? throwOnExecute;

  @override
  Future<void> execute(PostResponseEngineInput input) async {
    executeCalled = true;
    executeCallCount++;
    lastInput = input;
    if (throwOnExecute != null) {
      throw throwOnExecute!;
    }
    if (onExecute != null) {
      return onExecute!(input);
    }
  }

  void reset() {
    executeCalled = false;
    executeCallCount = 0;
    lastInput = null;
    onExecute = null;
    throwOnExecute = null;
  }
}

final class TestContextEngine extends ContextEngine {
  Future<({CoreMessage userMessage, IList<CoreMessage> prompts})> Function({
    required IList<CoreMessage> source,
    required QueryContext inputQuery,
    CoreMessage? providedUserMessage,
  })?
  _generateFunction;

  TestContextEngine({
    Future<({CoreMessage userMessage, IList<CoreMessage> prompts})> Function({
      required IList<CoreMessage> source,
      required QueryContext inputQuery,
      CoreMessage? providedUserMessage,
    })?
    generateFunction,
  }) : _generateFunction = generateFunction;

  void setGenerateFunction(
    Future<({CoreMessage userMessage, IList<CoreMessage> prompts})> Function({
      required IList<CoreMessage> source,
      required QueryContext inputQuery,
      CoreMessage? providedUserMessage,
    })
    generateFunction,
  ) {
    _generateFunction = generateFunction;
  }

  @override
  List<PromptTemplate> get promptBuilder => [const PromptTemplate.input()];

  @override
  Future<({CoreMessage userMessage, IList<CoreMessage> prompts})> generate({
    required IList<CoreMessage> source,
    required QueryContext inputQuery,
    CoreMessage? providedUserMessage,
  }) {
    if (_generateFunction != null) {
      return _generateFunction!(
        source: source,
        inputQuery: inputQuery,
        providedUserMessage: providedUserMessage,
      );
    }
    final userMessage =
        providedUserMessage?.copyWith(content: inputQuery.processedQuery) ??
        CoreMessage.user(content: inputQuery.processedQuery);
    return Future.value((
      userMessage: userMessage,
      prompts: IList([userMessage]),
    ));
  }
}

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

final class TestChatController extends ChatControllerBase<TestMessage> {
  final TestContextEngine _testContextEngine;

  TestChatController({
    required super.conversationManager,
    required super.generationService,
    super.queryEngine,
    super.postResponseEngine,
    required TestContextEngine testContextEngine,
  }) : _testContextEngine = testContextEngine;

  @override
  ContextEngine build() => _testContextEngine;

  @override
  GenerationExecuteConfig generativeConfigs(IList<CoreMessage> prompts) {
    return const GenerationExecuteConfig(
      tools: [],
      config: {'temperature': 0.7},
    );
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
    registerFallbackValue(
      QueryEngineInput(
        rawInput: 'test',
        session: const ConversationSession(id: 'test_session'),
        histories: const IList.empty(),
      ),
    );
    registerFallbackValue(
      ContextEngineInput(
        inputQuery: const QueryContext(
          originalQuery: 'test',
          processedQuery: 'test',
          session: ConversationSession(id: 'test_session'),
        ),
        conversationMessages: const IList.empty(),
        providedUserMessage: null,
      ),
    );
    registerFallbackValue(
      PostResponseEngineInput(
        input: const QueryContext(
          originalQuery: 'test',
          processedQuery: 'test',
          session: ConversationSession(id: 'test_session'),
        ),
        initialRequestMessageId: 'test',
        requestMessages: const IList.empty(),
        result: createTestGenerationResult(
          messages: IList([CoreMessage.ai(content: 'test')]),
        ),
        conversationManager: MockConversationManager(),
      ),
    );
  });

  group('ChatControllerBase', () {
    late MockConversationManager mockConversationManager;
    late MockGenerationService mockGenerationService;
    late FakeQueryEngine fakeQueryEngine;
    late FakePostResponseEngine fakePostResponseEngine;
    late TestContextEngine testContextEngine;
    late TestChatController controller;

    setUp(() {
      mockConversationManager = MockConversationManager();
      mockGenerationService = MockGenerationService();
      fakeQueryEngine = FakeQueryEngine();
      fakePostResponseEngine = FakePostResponseEngine();
      testContextEngine = TestContextEngine();

      controller = TestChatController(
        conversationManager: mockConversationManager,
        generationService: mockGenerationService,
        queryEngine: fakeQueryEngine,
        postResponseEngine: fakePostResponseEngine,
        testContextEngine: testContextEngine,
      );
    });

    group('constructor', () {
      test('should create controller without optional engines', () {
        final controllerWithoutOptional = TestChatController(
          conversationManager: mockConversationManager,
          generationService: mockGenerationService,
          testContextEngine: testContextEngine,
        );

        expect(controllerWithoutOptional, isNotNull);
      });

      test('should create controller with all engines', () {
        expect(controller, isNotNull);
      });
    });

    group('submit', () {
      setUp(() {
        fakeQueryEngine.onExecute = (input) async => QueryContext(
          originalQuery: input.rawInput,
          processedQuery: input.rawInput,
          session: const ConversationSession(id: 'test_session'),
        );

        when(
          () => mockConversationManager.getMessages(),
        ).thenAnswer((_) async => IList<CoreMessage>(const []));

        testContextEngine = TestContextEngine(
          generateFunction:
              ({
                required IList<CoreMessage> source,
                required QueryContext inputQuery,
                CoreMessage? providedUserMessage,
              }) async => (
                userMessage:
                    providedUserMessage ??
                    CoreMessage.user(messageId: 'user-1', content: 'Hello'),
                prompts: IList([
                  providedUserMessage ??
                      CoreMessage.user(messageId: 'user-1', content: 'Hello'),
                ]),
              ),
        );

        when(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            toolingConfig: any(named: 'toolingConfig'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) {
          final streamController =
              StreamController<GenerationState<GenerationResult>>();
          final result = createTestGenerationResult(
            messages: IList([
              CoreMessage.ai(messageId: 'ai-1', content: 'Hi there'),
            ]),
          );

          Future.microtask(() {
            streamController.add(GenerationState.complete(result));
            streamController.close();
          });

          return streamController.stream;
        });

        when(() => mockConversationManager.addMessages(any())).thenAnswer((
          invocation,
        ) async {
          final messages =
              invocation.positionalArguments[0] as IList<CoreMessage>;
          return messages;
        });

        when(
          () => mockConversationManager.updateMessages(any()),
        ).thenAnswer((_) async {});

        controller = TestChatController(
          conversationManager: mockConversationManager,
          generationService: mockGenerationService,
          queryEngine: fakeQueryEngine,
          postResponseEngine: fakePostResponseEngine,
          testContextEngine: testContextEngine,
        );
      });

      test('should complete successful submission flow', () async {
        final result = await controller.submit('Hello');

        expect(result, isA<GenerationCompleteState<GenerationResult>>());

        expect(fakeQueryEngine.executeCallCount, 1);
        verify(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            toolingConfig: any(named: 'toolingConfig'),
            config: any(named: 'config'),
          ),
        ).called(1);
        verify(() => mockConversationManager.addMessages(any())).called(2);
        expect(fakePostResponseEngine.executeCallCount, 1);
      });

      test('should handle query engine failure', () async {
        fakeQueryEngine.reset();
        fakeQueryEngine.throwOnExecute = Exception('Query processing failed');

        when(
          () => mockConversationManager.removeMessages(any()),
        ).thenAnswer((_) async {});

        final result = await controller.submit(
          'Hello',
          revertInputOnError: true,
        );

        expect(result, isA<GenerationErrorState<GenerationResult>>());

        verify(() => mockConversationManager.removeMessages(any())).called(1);

        verifyNever(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            toolingConfig: any(named: 'toolingConfig'),
            config: any(named: 'config'),
          ),
        );
      });

      test('should handle context engine failure', () async {
        final failingContextEngine = TestContextEngine(
          generateFunction:
              ({
                required IList<CoreMessage> source,
                required QueryContext inputQuery,
                CoreMessage? providedUserMessage,
              }) async => throw Exception('Context generation failed'),
        );

        final failingController = TestChatController(
          conversationManager: mockConversationManager,
          generationService: mockGenerationService,
          queryEngine: fakeQueryEngine,
          postResponseEngine: fakePostResponseEngine,
          testContextEngine: failingContextEngine,
        );

        when(
          () => mockConversationManager.removeMessages(any()),
        ).thenAnswer((_) async {});

        final result = await failingController.submit(
          'Hello',
          revertInputOnError: true,
        );

        expect(result, isA<GenerationErrorState<GenerationResult>>());

        verify(() => mockConversationManager.removeMessages(any())).called(1);
      });

      test('should handle generation service failure', () async {
        when(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            toolingConfig: any(named: 'toolingConfig'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) {
          final streamController =
              StreamController<GenerationState<GenerationResult>>();

          Future.microtask(() {
            streamController.addError(Exception('Generation failed'));
          });

          return streamController.stream;
        });

        when(
          () => mockConversationManager.removeMessages(any()),
        ).thenAnswer((_) async {});

        final result = await controller.submit(
          'Hello',
          revertInputOnError: true,
        );

        expect(result, isA<GenerationErrorState<GenerationResult>>());

        verify(() => mockConversationManager.removeMessages(any())).called(1);
      });

      test('should handle null final state error', () async {
        when(
          () => mockGenerationService.stream(
            any(),
            cancelToken: any(named: 'cancelToken'),
            tools: any(named: 'tools'),
            toolingConfig: any(named: 'toolingConfig'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) {
          final streamController =
              StreamController<GenerationState<GenerationResult>>();

          Future.microtask(() {
            streamController.close();
          });

          return streamController.stream;
        });

        when(
          () => mockConversationManager.removeMessages(any()),
        ).thenAnswer((_) async {});

        final result = await controller.submit(
          'Hello',
          revertInputOnError: true,
        );

        expect(result, isA<GenerationErrorState<GenerationResult>>());

        verify(() => mockConversationManager.removeMessages(any())).called(1);
      });

      test('should handle post response engine failure gracefully', () async {
        fakePostResponseEngine.throwOnExecute = Exception(
          'Post response failed',
        );

        final result = await controller.submit('Hello');

        expect(result, isA<GenerationErrorState<GenerationResult>>());
      });

      test(
        'should revert input on error when revertInputOnError is true',
        () async {
          fakeQueryEngine.reset();
          fakeQueryEngine.throwOnExecute = Exception('Query failed');

          when(
            () => mockConversationManager.removeMessages(any()),
          ).thenAnswer((_) async {});

          final result = await controller.submit(
            'Hello',
            revertInputOnError: true,
          );

          expect(result, isA<GenerationErrorState<GenerationResult>>());

          verify(() => mockConversationManager.removeMessages(any())).called(1);
        },
      );

      test(
        'should revert persisted message on error when revertInputOnError is true',
        () async {
          when(
            () => mockGenerationService.stream(
              any(),
              cancelToken: any(named: 'cancelToken'),
              tools: any(named: 'tools'),
              toolingConfig: any(named: 'toolingConfig'),
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

          expect(result, isA<GenerationErrorState<GenerationResult>>());

          verify(() => mockConversationManager.removeMessages(any())).called(1);
        },
      );

      test(
        'should not revert input on error when revertInputOnError is false',
        () async {
          fakeQueryEngine.reset();
          fakeQueryEngine.throwOnExecute = Exception('Query failed');

          final result = await controller.submit(
            'Hello',
            revertInputOnError: false,
          );

          expect(result, isA<GenerationErrorState<GenerationResult>>());

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
              toolingConfig: any(named: 'toolingConfig'),
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
              toolingConfig: any(named: 'toolingConfig'),
              config: any(named: 'config'),
            ),
          ).thenAnswer((_) {
            final streamController =
                StreamController<GenerationState<GenerationResult>>();

            Future.microtask(() {
              streamController.add(
                GenerationState.error(
                  KaiException.exception('Stream generation failed'),
                ),
              );
              streamController.close();
            });

            return streamController.stream;
          });

          when(
            () => mockConversationManager.removeMessages(any()),
          ).thenAnswer((_) async {});

          final result = await controller.submit(
            'Hello',
            revertInputOnError: true,
          );

          expect(result, isA<GenerationErrorState<GenerationResult>>());

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
              toolingConfig: any(named: 'toolingConfig'),
              config: any(named: 'config'),
            ),
          ).thenAnswer((_) {
            final streamController =
                StreamController<GenerationState<GenerationResult>>();

            Future.microtask(() {
              streamController.add(
                GenerationState.error(
                  KaiException.exception('Stream generation failed'),
                ),
              );
              streamController.close();
            });

            return streamController.stream;
          });

          final result = await controller.submit(
            'Hello',
            revertInputOnError: false,
          );

          expect(result, isA<GenerationErrorState<GenerationResult>>());

          verifyNever(() => mockConversationManager.removeMessages(any()));
        },
      );

      test('should emit states through stream during submission', () async {
        final states = <GenerationState<GenerationResult>>[];
        final subscription = controller.generationStateStream.listen(
          states.add,
        );

        await controller.submit('Hello');

        expect(states.length, greaterThan(1));
        expect(states.any((s) => s is GenerationLoadingState), isTrue);
        expect(states.any((s) => s is GenerationCompleteState), isTrue);

        await subscription.cancel();
      });

      test(
        'should not have duplicate user input in prompt sent to stream',
        () async {
          IList<CoreMessage>? capturedPrompts;

          final localMockConversationManager = MockConversationManager();
          final localMockGenerationService = MockGenerationService();
          final localFakeQueryEngine = FakeQueryEngine();
          final localFakePostResponseEngine = FakePostResponseEngine();

          when(() => localMockConversationManager.getMessages()).thenAnswer(
            (_) async => IList([
              CoreMessage.user(content: 'Previous message'),
              CoreMessage.ai(content: 'Previous response'),
            ]),
          );

          when(
            () => localMockConversationManager.addMessages(any()),
          ).thenAnswer((invocation) async {
            final messages =
                invocation.positionalArguments[0] as IList<CoreMessage>;
            return messages;
          });

          when(
            () => localMockConversationManager.updateMessages(any()),
          ).thenAnswer((_) async {});

          localFakeQueryEngine.onExecute = (input) async => QueryContext(
            originalQuery: input.rawInput,
            processedQuery: input.rawInput,
            session: const ConversationSession(id: 'test_session'),
          );

          when(
            () => localMockGenerationService.stream(
              captureAny(that: isA<IList<CoreMessage>>()),
              cancelToken: any(named: 'cancelToken'),
              tools: any(named: 'tools'),
              toolingConfig: any(named: 'toolingConfig'),
              config: any(named: 'config'),
            ),
          ).thenAnswer((invocation) {
            capturedPrompts =
                invocation.positionalArguments[0] as IList<CoreMessage>;

            final streamController =
                StreamController<GenerationState<GenerationResult>>();
            final result = createTestGenerationResult(
              messages: IList([
                CoreMessage.ai(messageId: 'ai-1', content: 'Hi there'),
              ]),
            );

            Future.microtask(() {
              streamController.add(GenerationState.complete(result));
              streamController.close();
            });

            return streamController.stream;
          });

          final localTestContextEngine = TestContextEngine(
            generateFunction:
                ({
                  required IList<CoreMessage> source,
                  required QueryContext inputQuery,
                  CoreMessage? providedUserMessage,
                }) async => (
                  userMessage:
                      providedUserMessage ??
                      CoreMessage.user(messageId: 'user-1', content: 'Hello'),
                  prompts: IList([
                    CoreMessage.user(content: 'Previous message'),
                    CoreMessage.ai(content: 'Previous response'),
                    providedUserMessage ??
                        CoreMessage.user(messageId: 'user-1', content: 'Hello'),
                  ]),
                ),
          );

          final localController = TestChatController(
            conversationManager: localMockConversationManager,
            generationService: localMockGenerationService,
            queryEngine: localFakeQueryEngine,
            postResponseEngine: localFakePostResponseEngine,
            testContextEngine: localTestContextEngine,
          );

          await localController.submit('Hello');

          expect(capturedPrompts, isNotNull);
          expect(capturedPrompts!.length, equals(3));

          expect(capturedPrompts![0].content, equals('Previous message'));
          expect(capturedPrompts![1].content, equals('Previous response'));
          expect(capturedPrompts![2].content, equals('Hello'));

          final helloMessages = capturedPrompts!
              .where((msg) => msg.content == 'Hello')
              .toList();
          expect(helloMessages.length, equals(1));
          expect(helloMessages[0].messageId, isNotEmpty);
        },
      );
    });

    group('streams', () {
      test('should provide messages stream from conversation manager', () {
        expect(controller, isNotNull);
      });
    });

    group('dispose', () {
      test('should dispose resources without errors', () {
        expect(() => controller.dispose(), returnsNormally);
      });
    });
  });
}
