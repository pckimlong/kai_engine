import 'package:freezed_annotation/freezed_annotation.dart';

import '../execution_timeline.dart';
import 'timeline_types.dart';

part 'timeline_session.freezed.dart';
part 'timeline_session.g.dart';

/// Role: The main container for an entire conversation.
///
/// Flow: This is the top-level object in the hierarchy. It is created when a
/// new conversation starts and will contain a list of all `ExecutionTimeline`s
/// (one for each user message). It's also used to store aggregate data for the
/// whole conversation, like total token cost.
@freezed
sealed class TimelineSession with _$TimelineSession {
  /// Creates a new TimelineSession.
  const factory TimelineSession({
    /// Unique identifier for this session.
    required String id,

    /// When this session started.
    required DateTime startTime,

    /// When this session ended (null if still active).
    DateTime? endTime,

    /// Current status of the session.
    @Default(TimelineStatus.running) TimelineStatus status,

    /// Additional metadata about the session.
    @Default({}) Map<String, dynamic> metadata,

    /// List of all execution timelines in this session.
    @Default([]) List<ExecutionTimeline> timelines,
  }) = _TimelineSession;

  /// Creates a TimelineSession from JSON.
  factory TimelineSession.fromJson(Map<String, dynamic> json) => _$TimelineSessionFromJson(json);

  const TimelineSession._();

  /// Duration of the session (calculated from start/end times).
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Total number of messages processed in this session.
  int get messageCount => timelines.length;

  /// Total token usage across all timelines in this session.
  int get totalTokenUsage {
    return metadata['totalTokenUsage'] as int? ?? 0;
  }

  /// Total cost across all timelines in this session.
  double get totalCost {
    return metadata['totalCost'] as double? ?? 0.0;
  }

  /// Creates a copy of this session with a new timeline added.
  TimelineSession addTimeline(ExecutionTimeline timeline) {
    return copyWith(timelines: [...timelines, timeline]);
  }

  /// Creates a copy of this session with updated aggregate data.
  TimelineSession updateAggregates({int? tokenUsage, double? cost}) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    if (tokenUsage != null) {
      newMetadata['totalTokenUsage'] = (newMetadata['totalTokenUsage'] as int? ?? 0) + tokenUsage;
    }
    if (cost != null) {
      newMetadata['totalCost'] = (newMetadata['totalCost'] as double? ?? 0.0) + cost;
    }
    return copyWith(metadata: newMetadata);
  }

  /// Creates a copy of this session marked as completed.
  TimelineSession complete({TimelineStatus status = TimelineStatus.completed}) {
    return copyWith(status: status, endTime: DateTime.now());
  }
}
