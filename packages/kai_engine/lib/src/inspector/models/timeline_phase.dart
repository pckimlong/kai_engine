import 'package:freezed_annotation/freezed_annotation.dart';

import 'timeline_step.dart';
import 'timeline_types.dart';

part 'timeline_phase.freezed.dart';
part 'timeline_phase.g.dart';

/// Role: Represents a major stage within the processing of a single message.
///
/// Flow: This corresponds directly to a `KaiPhase` execution (e.g., "Query
/// Processing" or "AI Generation"). It belongs to a parent `ExecutionTimeline`
/// and contains a list of the granular `TimelineStep`s that occurred within it.
@freezed
sealed class TimelinePhase with _$TimelinePhase {
  /// Creates a new TimelinePhase.
  const factory TimelinePhase({
    /// Unique identifier for this phase.
    required String id,

    /// Human-readable name of the phase.
    required String name,

    /// Optional description of what this phase does.
    String? description,

    /// When this phase started.
    required DateTime startTime,

    /// When this phase completed (null if still running).
    DateTime? endTime,

    /// Current status of the phase.
    @Default(TimelineStatus.running) TimelineStatus status,

    /// Additional metadata about the phase.
    @Default({}) Map<String, dynamic> metadata,

    /// List of steps that occurred within this phase.
    @Default([]) List<TimelineStep> steps,

    /// List of logs associated with this phase.
    @Default([]) List<TimelineLog> logs,

    /// List of prompt messages logs associated with this phase.
    @Default([]) List<PromptMessagesLog> promptMessagesLogs,

    /// List of generated messages logs associated with this phase.
    @Default([]) List<GeneratedMessagesLog> generatedMessagesLogs,
  }) = _TimelinePhase;

  /// Creates a TimelinePhase from JSON.
  factory TimelinePhase.fromJson(Map<String, dynamic> json) =>
      _$TimelinePhaseFromJson(json);

  const TimelinePhase._();

  /// Duration of the phase (calculated from start/end times).
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Creates a copy of this phase with a new step added.
  TimelinePhase addStep(TimelineStep step) {
    return copyWith(steps: [...steps, step]);
  }

  /// Creates a copy of this phase with a new log entry added.
  TimelinePhase addLog(TimelineLog log) {
    return copyWith(logs: [...logs, log]);
  }

  /// Creates a copy of this phase with a new prompt messages log added.
  TimelinePhase addPromptMessagesLog(PromptMessagesLog log) {
    return copyWith(promptMessagesLogs: [...promptMessagesLogs, log]);
  }

  /// Creates a copy of this phase with a new generated messages log added.
  TimelinePhase addGeneratedMessagesLog(GeneratedMessagesLog log) {
    return copyWith(generatedMessagesLogs: [...generatedMessagesLogs, log]);
  }

  /// Creates a copy of this phase marked as completed.
  TimelinePhase complete({TimelineStatus status = TimelineStatus.completed}) {
    return copyWith(status: status, endTime: DateTime.now());
  }
}
