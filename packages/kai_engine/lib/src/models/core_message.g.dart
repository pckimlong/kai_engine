// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoreMessage _$CoreMessageFromJson(Map<String, dynamic> json) => _CoreMessage(
  messageId: json['messageId'] as String,
  type: $enumDecode(_$CoreMessageTypeEnumMap, json['type']),
  content: json['content'] as String,
  extensions: json['extensions'] == null
      ? const IMap.empty()
      : IMap<String, dynamic>.fromJson(
          json['extensions'] as Map<String, dynamic>,
          (value) => value as String,
          (value) => value,
        ),
);

Map<String, dynamic> _$CoreMessageToJson(
  _CoreMessage instance,
) => <String, dynamic>{
  'messageId': instance.messageId,
  'type': _$CoreMessageTypeEnumMap[instance.type]!,
  'content': instance.content,
  'extensions': instance.extensions.toJson((value) => value, (value) => value),
};

const _$CoreMessageTypeEnumMap = {
  CoreMessageType.system: 'system',
  CoreMessageType.user: 'user',
  CoreMessageType.ai: 'ai',
  CoreMessageType.function: 'function',
  CoreMessageType.unknown: 'unknown',
};
