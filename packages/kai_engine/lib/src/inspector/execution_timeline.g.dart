// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution_timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExecutionTimeline _$ExecutionTimelineFromJson(Map<String, dynamic> json) =>
    _ExecutionTimeline(
      id: json['id'] as String,
      userMessage: json['userMessage'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status:
          $enumDecodeNullable(_$TimelineStatusEnumMap, json['status']) ??
          TimelineStatus.running,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      phases:
          (json['phases'] as List<dynamic>?)
              ?.map((e) => TimelinePhase.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExecutionTimelineToJson(_ExecutionTimeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userMessage': instance.userMessage,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$TimelineStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'phases': instance.phases,
    };

const _$TimelineStatusEnumMap = {
  TimelineStatus.running: 'running',
  TimelineStatus.completed: 'completed',
  TimelineStatus.failed: 'failed',
};
