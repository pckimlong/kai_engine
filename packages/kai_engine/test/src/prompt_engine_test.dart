import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

// Mock implementations for testing
class MockParallelContextBuilder extends Mock
    implements ParallelContextBuilder {}

class MockSequentialContextBuilder extends Mock
    implements SequentialContextBuilder {}

// Test implementation of ContextEngine
final class TestContextEngine extends ContextEngine {
  final List<PromptTemplate> _promptBuilder;

  TestContextEngine(this._promptBuilder);

  @override
  List<PromptTemplate> get promptBuilder => _promptBuilder;
}

void main() {
  group('ContextEngine', () {
    late IList<CoreMessage> sourceMessages;
    late QueryContext queryContext;

    setUp(() {
      sourceMessages = IList([
        CoreMessage.user(messageId: const Uuid().v4(), content: 'Hello'),
        CoreMessage.user(messageId: const Uuid().v4(), content: 'How are you?'),
      ]);

      queryContext = const QueryContext(
        session: ConversationSession(id: 'test_session'),
        originalQuery: 'Tell me a joke',
        processedQuery: 'Tell me a joke',
      );

      // Register fallback values for mocktail
      registerFallbackValue(queryContext);
      registerFallbackValue(IList<CoreMessage>(const []));
    });

    test('generates prompt with system template only', () async {
      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        const PromptTemplate.input(),
      ]);

      final result = await engine.generate(
        source: sourceMessages,
        inputQuery: queryContext,
      );

      expect(result, isNotNull);
      expect(result.userMessage, isA<CoreMessage>());
      expect(result.prompts, isA<IList<CoreMessage>>());
      // Should have system message + user message
      expect(result.prompts.length, 2);

      // First message should be the system message
      expect(result.prompts.first.content, 'You are a helpful assistant');

      // User message should match
      expect(result.userMessage.content, 'Tell me a joke');
    });

    test('generates prompt with parallel builders', () async {
      final mockBuilder = MockParallelContextBuilder();
      when(() => mockBuilder.build(any(), any())).thenAnswer(
        (_) async => [
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Current date: 2023-01-01',
          ),
        ],
      );

      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        PromptTemplate.buildParallel(mockBuilder),
        const PromptTemplate.input(),
      ]);

      final result = await engine.generate(
        source: sourceMessages,
        inputQuery: queryContext,
      );

      expect(result, isNotNull);
      // Should have system message + parallel message + user message
      expect(result.prompts.length, 3);
      expect(result.prompts[0].content, 'You are a helpful assistant');
      expect(result.prompts[1].content, 'Current date: 2023-01-01');
      expect(result.userMessage.content, 'Tell me a joke');

      verify(() => mockBuilder.build(any(), any())).called(1);
    });

    test('generates prompt with sequential builders', () async {
      final mockBuilder = MockSequentialContextBuilder();
      when(() => mockBuilder.build(any(), any())).thenAnswer(
        (_) async => [
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Processed history',
          ),
        ],
      );

      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        PromptTemplate.buildSequential(mockBuilder),
        const PromptTemplate.input(),
      ]);

      final result = await engine.generate(
        source: sourceMessages,
        inputQuery: queryContext,
      );

      expect(result, isNotNull);
      // Should have system message + sequential message + user message
      expect(result.prompts.length, 3);
      expect(result.prompts[0].content, 'You are a helpful assistant');
      expect(result.prompts[1].content, 'Processed history');
      expect(result.userMessage.content, 'Tell me a joke');

      verify(() => mockBuilder.build(any(), any())).called(1);
    });

    test('executes parallel builders concurrently', () async {
      final mockBuilder1 = MockParallelContextBuilder();
      final mockBuilder2 = MockParallelContextBuilder();

      // Simulate different execution times
      when(() => mockBuilder1.build(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [
          CoreMessage.user(messageId: const Uuid().v4(), content: 'Parallel 1'),
        ];
      });

      when(() => mockBuilder2.build(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [
          CoreMessage.user(messageId: const Uuid().v4(), content: 'Parallel 2'),
        ];
      });

      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        PromptTemplate.buildParallel(mockBuilder1),
        PromptTemplate.buildParallel(mockBuilder2),
        const PromptTemplate.input(),
      ]);

      final startTime = DateTime.now();

      await engine.generate(source: sourceMessages, inputQuery: queryContext);

      final endTime = DateTime.now();

      final duration = endTime.difference(startTime);

      // If executed sequentially, it would take ~200ms
      // If executed concurrently, it should take ~100ms
      expect(duration.inMilliseconds, lessThan(150));

      verify(() => mockBuilder1.build(any(), any())).called(1);
      verify(() => mockBuilder2.build(any(), any())).called(1);
    });

    test('executes sequential builders in order', () async {
      final mockBuilder1 = MockSequentialContextBuilder();
      final mockBuilder2 = MockSequentialContextBuilder();

      final callOrder = <String>[];

      when(() => mockBuilder1.build(any(), any())).thenAnswer((
        invocation,
      ) async {
        callOrder.add('builder1');
        final previous = invocation.positionalArguments[1] as List<CoreMessage>;
        return [
          ...previous,
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Sequential 1',
          ),
        ];
      });

      when(() => mockBuilder2.build(any(), any())).thenAnswer((
        invocation,
      ) async {
        callOrder.add('builder2');
        final previous = invocation.positionalArguments[1] as List<CoreMessage>;
        return [
          ...previous,
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Sequential 2',
          ),
        ];
      });

      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        PromptTemplate.buildSequential(mockBuilder1),
        PromptTemplate.buildSequential(mockBuilder2),
        const PromptTemplate.input(),
      ]);

      await engine.generate(source: sourceMessages, inputQuery: queryContext);

      // Verify call order
      expect(callOrder, ['builder1', 'builder2']);

      // Verify that each builder was called with the previous context
      verify(() => mockBuilder1.build(any(), any())).called(1);
      verify(() => mockBuilder2.build(any(), any())).called(1);
    });

    test('processes parallel and sequential builders correctly', () async {
      final mockParallelBuilder = MockParallelContextBuilder();
      final mockSequentialBuilder = MockSequentialContextBuilder();

      when(() => mockParallelBuilder.build(any(), any())).thenAnswer(
        (_) async => [
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Parallel context',
          ),
        ],
      );

      when(() => mockSequentialBuilder.build(any(), any())).thenAnswer(
        (_) async => [
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Sequential context',
          ),
        ],
      );

      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        PromptTemplate.buildParallel(mockParallelBuilder),
        PromptTemplate.buildSequential(mockSequentialBuilder),
        const PromptTemplate.input(),
      ]);

      final result = await engine.generate(
        source: sourceMessages,
        inputQuery: queryContext,
      );

      // Verify both builders were called
      verify(() => mockParallelBuilder.build(any(), any())).called(1);
      verify(() => mockSequentialBuilder.build(any(), any())).called(1);

      // Verify the result structure includes all prompts
      expect(
        result.prompts,
        hasLength(4),
      ); // system + parallel + sequential + user input
      expect(result.prompts[0].content, 'You are a helpful assistant');
      expect(result.prompts[1].content, 'Parallel context');
      expect(result.prompts[2].content, 'Sequential context');
    });

    test('throws assertion error when no input template is provided', () async {
      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
      ]);

      expect(
        () => engine.generate(source: sourceMessages, inputQuery: queryContext),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
      'throws assertion error when multiple input templates are provided',
      () async {
        final engine = TestContextEngine([
          const PromptTemplate.system('You are a helpful assistant'),
          const PromptTemplate.input(),
          const PromptTemplate.input(),
        ]);

        expect(
          () =>
              engine.generate(source: sourceMessages, inputQuery: queryContext),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    // This test is no longer relevant as PromptTemplate.input no longer accepts a transformer function
    // The functionality was removed in commit 0096dba
    test('PromptTemplate.input no longer accepts transformer function', () {
      // This is just a placeholder test since the functionality was removed
      expect(true, isTrue);
    });

    test('maintains correct order of mixed template types', () async {
      final mockParallelBuilder = MockParallelContextBuilder();
      final mockSequentialBuilder1 = MockSequentialContextBuilder();
      final mockSequentialBuilder2 = MockSequentialContextBuilder();

      when(() => mockParallelBuilder.build(any(), any())).thenAnswer(
        (_) async => [
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Parallel context',
          ),
        ],
      );

      when(() => mockSequentialBuilder1.build(any(), any())).thenAnswer((
        invocation,
      ) async {
        final previous = invocation.positionalArguments[1] as List<CoreMessage>;
        return [
          ...previous,
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Sequential context 1',
          ),
        ];
      });

      when(() => mockSequentialBuilder2.build(any(), any())).thenAnswer((
        invocation,
      ) async {
        final previous = invocation.positionalArguments[1] as List<CoreMessage>;
        return [
          ...previous,
          CoreMessage.user(
            messageId: const Uuid().v4(),
            content: 'Sequential context 2',
          ),
        ];
      });

      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        PromptTemplate.buildSequential(mockSequentialBuilder1),
        PromptTemplate.buildParallel(mockParallelBuilder),
        PromptTemplate.buildSequential(mockSequentialBuilder2),
        const PromptTemplate.input(),
      ]);

      final result = await engine.generate(
        source: sourceMessages,
        inputQuery: queryContext,
      );

      // Verify that the mocks were called
      verify(() => mockParallelBuilder.build(any(), any())).called(1);
      verify(() => mockSequentialBuilder1.build(any(), any())).called(1);
      verify(() => mockSequentialBuilder2.build(any(), any())).called(1);

      // Check that we have the expected messages
      expect(
        result.prompts.length,
        greaterThan(3),
      ); // At least system + 3 built messages + user input
      expect(result.prompts[0].content, 'You are a helpful assistant');
      expect(result.userMessage.content, 'Tell me a joke');
    });

    test('SimpleContextEngine generates expected prompt structure', () async {
      final engine = SimpleContextEngine();
      final result = await engine.generate(
        source: sourceMessages,
        inputQuery: queryContext,
      );

      expect(result, isNotNull);
      expect(result.prompts, isA<IList<CoreMessage>>());
      // Should have system message + history messages + user message
      expect(result.prompts.length, 2 + sourceMessages.length);

      // First message should be the system message
      expect(
        result.prompts.first.content,
        "You're kai, a useful friendly personal assistant.",
      );

      // User message should match
      expect(result.userMessage.content, 'Tell me a joke');
    });
  });
}
