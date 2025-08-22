import 'package:freezed_annotation/freezed_annotation.dart';

import 'models/timeline_phase.dart';
import 'models/timeline_types.dart';

part 'execution_timeline.freezed.dart';
part 'execution_timeline.g.dart';

/// Role: Represents the complete lifecycle of a single message submission, from
/// the user's input to the final AI response.
///
/// Flow: An instance of this class is created every time the user sends a
/// message. It belongs to a parent `TimelineSession` and contains a list of
/// `TimelinePhase`s that occurred during its processing.
@freezed
sealed class ExecutionTimeline with _$ExecutionTimeline {
  /// Creates a new ExecutionTimeline.
  const factory ExecutionTimeline({
    /// Unique identifier for this timeline.
    required String id,

    /// The user's original message that started this timeline.
    required String userMessage,

    /// When this timeline started.
    required DateTime startTime,

    /// When this timeline completed (null if still running).
    DateTime? endTime,

    /// Current status of the timeline.
    @Default(TimelineStatus.running) TimelineStatus status,

    /// Additional metadata about the timeline.
    @Default({}) Map<String, dynamic> metadata,

    /// List of phases that occurred during this timeline.
    @Default([]) List<TimelinePhase> phases,
  }) = _ExecutionTimeline;

  /// Creates an ExecutionTimeline from JSON.
  factory ExecutionTimeline.fromJson(Map<String, dynamic> json) =>
      _$ExecutionTimelineFromJson(json);

  const ExecutionTimeline._();

  /// Duration of the timeline (calculated from start/end times).
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Creates a copy of this timeline with a new phase added.
  ExecutionTimeline addPhase(TimelinePhase phase) {
    return copyWith(phases: [...phases, phase]);
  }

  /// Creates a copy of this timeline marked as completed.
  ExecutionTimeline complete({TimelineStatus status = TimelineStatus.completed}) {
    return copyWith(status: status, endTime: DateTime.now());
  }
}
