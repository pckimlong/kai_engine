// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_phase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelinePhase _$TimelinePhaseFromJson(Map<String, dynamic> json) =>
    _TimelinePhase(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status:
          $enumDecodeNullable(_$TimelineStatusEnumMap, json['status']) ??
          TimelineStatus.running,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((e) => TimelineStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      logs:
          (json['logs'] as List<dynamic>?)
              ?.map((e) => TimelineLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TimelinePhaseToJson(_TimelinePhase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$TimelineStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'steps': instance.steps,
      'logs': instance.logs,
    };

const _$TimelineStatusEnumMap = {
  TimelineStatus.running: 'running',
  TimelineStatus.completed: 'completed',
  TimelineStatus.failed: 'failed',
};
