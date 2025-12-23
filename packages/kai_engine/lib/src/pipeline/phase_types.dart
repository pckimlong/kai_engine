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
    required IList<CoreMessage> histories,
  }) = _QueryEngineInput;
}

/// Input type for ContextEngine phase
@freezed
sealed class ContextEngineInput with _$ContextEngineInput {
  const factory ContextEngineInput({
    required QueryContext inputQuery,
    required IList<CoreMessage> conversationMessages,
    required CoreMessage? providedUserMessage,
  }) = _ContextEngineInput;
}

/// Output type for ContextEngine phase
@freezed
sealed class ContextEngineOutput with _$ContextEngineOutput {
  const factory ContextEngineOutput({
    /// Final user message after applying any `PromptTemplate.input(revision: ...)` logic.
    required CoreMessage userMessage,

    /// The final prompts to send to the generation service.
    required IList<CoreMessage> prompts,
  }) = _ContextEngineOutput;
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
  const PostResponseEngineInput._();

  const factory PostResponseEngineInput({
    required QueryContext input,

    /// The last user message which trigger this generation
    /// it differs from requestMessages which include all the message
    required String initialRequestMessageId,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) = _PostResponseEngineInput;

  /// Return the new requested message from the user input to the end
  IList<CoreMessage> get newRequestMessages {
    // identity user input message position
    final inputIndex = requestMessages.lastIndexWhere(
      (m) => m.type == CoreMessageType.user && m.messageId == initialRequestMessageId.trim(),
    );
    return requestMessages.sublist(inputIndex);
  }
}
