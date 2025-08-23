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

    /// List of nested steps.
    @Default([]) List<TimelineStep> steps,
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

  /// Creates a copy of this step with a new nested step added.
  TimelineStep addStep(TimelineStep step) {
    return copyWith(steps: [...steps, step]);
  }

  TimelineStep addLogMessage(String message, {Map<String, dynamic>? metadata}) {
    final log = TimelineLog(message: message, timestamp: DateTime.now(), metadata: metadata ?? {});
    return addLog(log);
  }

  /// Creates a copy of this step marked as completed.
  TimelineStep complete({TimelineStatus status = TimelineStatus.completed}) {
    return copyWith(status: status, endTime: DateTime.now());
  }
}

/// A wrapper around TimelineStep that provides auto-syncing capabilities
/// when used within a step context that has a phase controller.
class ManagedTimelineStep {
  ManagedTimelineStep(this._step, this._updateCallback);

  TimelineStep _step;
  final Future<void> Function(TimelineStep)? _updateCallback;

  TimelineStep get step => _step;

  String get id => _step.id;
  String get name => _step.name;
  String? get description => _step.description;
  DateTime get startTime => _step.startTime;
  DateTime? get endTime => _step.endTime;
  TimelineStatus get status => _step.status;
  Map<String, dynamic> get metadata => _step.metadata;
  List<TimelineLog> get logs => _step.logs;
  List<TimelineStep> get steps => _step.steps;
  Duration? get duration => _step.duration;

  /// Adds a log message and automatically syncs with the phase controller
  Future<void> addLogMessage(String message, {Map<String, dynamic>? metadata}) async {
    final log = TimelineLog(message: message, timestamp: DateTime.now(), metadata: metadata ?? {});
    _step = _step.addLog(log);
    if (_updateCallback != null) {
      await _updateCallback(_step);
    }
  }

  /// Adds a log and automatically syncs with the phase controller
  Future<void> addLog(TimelineLog log) async {
    _step = _step.addLog(log);
    if (_updateCallback != null) {
      await _updateCallback(_step);
    }
  }

  /// Adds a nested step and automatically syncs with the phase controller
  Future<void> addStep(TimelineStep step) async {
    _step = _step.addStep(step);
    if (_updateCallback != null) {
      await _updateCallback(_step);
    }
  }
}
