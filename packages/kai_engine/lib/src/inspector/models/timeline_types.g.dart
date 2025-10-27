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

_PromptMessagesLog _$PromptMessagesLogFromJson(Map<String, dynamic> json) =>
    _PromptMessagesLog(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      promptMessages: (json['promptMessages'] as List<dynamic>)
          .map((e) => CoreMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      severity:
          $enumDecodeNullable(_$TimelineLogSeverityEnumMap, json['severity']) ??
          TimelineLogSeverity.info,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PromptMessagesLogToJson(_PromptMessagesLog instance) =>
    <String, dynamic>{
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'promptMessages': instance.promptMessages,
      'severity': _$TimelineLogSeverityEnumMap[instance.severity]!,
      'metadata': instance.metadata,
    };

_GeneratedMessagesLog _$GeneratedMessagesLogFromJson(
  Map<String, dynamic> json,
) => _GeneratedMessagesLog(
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  generatedMessages: (json['generatedMessages'] as List<dynamic>)
      .map((e) => CoreMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  severity:
      $enumDecodeNullable(_$TimelineLogSeverityEnumMap, json['severity']) ??
      TimelineLogSeverity.info,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$GeneratedMessagesLogToJson(
  _GeneratedMessagesLog instance,
) => <String, dynamic>{
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
  'generatedMessages': instance.generatedMessages,
  'severity': _$TimelineLogSeverityEnumMap[instance.severity]!,
  'metadata': instance.metadata,
};
