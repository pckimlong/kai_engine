/// Role: Represents a granular, timed operation within a `TimelinePhase`.
///
/// Flow: This is the most detailed level of tracking. A step is created by using
/// the `withStep()` helper method inside a `KaiPhase` implementation. It contains
/// detailed metadata and logs specific to that small unit of work.
class TimelineStep {}

/// Role: A single log entry with a message and severity level.
///
/// Flow: These are attached to `TimelinePhase`s or `TimelineStep`s to provide
/// contextual, printf-style information.
class TimelineLog {}
