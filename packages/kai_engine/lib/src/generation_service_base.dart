import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/src/models/core_message.dart';
import 'package:kai_engine/src/tool_schema.dart';

import 'models/cancel_token.dart';
import 'models/generation_result.dart';
import 'models/generation_state.dart';

abstract interface class GenerationServiceBase {
  /// Process messages and return a stream of generation states.
  /// Response the generated state of IList[CoreMessage]
  /// In some case like tool calling the response might involve multiple messages steps
  /// This means we need to handle the response and save it accordingly
  Stream<GenerationState<GenerationResult>> stream(
    IList<CoreMessage> prompts, {
    CancelToken? cancelToken,
    List<ToolSchema> tools = const [],
    Map<String, dynamic>? config,
  });

  Future<int> countToken(IList<CoreMessage> prompts);

  Future<String> invoke(IList<CoreMessage> prompts);
}
