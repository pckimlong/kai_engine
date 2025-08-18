// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoreMessage _$CoreMessageFromJson(Map<String, dynamic> json) => _CoreMessage(
  messageId: json['messageId'] as String,
  type: $enumDecode(_$CoreMessageTypeEnumMap, json['type']),
  content: json['content'] as String,
  isBackgroundContext: json['isBackgroundContext'] as bool? ?? false,
  timestamp: DateTime.parse(json['timestamp'] as String),
  extensions:
      json['extensions'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$CoreMessageToJson(_CoreMessage instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'type': _$CoreMessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'isBackgroundContext': instance.isBackgroundContext,
      'timestamp': instance.timestamp.toIso8601String(),
      'extensions': instance.extensions,
    };

const _$CoreMessageTypeEnumMap = {
  CoreMessageType.system: 'system',
  CoreMessageType.user: 'user',
  CoreMessageType.ai: 'ai',
  CoreMessageType.function: 'function',
  CoreMessageType.unknown: 'unknown',
};
