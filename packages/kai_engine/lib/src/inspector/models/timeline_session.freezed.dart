// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimelineSession {

/// Unique identifier for this session.
 String get id;/// When this session started.
 DateTime get startTime;/// When this session ended (null if still active).
 DateTime? get endTime;/// Current status of the session.
 TimelineStatus get status;/// Additional metadata about the session.
 Map<String, dynamic> get metadata;/// List of all execution timelines in this session.
 List<ExecutionTimeline> get timelines;
/// Create a copy of TimelineSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineSessionCopyWith<TimelineSession> get copyWith => _$TimelineSessionCopyWithImpl<TimelineSession>(this as TimelineSession, _$identity);

  /// Serializes this TimelineSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.timelines, timelines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,status,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(timelines));

@override
String toString() {
  return 'TimelineSession(id: $id, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, timelines: $timelines)';
}


}

/// @nodoc
abstract mixin class $TimelineSessionCopyWith<$Res>  {
  factory $TimelineSessionCopyWith(TimelineSession value, $Res Function(TimelineSession) _then) = _$TimelineSessionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<ExecutionTimeline> timelines
});




}
/// @nodoc
class _$TimelineSessionCopyWithImpl<$Res>
    implements $TimelineSessionCopyWith<$Res> {
  _$TimelineSessionCopyWithImpl(this._self, this._then);

  final TimelineSession _self;
  final $Res Function(TimelineSession) _then;

/// Create a copy of TimelineSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? timelines = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,timelines: null == timelines ? _self.timelines : timelines // ignore: cast_nullable_to_non_nullable
as List<ExecutionTimeline>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineSession].
extension TimelineSessionPatterns on TimelineSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineSession value)  $default,){
final _that = this;
switch (_that) {
case _TimelineSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineSession value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<ExecutionTimeline> timelines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineSession() when $default != null:
return $default(_that.id,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.timelines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<ExecutionTimeline> timelines)  $default,) {final _that = this;
switch (_that) {
case _TimelineSession():
return $default(_that.id,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.timelines);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<ExecutionTimeline> timelines)?  $default,) {final _that = this;
switch (_that) {
case _TimelineSession() when $default != null:
return $default(_that.id,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.timelines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineSession extends TimelineSession {
  const _TimelineSession({required this.id, required this.startTime, this.endTime, this.status = TimelineStatus.running, final  Map<String, dynamic> metadata = const {}, final  List<ExecutionTimeline> timelines = const []}): _metadata = metadata,_timelines = timelines,super._();
  factory _TimelineSession.fromJson(Map<String, dynamic> json) => _$TimelineSessionFromJson(json);

/// Unique identifier for this session.
@override final  String id;
/// When this session started.
@override final  DateTime startTime;
/// When this session ended (null if still active).
@override final  DateTime? endTime;
/// Current status of the session.
@override@JsonKey() final  TimelineStatus status;
/// Additional metadata about the session.
 final  Map<String, dynamic> _metadata;
/// Additional metadata about the session.
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

/// List of all execution timelines in this session.
 final  List<ExecutionTimeline> _timelines;
/// List of all execution timelines in this session.
@override@JsonKey() List<ExecutionTimeline> get timelines {
  if (_timelines is EqualUnmodifiableListView) return _timelines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timelines);
}


/// Create a copy of TimelineSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineSessionCopyWith<_TimelineSession> get copyWith => __$TimelineSessionCopyWithImpl<_TimelineSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._timelines, _timelines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,status,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_timelines));

@override
String toString() {
  return 'TimelineSession(id: $id, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, timelines: $timelines)';
}


}

/// @nodoc
abstract mixin class _$TimelineSessionCopyWith<$Res> implements $TimelineSessionCopyWith<$Res> {
  factory _$TimelineSessionCopyWith(_TimelineSession value, $Res Function(_TimelineSession) _then) = __$TimelineSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<ExecutionTimeline> timelines
});




}
/// @nodoc
class __$TimelineSessionCopyWithImpl<$Res>
    implements _$TimelineSessionCopyWith<$Res> {
  __$TimelineSessionCopyWithImpl(this._self, this._then);

  final _TimelineSession _self;
  final $Res Function(_TimelineSession) _then;

/// Create a copy of TimelineSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? timelines = null,}) {
  return _then(_TimelineSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,timelines: null == timelines ? _self._timelines : timelines // ignore: cast_nullable_to_non_nullable
as List<ExecutionTimeline>,
  ));
}


}

// dart format on
