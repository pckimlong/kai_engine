import 'package:freezed_annotation/freezed_annotation.dart';

import 'timeline_types.dart';

part 'timeline_step.freezed.dart';
part 'timeline_step.g.dart';

/// Role: Represents a granular, timed operation within a `TimelinePhase`.
///
/// Flow: This is the most detailed level of tracking. A step is created by using
/// the `withStep()` helper method inside a `KaiPhase` implementation. It contains
/// detailed metadata and logs specific to that small unit of work.
@freezed
sealed class TimelineStep with _$TimelineStep {
  /// Creates a new TimelineStep.
  const factory TimelineStep({
    /// Unique identifier for this step.
    required String id,

    /// Human-readable name of the step.
    required String name,

    /// Optional description of what this step does.
    String? description,

    /// When this step started.
    required DateTime startTime,

    /// When this step completed (null if still running).
    DateTime? endTime,

    /// Current status of the step.
    @Default(TimelineStatus.running) TimelineStatus status,

    /// Additional metadata about the step.
    @Default({}) Map<String, dynamic> metadata,

    /// List of logs associated with this step.
    @Default([]) List<TimelineLog> logs,
  }) = _TimelineStep;

  /// Creates a TimelineStep from JSON.
  factory TimelineStep.fromJson(Map<String, dynamic> json) => _$TimelineStepFromJson(json);

  const TimelineStep._();

  /// Duration of the step (calculated from start/end times).
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Creates a copy of this step with a new log entry added.
  TimelineStep addLog(TimelineLog log) {
    return copyWith(logs: [...logs, log]);
  }

  TimelineStep addLogMessage(String message) {
    final log = TimelineLog(message: message, timestamp: DateTime.now());
    return addLog(log);
  }

  /// Creates a copy of this step marked as completed.
  TimelineStep complete({TimelineStatus status = TimelineStatus.completed}) {
    return copyWith(status: status, endTime: DateTime.now());
  }
}
