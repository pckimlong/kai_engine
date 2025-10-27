// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelineSession _$TimelineSessionFromJson(Map<String, dynamic> json) =>
    _TimelineSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status:
          $enumDecodeNullable(_$TimelineStatusEnumMap, json['status']) ??
          TimelineStatus.running,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      timelines:
          (json['timelines'] as List<dynamic>?)
              ?.map(
                (e) => ExecutionTimeline.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TimelineSessionToJson(_TimelineSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$TimelineStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'timelines': instance.timelines,
    };

const _$TimelineStatusEnumMap = {
  TimelineStatus.running: 'running',
  TimelineStatus.completed: 'completed',
  TimelineStatus.failed: 'failed',
};
