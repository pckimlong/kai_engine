// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelineLog _$TimelineLogFromJson(Map<String, dynamic> json) => _TimelineLog(
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  severity:
      $enumDecodeNullable(_$TimelineLogSeverityEnumMap, json['severity']) ??
      TimelineLogSeverity.info,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$TimelineLogToJson(_TimelineLog instance) =>
    <String, dynamic>{
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'severity': _$TimelineLogSeverityEnumMap[instance.severity]!,
      'metadata': instance.metadata,
    };

const _$TimelineLogSeverityEnumMap = {
  TimelineLogSeverity.debug: 'debug',
  TimelineLogSeverity.info: 'info',
  TimelineLogSeverity.warning: 'warning',
  TimelineLogSeverity.error: 'error',
};
