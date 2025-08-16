// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_extensions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GenerationUsage _$GenerationUsageFromJson(Map<String, dynamic> json) =>
    _GenerationUsage(
      inputToken: (json['inputToken'] as num?)?.toInt(),
      outputToken: (json['outputToken'] as num?)?.toInt(),
      apiCallCount: (json['apiCallCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GenerationUsageToJson(_GenerationUsage instance) =>
    <String, dynamic>{
      'inputToken': instance.inputToken,
      'outputToken': instance.outputToken,
      'apiCallCount': instance.apiCallCount,
    };
