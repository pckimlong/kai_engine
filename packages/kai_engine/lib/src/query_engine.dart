import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'models/conversation_session.dart';
import 'models/query_context.dart';

interface class QueryEngine {
  Future<QueryContext> process(
    String rawInput, {
    required ConversationSession session,
    Function(String stageName)? onStageStart,
  }) async {
    // Default implementation, no any logic, you might need to abstract it to extend functionality
    return QueryContext(
      session: session,
      originalQuery: rawInput,
      processedQuery: rawInput.trim(),
      embeddings: const IList.empty(),
      metadata: const {},
    );
  }
}
