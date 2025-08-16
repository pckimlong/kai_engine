// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_schema_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestToolCall _$TestToolCallFromJson(Map<String, dynamic> json) =>
    _TestToolCall(
      query: json['query'] as String,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$TestToolCallToJson(_TestToolCall instance) =>
    <String, dynamic>{'query': instance.query, 'limit': instance.limit};
