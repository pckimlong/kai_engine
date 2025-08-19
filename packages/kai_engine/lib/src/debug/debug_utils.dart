import 'debug_data.dart';
import 'debug_tracker.dart';

/// Easy access utilities
class KaiDebug {
  static MessageDebugInfo? getMessageInfo(String messageId) {
    return KaiDebugTracker.instance.getMessageDebugInfo(messageId);
  }

  static List<MessageDebugInfo> getRecentMessages({int limit = 20}) {
    return KaiDebugTracker.instance.getRecentMessages(limit: limit);
  }

  static Stream<MessageDebugInfo> get stream => KaiDebugTracker.instance.debugInfoStream;
}