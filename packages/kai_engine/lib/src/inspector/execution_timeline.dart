/// Role: Represents the complete lifecycle of a single message submission, from
/// the user's input to the final AI response.
///
/// Flow: An instance of this class is created every time the user sends a
/// message. It belongs to a parent `TimelineSession` and contains a list of
/// `TimelinePhase`s that occurred during its processing.
class ExecutionTimeline {}
