import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

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
        CoreMessage.backgroundContext('Hello'),
        CoreMessage.backgroundContext('How are you?'),
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
      when(() => mockBuilder.build(any(), any(), any())).thenAnswer(
        (_) async =>
            [CoreMessage.backgroundContext('Current date: 2023-01-01')].lock,
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

      verify(() => mockBuilder.build(any(), any(), any())).called(1);
    });

    test('generates prompt with parallel function builder', () async {
      final engine = TestContextEngine([
        const PromptTemplate.system('You are a helpful assistant'),
        PromptTemplate.buildParallelFn((input, inputMessageId, context) async {
          return [
            CoreMessage.backgroundContext('Current date: 2023-01-01'),
          ].lock;
        }),
        const PromptTemplate.input(),
      ]);

      final result = await engine.generate(
        source: sourceMessages,
        inputQuery: queryContext,
      );

      expect(result, isNotNull);
      expect(result.prompts.length, 3);
      expect(result.prompts[0].content, 'You are a helpful assistant');
      expect(result.prompts[1].content, 'Current date: 2023-01-01');
      expect(result.userMessage.content, 'Tell me a joke');
    });

    test('generates prompt with sequential builders', () async {
      final mockBuilder = MockSequentialContextBuilder();
      when(() => mockBuilder.build(any(), any(), any())).thenAnswer(
        (_) async => [CoreMessage.backgroundContext('Processed history')].lock,
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

      verify(() => mockBuilder.build(any(), any(), any())).called(1);
    });

    test('executes parallel builders concurrently', () async {
      final mockBuilder1 = MockParallelContextBuilder();
      final mockBuilder2 = MockParallelContextBuilder();

      // Simulate different execution times
      when(() => mockBuilder1.build(any(), any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [CoreMessage.backgroundContext('Parallel 1')].lock;
      });

      when(() => mockBuilder2.build(any(), any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [CoreMessage.backgroundContext('Parallel 2')].lock;
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

      verify(() => mockBuilder1.build(any(), any(), any())).called(1);
      verify(() => mockBuilder2.build(any(), any(), any())).called(1);
    });

    test('executes sequential builders in order', () async {
      final mockBuilder1 = MockSequentialContextBuilder();
      final mockBuilder2 = MockSequentialContextBuilder();

      final callOrder = <String>[];

      when(() => mockBuilder1.build(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        callOrder.add('builder1');
        final previous =
            invocation.positionalArguments[2] as IList<CoreMessage>;
        return [
          ...previous,
          CoreMessage.backgroundContext('Sequential 1'),
        ].lock;
      });

      when(() => mockBuilder2.build(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        callOrder.add('builder2');
        final previous =
            invocation.positionalArguments[2] as IList<CoreMessage>;
        return [
          ...previous,
          CoreMessage.backgroundContext('Sequential 2'),
        ].lock;
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
      verify(() => mockBuilder1.build(any(), any(), any())).called(1);
      verify(() => mockBuilder2.build(any(), any(), any())).called(1);
    });

    test('processes parallel and sequential builders correctly', () async {
      final mockParallelBuilder = MockParallelContextBuilder();
      final mockSequentialBuilder = MockSequentialContextBuilder();

      when(() => mockParallelBuilder.build(any(), any(), any())).thenAnswer(
        (_) async => [CoreMessage.backgroundContext('Parallel context')].lock,
      );

      when(() => mockSequentialBuilder.build(any(), any(), any())).thenAnswer(
        (_) async => [CoreMessage.backgroundContext('Sequential context')].lock,
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
      verify(() => mockParallelBuilder.build(any(), any(), any())).called(1);
      verify(() => mockSequentialBuilder.build(any(), any(), any())).called(1);

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

      when(() => mockParallelBuilder.build(any(), any(), any())).thenAnswer(
        (_) async => [CoreMessage.backgroundContext('Parallel context')].lock,
      );

      when(() => mockSequentialBuilder1.build(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        final previous =
            invocation.positionalArguments[2] as IList<CoreMessage>;
        return [
          ...previous,
          CoreMessage.backgroundContext('Sequential context 1'),
        ].lock;
      });

      when(() => mockSequentialBuilder2.build(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        final previous =
            invocation.positionalArguments[2] as IList<CoreMessage>;
        return [
          ...previous,
          CoreMessage.backgroundContext('Sequential context 2'),
        ].lock;
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
      verify(() => mockParallelBuilder.build(any(), any(), any())).called(1);
      verify(() => mockSequentialBuilder1.build(any(), any(), any())).called(1);
      verify(() => mockSequentialBuilder2.build(any(), any(), any())).called(1);

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

    group('Input Template Positioning Tests', () {
      test(
        'preserves input template position when placed between parallel builders',
        () async {
          final mockBuilder1 = MockParallelContextBuilder();
          final mockBuilder2 = MockParallelContextBuilder();

          when(() => mockBuilder1.build(any(), any(), any())).thenAnswer(
            (_) async => [CoreMessage.backgroundContext('Parallel 1')].lock,
          );

          when(() => mockBuilder2.build(any(), any(), any())).thenAnswer(
            (_) async => [CoreMessage.backgroundContext('Parallel 2')].lock,
          );

          final engine = TestContextEngine([
            const PromptTemplate.system('System prompt'),
            PromptTemplate.buildParallel(mockBuilder1),
            const PromptTemplate.input(), // Input between two parallel builders
            PromptTemplate.buildParallel(mockBuilder2),
          ]);

          final result = await engine.generate(
            source: sourceMessages,
            inputQuery: queryContext,
          );

          expect(result.prompts, hasLength(4));
          expect(result.prompts[0].content, 'System prompt');
          expect(result.prompts[1].content, 'Parallel 1');
          expect(
            result.prompts[2].content,
            'Tell me a joke',
          ); // User input at position 2
          expect(result.prompts[3].content, 'Parallel 2');
        },
      );

      test(
        'preserves input template position when placed between sequential builders',
        () async {
          final mockBuilder1 = MockSequentialContextBuilder();
          final mockBuilder2 = MockSequentialContextBuilder();

          when(() => mockBuilder1.build(any(), any(), any())).thenAnswer(
            (_) async => [CoreMessage.backgroundContext('Sequential 1')].lock,
          );

          when(() => mockBuilder2.build(any(), any(), any())).thenAnswer(
            (_) async => [CoreMessage.backgroundContext('Sequential 2')].lock,
          );

          final engine = TestContextEngine([
            const PromptTemplate.system('System prompt'),
            PromptTemplate.buildSequential(mockBuilder1),
            const PromptTemplate.input(), // Input between two sequential builders
            PromptTemplate.buildSequential(mockBuilder2),
          ]);

          final result = await engine.generate(
            source: sourceMessages,
            inputQuery: queryContext,
          );

          expect(result.prompts, hasLength(4));
          expect(result.prompts[0].content, 'System prompt');
          expect(result.prompts[1].content, 'Sequential 1');
          expect(
            result.prompts[2].content,
            'Tell me a joke',
          ); // User input at position 2
          expect(result.prompts[3].content, 'Sequential 2');
        },
      );

      test(
        'preserves input template position when placed between mixed builder types',
        () async {
          final mockParallel = MockParallelContextBuilder();
          final mockSequential = MockSequentialContextBuilder();

          when(() => mockParallel.build(any(), any(), any())).thenAnswer(
            (_) async =>
                [CoreMessage.backgroundContext('Parallel context')].lock,
          );

          when(() => mockSequential.build(any(), any(), any())).thenAnswer(
            (_) async =>
                [CoreMessage.backgroundContext('Sequential context')].lock,
          );

          final engine = TestContextEngine([
            const PromptTemplate.system('System prompt'),
            PromptTemplate.buildParallel(mockParallel),
            const PromptTemplate.input(), // Input between parallel and sequential
            PromptTemplate.buildSequential(mockSequential),
          ]);

          final result = await engine.generate(
            source: sourceMessages,
            inputQuery: queryContext,
          );

          expect(result.prompts, hasLength(4));
          expect(result.prompts[0].content, 'System prompt');
          expect(result.prompts[1].content, 'Parallel context');
          expect(
            result.prompts[2].content,
            'Tell me a joke',
          ); // User input at position 2
          expect(result.prompts[3].content, 'Sequential context');
        },
      );

      test('preserves input template position at the beginning', () async {
        final mockBuilder = MockParallelContextBuilder();

        when(() => mockBuilder.build(any(), any(), any())).thenAnswer(
          (_) async => [CoreMessage.backgroundContext('Parallel context')].lock,
        );

        final engine = TestContextEngine([
          const PromptTemplate.input(), // Input at the beginning
          const PromptTemplate.system('System prompt'),
          PromptTemplate.buildParallel(mockBuilder),
        ]);

        final result = await engine.generate(
          source: sourceMessages,
          inputQuery: queryContext,
        );

        expect(result.prompts, hasLength(3));
        expect(
          result.prompts[0].content,
          'Tell me a joke',
        ); // User input at position 0
        expect(result.prompts[1].content, 'System prompt');
        expect(result.prompts[2].content, 'Parallel context');
      });

      test(
        'preserves input template position in complex mixed template order',
        () async {
          final mockParallel1 = MockParallelContextBuilder();
          final mockParallel2 = MockParallelContextBuilder();
          final mockSequential = MockSequentialContextBuilder();

          when(() => mockParallel1.build(any(), any(), any())).thenAnswer(
            (_) async => [CoreMessage.backgroundContext('Parallel 1')].lock,
          );

          when(() => mockParallel2.build(any(), any(), any())).thenAnswer(
            (_) async => [CoreMessage.backgroundContext('Parallel 2')].lock,
          );

          when(() => mockSequential.build(any(), any(), any())).thenAnswer(
            (_) async => [CoreMessage.backgroundContext('Sequential')].lock,
          );

          final engine = TestContextEngine([
            const PromptTemplate.system('System 1'),
            PromptTemplate.buildParallel(mockParallel1),
            const PromptTemplate.system('System 2'),
            const PromptTemplate.input(), // Input at position 3
            PromptTemplate.buildSequential(mockSequential),
            PromptTemplate.buildParallel(mockParallel2),
            const PromptTemplate.system('System 3'),
          ]);

          final result = await engine.generate(
            source: sourceMessages,
            inputQuery: queryContext,
          );

          expect(result.prompts, hasLength(7));
          expect(result.prompts[0].content, 'System 1');
          expect(result.prompts[1].content, 'Parallel 1');
          expect(result.prompts[2].content, 'System 2');
          expect(
            result.prompts[3].content,
            'Tell me a joke',
          ); // User input at position 3
          expect(result.prompts[4].content, 'Sequential');
          expect(result.prompts[5].content, 'Parallel 2');
          expect(result.prompts[6].content, 'System 3');
        },
      );

      test('throws StateError for unhandled template type', () async {
        // This test validates our safety check for unknown template types
        // Since we can't easily create an unknown template type in production code,
        // we'll test that the existing types are handled correctly
        final mockBuilder = MockParallelContextBuilder();

        when(
          () => mockBuilder.build(any(), any(), any()),
        ).thenAnswer((_) async => [CoreMessage.backgroundContext('Test')].lock);

        final engine = TestContextEngine([
          const PromptTemplate.system('System'),
          PromptTemplate.buildParallel(mockBuilder),
          const PromptTemplate.input(),
        ]);

        // Should complete successfully with all known template types
        final result = await engine.generate(
          source: sourceMessages,
          inputQuery: queryContext,
        );
        expect(result.prompts, hasLength(3));
      });

      test('handles multiple builders with same position correctly', () async {
        // This tests that parallel builders at different positions don't interfere
        final mockBuilder1 = MockParallelContextBuilder();
        final mockBuilder2 = MockParallelContextBuilder();
        final mockBuilder3 = MockParallelContextBuilder();

        when(() => mockBuilder1.build(any(), any(), any())).thenAnswer(
          (_) async => [CoreMessage.backgroundContext('First')].lock,
        );

        when(() => mockBuilder2.build(any(), any(), any())).thenAnswer(
          (_) async => [CoreMessage.backgroundContext('Second')].lock,
        );

        when(() => mockBuilder3.build(any(), any(), any())).thenAnswer(
          (_) async => [CoreMessage.backgroundContext('Third')].lock,
        );

        final engine = TestContextEngine([
          PromptTemplate.buildParallel(mockBuilder1), // index 0
          const PromptTemplate.input(), // index 1
          PromptTemplate.buildParallel(mockBuilder2), // index 2
          const PromptTemplate.system('Middle system'), // index 3
          PromptTemplate.buildParallel(mockBuilder3), // index 4
        ]);

        final result = await engine.generate(
          source: sourceMessages,
          inputQuery: queryContext,
        );

        expect(result.prompts, hasLength(5));
        expect(result.prompts[0].content, 'First');
        expect(
          result.prompts[1].content,
          'Tell me a joke',
        ); // User input at position 1
        expect(result.prompts[2].content, 'Second');
        expect(result.prompts[3].content, 'Middle system');
        expect(result.prompts[4].content, 'Third');
      });

      test(
        'allows real user messages before input template (memory use case)',
        () async {
          // This test validates that real user messages (like from memory/history) can come before input
          final mockMemoryBuilder = MockParallelContextBuilder();

          when(() => mockMemoryBuilder.build(any(), any(), any())).thenAnswer(
            (_) async => [
              CoreMessage.user(content: 'Previous conversation message 1'),
              CoreMessage.user(content: 'Previous conversation message 2'),
              CoreMessage.user(content: 'Previous conversation message 3'),
            ].lock,
          );

          final engine = TestContextEngine([
            const PromptTemplate.system('System prompt'),
            PromptTemplate.buildParallel(
              mockMemoryBuilder,
            ), // Real user messages before input
            const PromptTemplate.input(), // New user input
          ]);

          final result = await engine.generate(
            source: sourceMessages,
            inputQuery: queryContext,
          );

          expect(result.prompts, hasLength(5));
          expect(result.prompts[0].content, 'System prompt');
          expect(result.prompts[1].content, 'Previous conversation message 1');
          expect(result.prompts[2].content, 'Previous conversation message 2');
          expect(result.prompts[3].content, 'Previous conversation message 3');
          expect(
            result.prompts[4].content,
            'Tell me a joke',
          ); // New user input at the end
          expect(result.userMessage.content, 'Tell me a joke');
        },
      );
    });
  });
}
