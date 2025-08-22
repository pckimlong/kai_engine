// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'execution_timeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExecutionTimeline {

/// Unique identifier for this timeline.
 String get id;/// The user's original message that started this timeline.
 String get userMessage;/// When this timeline started.
 DateTime get startTime;/// When this timeline completed (null if still running).
 DateTime? get endTime;/// Current status of the timeline.
 TimelineStatus get status;/// Additional metadata about the timeline.
 Map<String, dynamic> get metadata;/// List of phases that occurred during this timeline.
 List<TimelinePhase> get phases;
/// Create a copy of ExecutionTimeline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExecutionTimelineCopyWith<ExecutionTimeline> get copyWith => _$ExecutionTimelineCopyWithImpl<ExecutionTimeline>(this as ExecutionTimeline, _$identity);

  /// Serializes this ExecutionTimeline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExecutionTimeline&&(identical(other.id, id) || other.id == id)&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.phases, phases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userMessage,startTime,endTime,status,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(phases));

@override
String toString() {
  return 'ExecutionTimeline(id: $id, userMessage: $userMessage, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, phases: $phases)';
}


}

/// @nodoc
abstract mixin class $ExecutionTimelineCopyWith<$Res>  {
  factory $ExecutionTimelineCopyWith(ExecutionTimeline value, $Res Function(ExecutionTimeline) _then) = _$ExecutionTimelineCopyWithImpl;
@useResult
$Res call({
 String id, String userMessage, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<TimelinePhase> phases
});




}
/// @nodoc
class _$ExecutionTimelineCopyWithImpl<$Res>
    implements $ExecutionTimelineCopyWith<$Res> {
  _$ExecutionTimelineCopyWithImpl(this._self, this._then);

  final ExecutionTimeline _self;
  final $Res Function(ExecutionTimeline) _then;

/// Create a copy of ExecutionTimeline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userMessage = null,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? phases = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,phases: null == phases ? _self.phases : phases // ignore: cast_nullable_to_non_nullable
as List<TimelinePhase>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExecutionTimeline].
extension ExecutionTimelinePatterns on ExecutionTimeline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExecutionTimeline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExecutionTimeline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExecutionTimeline value)  $default,){
final _that = this;
switch (_that) {
case _ExecutionTimeline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExecutionTimeline value)?  $default,){
final _that = this;
switch (_that) {
case _ExecutionTimeline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userMessage,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelinePhase> phases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExecutionTimeline() when $default != null:
return $default(_that.id,_that.userMessage,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.phases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userMessage,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelinePhase> phases)  $default,) {final _that = this;
switch (_that) {
case _ExecutionTimeline():
return $default(_that.id,_that.userMessage,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.phases);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userMessage,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelinePhase> phases)?  $default,) {final _that = this;
switch (_that) {
case _ExecutionTimeline() when $default != null:
return $default(_that.id,_that.userMessage,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.phases);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExecutionTimeline extends ExecutionTimeline {
  const _ExecutionTimeline({required this.id, required this.userMessage, required this.startTime, this.endTime, this.status = TimelineStatus.running, final  Map<String, dynamic> metadata = const {}, final  List<TimelinePhase> phases = const []}): _metadata = metadata,_phases = phases,super._();
  factory _ExecutionTimeline.fromJson(Map<String, dynamic> json) => _$ExecutionTimelineFromJson(json);

/// Unique identifier for this timeline.
@override final  String id;
/// The user's original message that started this timeline.
@override final  String userMessage;
/// When this timeline started.
@override final  DateTime startTime;
/// When this timeline completed (null if still running).
@override final  DateTime? endTime;
/// Current status of the timeline.
@override@JsonKey() final  TimelineStatus status;
/// Additional metadata about the timeline.
 final  Map<String, dynamic> _metadata;
/// Additional metadata about the timeline.
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

/// List of phases that occurred during this timeline.
 final  List<TimelinePhase> _phases;
/// List of phases that occurred during this timeline.
@override@JsonKey() List<TimelinePhase> get phases {
  if (_phases is EqualUnmodifiableListView) return _phases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_phases);
}


/// Create a copy of ExecutionTimeline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExecutionTimelineCopyWith<_ExecutionTimeline> get copyWith => __$ExecutionTimelineCopyWithImpl<_ExecutionTimeline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExecutionTimelineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExecutionTimeline&&(identical(other.id, id) || other.id == id)&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._phases, _phases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userMessage,startTime,endTime,status,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_phases));

@override
String toString() {
  return 'ExecutionTimeline(id: $id, userMessage: $userMessage, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, phases: $phases)';
}


}

/// @nodoc
abstract mixin class _$ExecutionTimelineCopyWith<$Res> implements $ExecutionTimelineCopyWith<$Res> {
  factory _$ExecutionTimelineCopyWith(_ExecutionTimeline value, $Res Function(_ExecutionTimeline) _then) = __$ExecutionTimelineCopyWithImpl;
@override @useResult
$Res call({
 String id, String userMessage, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<TimelinePhase> phases
});




}
/// @nodoc
class __$ExecutionTimelineCopyWithImpl<$Res>
    implements _$ExecutionTimelineCopyWith<$Res> {
  __$ExecutionTimelineCopyWithImpl(this._self, this._then);

  final _ExecutionTimeline _self;
  final $Res Function(_ExecutionTimeline) _then;

/// Create a copy of ExecutionTimeline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userMessage = null,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? phases = null,}) {
  return _then(_ExecutionTimeline(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,phases: null == phases ? _self._phases : phases // ignore: cast_nullable_to_non_nullable
as List<TimelinePhase>,
  ));
}


}

// dart format on
