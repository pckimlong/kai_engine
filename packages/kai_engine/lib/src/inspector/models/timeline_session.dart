/// The status of a timeline, phase, or step.
enum TimelineStatus { running, completed, failed }

/// A common interface for nodes in the timeline tree (Phases and Steps)
/// to allow for polymorphic handling in the UI.
abstract class TimelineNode {
  // String get name;
  // String? get description;
  // DateTime get startTime;
  // DateTime? get endTime;
  // TimelineStatus get status;
  // Map<String, dynamic> get metadata;
  // List<TimelineLog> get logs;
  // Duration? get duration;
}

/// Role: The main container for an entire conversation.
///
/// Flow: This is the top-level object in the hierarchy. It is created when a
/// new conversation starts and will contain a list of all `ExecutionTimeline`s
/// (one for each user message). It's also used to store aggregate data for the
/// whole conversation, like total token cost.
class TimelineSession {}