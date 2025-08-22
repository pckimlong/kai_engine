import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

import 'inspector/kai_phase.dart';
import 'inspector/phase_types.dart';

base class QueryEngineBase extends KaiPhase<QueryEngineInput, QueryEngineOutput> {
  @override
  Future<QueryEngineOutput> execute(QueryEngineInput input) async {
    // Default implementation, no any logic, you might need to abstract it to extend functionality
    return QueryEngineOutput(
      queryContext: QueryContext(
        session: input.session,
        originalQuery: input.rawInput,
        processedQuery: input.rawInput.trim(),
        embeddings: const [],
        metadata: const {},
      ),
    );
  }

  /// Legacy method for backward compatibility - will be removed
  @deprecated
  Future<QueryContext> process(
    String rawInput, {
    required ConversationSession session,
    IList<CoreMessage> histories = const IList.empty(),
    void Function(String stageName)? onStageStart,
  }) async {
    final input = QueryEngineInput(rawInput: rawInput, session: session, histories: histories);

    final result = await execute(input);
    return result.queryContext;
  }
}
