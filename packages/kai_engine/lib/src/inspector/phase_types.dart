import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../conversation_manager.dart';
import '../models/cancel_token.dart';
import '../models/conversation_session.dart';
import '../models/core_message.dart';
import '../models/generation_result.dart';
import '../models/query_context.dart';
import '../tool_schema.dart';

part 'phase_types.freezed.dart';

/// Input type for QueryEngine phase
@freezed
sealed class QueryEngineInput with _$QueryEngineInput {
  const factory QueryEngineInput({
    required String rawInput,
    required ConversationSession session,
    @Default(IList<CoreMessage>.empty()) IList<CoreMessage> histories,
  }) = _QueryEngineInput;
}

/// Input type for ContextEngine phase
@freezed
sealed class ContextEngineInput with _$ContextEngineInput {
  const factory ContextEngineInput({
    required QueryContext inputQuery,
    required IList<CoreMessage> conversationMessages,
  }) = _ContextEngineInput;
}

/// Output type for ContextEngine phase
@freezed
sealed class ContextEngineOutput with _$ContextEngineOutput {
  const factory ContextEngineOutput({required IList<CoreMessage> prompts}) =
      _ContextEngineOutput;
}

/// Input type for GenerationService phase
@freezed
sealed class GenerationServiceInput with _$GenerationServiceInput {
  const factory GenerationServiceInput({
    required IList<CoreMessage> prompts,
    CancelToken? cancelToken,
    @Default([]) List<ToolSchema> tools,
    Map<String, dynamic>? config,
  }) = _GenerationServiceInput;
}

/// Output type for GenerationService phase
@freezed
sealed class GenerationServiceOutput with _$GenerationServiceOutput {
  const factory GenerationServiceOutput({required GenerationResult result}) =
      _GenerationServiceOutput;
}

/// Input type for PostResponseEngine phase
@freezed
sealed class PostResponseEngineInput with _$PostResponseEngineInput {
  const factory PostResponseEngineInput({
    required QueryContext input,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) = _PostResponseEngineInput;
}
