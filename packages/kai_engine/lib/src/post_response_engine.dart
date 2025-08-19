// Run after the response is generated
// we can use this to perform same enhancements on the response
import 'package:kai_engine/kai_engine.dart';

interface class PostResponseEngine {
  /// Process post-response actions
  /// This should run before save to database
  /// [result] are the generated responses from the AI after process
  /// [input] is the original query context
  /// [conversationManager] is the conversation manager for the current session, to access conversation state use [conversationManager.getMessages()]
  Future<void> process({
    required QueryContext input,
    required GenerationResult result,
    required ConversationManager conversationManager,
  }) async {
    // DO Nothings by default
  }
}
