import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_types.freezed.dart';
part 'timeline_types.g.dart';

/// Common types and enums used across the inspector timeline models.

/// The status of a timeline, phase, or step.
enum TimelineStatus { running, completed, failed }

/// Severity levels for timeline logs.
enum TimelineLogSeverity { debug, info, warning, error }

/// Role: A single log entry with a message and severity level.
///
/// Flow: These are attached to `TimelinePhase`s or `TimelineStep`s to provide
/// contextual, printf-style information.
@freezed
sealed class TimelineLog with _$TimelineLog {
  /// Creates a new TimelineLog.
  const factory TimelineLog({
    /// The log message.
    required String message,

    /// When this log was created.
    required DateTime timestamp,

    /// Severity level of the log.
    @Default(TimelineLogSeverity.info) TimelineLogSeverity severity,

    /// Additional metadata about the log.
    @Default({}) Map<String, dynamic> metadata,
  }) = _TimelineLog;

  /// Creates a TimelineLog from JSON.
  factory TimelineLog.fromJson(Map<String, dynamic> json) => _$TimelineLogFromJson(json);
}
