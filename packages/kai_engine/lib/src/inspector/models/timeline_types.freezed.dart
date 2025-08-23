// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimelineLog {

/// The log message.
 String get message;/// When this log was created.
 DateTime get timestamp;/// Severity level of the log.
 TimelineLogSeverity get severity;/// Additional metadata about the log.
 Map<String, dynamic> get metadata;
/// Create a copy of TimelineLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineLogCopyWith<TimelineLog> get copyWith => _$TimelineLogCopyWithImpl<TimelineLog>(this as TimelineLog, _$identity);

  /// Serializes this TimelineLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,severity,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'TimelineLog(message: $message, timestamp: $timestamp, severity: $severity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $TimelineLogCopyWith<$Res>  {
  factory $TimelineLogCopyWith(TimelineLog value, $Res Function(TimelineLog) _then) = _$TimelineLogCopyWithImpl;
@useResult
$Res call({
 String message, DateTime timestamp, TimelineLogSeverity severity, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$TimelineLogCopyWithImpl<$Res>
    implements $TimelineLogCopyWith<$Res> {
  _$TimelineLogCopyWithImpl(this._self, this._then);

  final TimelineLog _self;
  final $Res Function(TimelineLog) _then;

/// Create a copy of TimelineLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? timestamp = null,Object? severity = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as TimelineLogSeverity,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineLog].
extension TimelineLogPatterns on TimelineLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineLog value)  $default,){
final _that = this;
switch (_that) {
case _TimelineLog():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineLog value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.severity,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _TimelineLog():
return $default(_that.message,_that.timestamp,_that.severity,_that.metadata);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  DateTime timestamp,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _TimelineLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.severity,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineLog implements TimelineLog {
  const _TimelineLog({required this.message, required this.timestamp, this.severity = TimelineLogSeverity.info, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata;
  factory _TimelineLog.fromJson(Map<String, dynamic> json) => _$TimelineLogFromJson(json);

/// The log message.
@override final  String message;
/// When this log was created.
@override final  DateTime timestamp;
/// Severity level of the log.
@override@JsonKey() final  TimelineLogSeverity severity;
/// Additional metadata about the log.
 final  Map<String, dynamic> _metadata;
/// Additional metadata about the log.
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of TimelineLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineLogCopyWith<_TimelineLog> get copyWith => __$TimelineLogCopyWithImpl<_TimelineLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,severity,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'TimelineLog(message: $message, timestamp: $timestamp, severity: $severity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$TimelineLogCopyWith<$Res> implements $TimelineLogCopyWith<$Res> {
  factory _$TimelineLogCopyWith(_TimelineLog value, $Res Function(_TimelineLog) _then) = __$TimelineLogCopyWithImpl;
@override @useResult
$Res call({
 String message, DateTime timestamp, TimelineLogSeverity severity, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$TimelineLogCopyWithImpl<$Res>
    implements _$TimelineLogCopyWith<$Res> {
  __$TimelineLogCopyWithImpl(this._self, this._then);

  final _TimelineLog _self;
  final $Res Function(_TimelineLog) _then;

/// Create a copy of TimelineLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? timestamp = null,Object? severity = null,Object? metadata = null,}) {
  return _then(_TimelineLog(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as TimelineLogSeverity,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$PromptMessagesLog {

/// The log message.
 String get message;/// When this log was created.
 DateTime get timestamp;/// The actual CoreMessage objects sent as prompts.
 List<CoreMessage> get promptMessages;/// Severity level of the log.
 TimelineLogSeverity get severity;/// Additional metadata about the log (for auxiliary data only).
 Map<String, dynamic> get metadata;
/// Create a copy of PromptMessagesLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromptMessagesLogCopyWith<PromptMessagesLog> get copyWith => _$PromptMessagesLogCopyWithImpl<PromptMessagesLog>(this as PromptMessagesLog, _$identity);

  /// Serializes this PromptMessagesLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromptMessagesLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.promptMessages, promptMessages)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,const DeepCollectionEquality().hash(promptMessages),severity,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'PromptMessagesLog(message: $message, timestamp: $timestamp, promptMessages: $promptMessages, severity: $severity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PromptMessagesLogCopyWith<$Res>  {
  factory $PromptMessagesLogCopyWith(PromptMessagesLog value, $Res Function(PromptMessagesLog) _then) = _$PromptMessagesLogCopyWithImpl;
@useResult
$Res call({
 String message, DateTime timestamp, List<CoreMessage> promptMessages, TimelineLogSeverity severity, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$PromptMessagesLogCopyWithImpl<$Res>
    implements $PromptMessagesLogCopyWith<$Res> {
  _$PromptMessagesLogCopyWithImpl(this._self, this._then);

  final PromptMessagesLog _self;
  final $Res Function(PromptMessagesLog) _then;

/// Create a copy of PromptMessagesLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? timestamp = null,Object? promptMessages = null,Object? severity = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,promptMessages: null == promptMessages ? _self.promptMessages : promptMessages // ignore: cast_nullable_to_non_nullable
as List<CoreMessage>,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as TimelineLogSeverity,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PromptMessagesLog].
extension PromptMessagesLogPatterns on PromptMessagesLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromptMessagesLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromptMessagesLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromptMessagesLog value)  $default,){
final _that = this;
switch (_that) {
case _PromptMessagesLog():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromptMessagesLog value)?  $default,){
final _that = this;
switch (_that) {
case _PromptMessagesLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  List<CoreMessage> promptMessages,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromptMessagesLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.promptMessages,_that.severity,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  List<CoreMessage> promptMessages,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _PromptMessagesLog():
return $default(_that.message,_that.timestamp,_that.promptMessages,_that.severity,_that.metadata);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  DateTime timestamp,  List<CoreMessage> promptMessages,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _PromptMessagesLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.promptMessages,_that.severity,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromptMessagesLog implements PromptMessagesLog {
  const _PromptMessagesLog({required this.message, required this.timestamp, required final  List<CoreMessage> promptMessages, this.severity = TimelineLogSeverity.info, final  Map<String, dynamic> metadata = const {}}): _promptMessages = promptMessages,_metadata = metadata;
  factory _PromptMessagesLog.fromJson(Map<String, dynamic> json) => _$PromptMessagesLogFromJson(json);

/// The log message.
@override final  String message;
/// When this log was created.
@override final  DateTime timestamp;
/// The actual CoreMessage objects sent as prompts.
 final  List<CoreMessage> _promptMessages;
/// The actual CoreMessage objects sent as prompts.
@override List<CoreMessage> get promptMessages {
  if (_promptMessages is EqualUnmodifiableListView) return _promptMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_promptMessages);
}

/// Severity level of the log.
@override@JsonKey() final  TimelineLogSeverity severity;
/// Additional metadata about the log (for auxiliary data only).
 final  Map<String, dynamic> _metadata;
/// Additional metadata about the log (for auxiliary data only).
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of PromptMessagesLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromptMessagesLogCopyWith<_PromptMessagesLog> get copyWith => __$PromptMessagesLogCopyWithImpl<_PromptMessagesLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromptMessagesLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromptMessagesLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._promptMessages, _promptMessages)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,const DeepCollectionEquality().hash(_promptMessages),severity,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PromptMessagesLog(message: $message, timestamp: $timestamp, promptMessages: $promptMessages, severity: $severity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PromptMessagesLogCopyWith<$Res> implements $PromptMessagesLogCopyWith<$Res> {
  factory _$PromptMessagesLogCopyWith(_PromptMessagesLog value, $Res Function(_PromptMessagesLog) _then) = __$PromptMessagesLogCopyWithImpl;
@override @useResult
$Res call({
 String message, DateTime timestamp, List<CoreMessage> promptMessages, TimelineLogSeverity severity, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$PromptMessagesLogCopyWithImpl<$Res>
    implements _$PromptMessagesLogCopyWith<$Res> {
  __$PromptMessagesLogCopyWithImpl(this._self, this._then);

  final _PromptMessagesLog _self;
  final $Res Function(_PromptMessagesLog) _then;

/// Create a copy of PromptMessagesLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? timestamp = null,Object? promptMessages = null,Object? severity = null,Object? metadata = null,}) {
  return _then(_PromptMessagesLog(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,promptMessages: null == promptMessages ? _self._promptMessages : promptMessages // ignore: cast_nullable_to_non_nullable
as List<CoreMessage>,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as TimelineLogSeverity,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$GeneratedMessagesLog {

/// The log message.
 String get message;/// When this log was created.
 DateTime get timestamp;/// The actual CoreMessage objects generated by AI.
 List<CoreMessage> get generatedMessages;/// Severity level of the log.
 TimelineLogSeverity get severity;/// Additional metadata about the log (for auxiliary data only).
 Map<String, dynamic> get metadata;
/// Create a copy of GeneratedMessagesLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedMessagesLogCopyWith<GeneratedMessagesLog> get copyWith => _$GeneratedMessagesLogCopyWithImpl<GeneratedMessagesLog>(this as GeneratedMessagesLog, _$identity);

  /// Serializes this GeneratedMessagesLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedMessagesLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.generatedMessages, generatedMessages)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,const DeepCollectionEquality().hash(generatedMessages),severity,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'GeneratedMessagesLog(message: $message, timestamp: $timestamp, generatedMessages: $generatedMessages, severity: $severity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $GeneratedMessagesLogCopyWith<$Res>  {
  factory $GeneratedMessagesLogCopyWith(GeneratedMessagesLog value, $Res Function(GeneratedMessagesLog) _then) = _$GeneratedMessagesLogCopyWithImpl;
@useResult
$Res call({
 String message, DateTime timestamp, List<CoreMessage> generatedMessages, TimelineLogSeverity severity, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$GeneratedMessagesLogCopyWithImpl<$Res>
    implements $GeneratedMessagesLogCopyWith<$Res> {
  _$GeneratedMessagesLogCopyWithImpl(this._self, this._then);

  final GeneratedMessagesLog _self;
  final $Res Function(GeneratedMessagesLog) _then;

/// Create a copy of GeneratedMessagesLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? timestamp = null,Object? generatedMessages = null,Object? severity = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,generatedMessages: null == generatedMessages ? _self.generatedMessages : generatedMessages // ignore: cast_nullable_to_non_nullable
as List<CoreMessage>,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as TimelineLogSeverity,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedMessagesLog].
extension GeneratedMessagesLogPatterns on GeneratedMessagesLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedMessagesLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedMessagesLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedMessagesLog value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedMessagesLog():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedMessagesLog value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedMessagesLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  List<CoreMessage> generatedMessages,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedMessagesLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.generatedMessages,_that.severity,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  DateTime timestamp,  List<CoreMessage> generatedMessages,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _GeneratedMessagesLog():
return $default(_that.message,_that.timestamp,_that.generatedMessages,_that.severity,_that.metadata);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  DateTime timestamp,  List<CoreMessage> generatedMessages,  TimelineLogSeverity severity,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedMessagesLog() when $default != null:
return $default(_that.message,_that.timestamp,_that.generatedMessages,_that.severity,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeneratedMessagesLog implements GeneratedMessagesLog {
  const _GeneratedMessagesLog({required this.message, required this.timestamp, required final  List<CoreMessage> generatedMessages, this.severity = TimelineLogSeverity.info, final  Map<String, dynamic> metadata = const {}}): _generatedMessages = generatedMessages,_metadata = metadata;
  factory _GeneratedMessagesLog.fromJson(Map<String, dynamic> json) => _$GeneratedMessagesLogFromJson(json);

/// The log message.
@override final  String message;
/// When this log was created.
@override final  DateTime timestamp;
/// The actual CoreMessage objects generated by AI.
 final  List<CoreMessage> _generatedMessages;
/// The actual CoreMessage objects generated by AI.
@override List<CoreMessage> get generatedMessages {
  if (_generatedMessages is EqualUnmodifiableListView) return _generatedMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_generatedMessages);
}

/// Severity level of the log.
@override@JsonKey() final  TimelineLogSeverity severity;
/// Additional metadata about the log (for auxiliary data only).
 final  Map<String, dynamic> _metadata;
/// Additional metadata about the log (for auxiliary data only).
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of GeneratedMessagesLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedMessagesLogCopyWith<_GeneratedMessagesLog> get copyWith => __$GeneratedMessagesLogCopyWithImpl<_GeneratedMessagesLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeneratedMessagesLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedMessagesLog&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._generatedMessages, _generatedMessages)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,timestamp,const DeepCollectionEquality().hash(_generatedMessages),severity,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'GeneratedMessagesLog(message: $message, timestamp: $timestamp, generatedMessages: $generatedMessages, severity: $severity, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$GeneratedMessagesLogCopyWith<$Res> implements $GeneratedMessagesLogCopyWith<$Res> {
  factory _$GeneratedMessagesLogCopyWith(_GeneratedMessagesLog value, $Res Function(_GeneratedMessagesLog) _then) = __$GeneratedMessagesLogCopyWithImpl;
@override @useResult
$Res call({
 String message, DateTime timestamp, List<CoreMessage> generatedMessages, TimelineLogSeverity severity, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$GeneratedMessagesLogCopyWithImpl<$Res>
    implements _$GeneratedMessagesLogCopyWith<$Res> {
  __$GeneratedMessagesLogCopyWithImpl(this._self, this._then);

  final _GeneratedMessagesLog _self;
  final $Res Function(_GeneratedMessagesLog) _then;

/// Create a copy of GeneratedMessagesLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? timestamp = null,Object? generatedMessages = null,Object? severity = null,Object? metadata = null,}) {
  return _then(_GeneratedMessagesLog(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,generatedMessages: null == generatedMessages ? _self._generatedMessages : generatedMessages // ignore: cast_nullable_to_non_nullable
as List<CoreMessage>,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as TimelineLogSeverity,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
