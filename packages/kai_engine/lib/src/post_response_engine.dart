// Run after the response is generated
// we can use this to perform same enhancements on the response
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'conversation_manager.dart';
import 'models/core_message.dart';
import 'models/generation_result.dart';

class PostResponseEngine {
  /// Process post-response actions
  /// This should run before save to database
  /// [prompt] is the request which has feature to transform to content
  /// [responses] are the generated responses from the AI
  Future<void> process({
    required IList<CoreMessage> prompts,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {}
}
