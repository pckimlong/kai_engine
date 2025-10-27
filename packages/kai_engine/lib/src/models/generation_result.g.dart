// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GenerationResult _$GenerationResultFromJson(Map<String, dynamic> json) =>
    _GenerationResult(
      requestMessages: IList<CoreMessage>.fromJson(
        json['requestMessages'],
        (value) => CoreMessage.fromJson(value as Map<String, dynamic>),
      ),
      generatedMessages: IList<CoreMessage>.fromJson(
        json['generatedMessages'],
        (value) => CoreMessage.fromJson(value as Map<String, dynamic>),
      ),
      usage: json['usage'] == null
          ? null
          : GenerationUsage.fromJson(json['usage'] as Map<String, dynamic>),
      extensions: json['extensions'] as Map<String, dynamic>?,
      responseText: json['responseText'] as String?,
    );

Map<String, dynamic> _$GenerationResultToJson(_GenerationResult instance) =>
    <String, dynamic>{
      'requestMessages': instance.requestMessages.toJson((value) => value),
      'generatedMessages': instance.generatedMessages.toJson((value) => value),
      'usage': instance.usage,
      'extensions': instance.extensions,
      'responseText': instance.responseText,
    };

_GenerationUsage _$GenerationUsageFromJson(Map<String, dynamic> json) =>
    _GenerationUsage(
      inputToken: (json['inputToken'] as num?)?.toInt(),
      outputToken: (json['outputToken'] as num?)?.toInt(),
      apiCallCount: (json['apiCallCount'] as num?)?.toInt(),
      extensions: json['extensions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GenerationUsageToJson(_GenerationUsage instance) =>
    <String, dynamic>{
      'inputToken': instance.inputToken,
      'outputToken': instance.outputToken,
      'apiCallCount': instance.apiCallCount,
      'extensions': instance.extensions,
    };
