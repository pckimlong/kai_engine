// Run after the response is generated
// we can use this to perform same enhancements on the response
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

interface class PostResponseEngine {
  /// Process post-response actions
  /// This should run before save to database
  /// [requestPrompts] is the request to AI include the input but not include the response
  /// [result] are the generated responses from the AI after process [requestPrompts]
  Future<void> process({
    required QueryContext input,
    required IList<CoreMessage> requestPrompts,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {
    // DO Nothings by default
  }
}
