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

// dart format on
