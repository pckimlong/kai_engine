import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

interface class QueryEngine {
  Future<QueryContext> process(
    String rawInput, {
    required ConversationSession session,
    IList<CoreMessage> histories = const IList.empty(), // might helpful for enhance query
    void Function(String stageName)? onStageStart,
  }) async {
    // Default implementation, no any logic, you might need to abstract it to extend functionality
    return QueryContext(
      session: session,
      originalQuery: rawInput,
      processedQuery: rawInput.trim(),
      embeddings: const [],
      metadata: const {},
    );
  }
}
