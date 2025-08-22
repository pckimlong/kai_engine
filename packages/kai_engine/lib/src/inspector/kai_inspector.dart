/// Role: The central Service Contract. This is the main "plug-in point" for the
/// entire inspection system.
///
/// Flow: The ChatController will interact with this abstract class, decoupling the
/// engine from any specific inspector implementation. A developer can provide their
/// own implementation (e.g., for custom storage) or use the default one provided
/// in the `kai_inspector` package.
abstract class KaiInspector {
  // In a full implementation, this would contain method signatures like:
  //
  // Future<void> startSession(String sessionId);
  // void recordTimeline(String sessionId, ExecutionTimeline timeline);
  // Stream<TimelineSession> getSessionStream(String sessionId);
}

/// Role: The default "do-nothing" implementation of the KaiInspector.
///
/// Flow: This class is used by the ChatController when no inspector is provided.
/// It ensures the system is completely disabled by default with zero performance
/// overhead, as its methods will all be empty. This avoids the need for
/// null-checks in the ChatController's logic.
class NoOpKaiInspector implements KaiInspector {}
