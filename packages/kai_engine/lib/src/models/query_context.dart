import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_engine/src/models/models.dart';

part 'query_context.freezed.dart';

@freezed
sealed class QueryContext with _$QueryContext {
  const QueryContext._();

  const factory QueryContext({
    required ConversationSession session,

    /// Original input from user
    required String originalQuery,
    required String processedQuery,
    @Default(IList.empty()) IList<double> embeddings,

    /// Extensible map for more specific data
    @Default({}) Map<String, dynamic> metadata,
  }) = _QueryContext;
}
