// Run after the response is generated
// we can use this to perform same enhancements on the response
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

import 'inspector/kai_phase.dart';
import 'inspector/phase_types.dart';

abstract class PostResponseEngineBase
    extends KaiPhase<PostResponseEngineInput, PostResponseEngineOutput> {
  @override
  Future<PostResponseEngineOutput> execute(PostResponseEngineInput input) async {
    // Default implementation - do nothing
    return const PostResponseEngineOutput();
  }

  /// Legacy method for backward compatibility - will be removed
  @deprecated
  Future<void> process({
    required QueryContext input,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {
    final phaseInput = PostResponseEngineInput(
      input: input,
      requestMessages: requestMessages,
      result: result,
      conversationManager: conversationManager,
    );

    await execute(phaseInput);
  }
}
