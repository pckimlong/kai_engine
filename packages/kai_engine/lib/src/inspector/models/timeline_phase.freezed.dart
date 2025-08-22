// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_phase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimelinePhase {

/// Unique identifier for this phase.
 String get id;/// Human-readable name of the phase.
 String get name;/// Optional description of what this phase does.
 String? get description;/// When this phase started.
 DateTime get startTime;/// When this phase completed (null if still running).
 DateTime? get endTime;/// Current status of the phase.
 TimelineStatus get status;/// Additional metadata about the phase.
 Map<String, dynamic> get metadata;/// List of steps that occurred within this phase.
 List<TimelineStep> get steps;/// List of logs associated with this phase.
 List<TimelineLog> get logs;
/// Create a copy of TimelinePhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelinePhaseCopyWith<TimelinePhase> get copyWith => _$TimelinePhaseCopyWithImpl<TimelinePhase>(this as TimelinePhase, _$identity);

  /// Serializes this TimelinePhase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelinePhase&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.steps, steps)&&const DeepCollectionEquality().equals(other.logs, logs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,startTime,endTime,status,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(steps),const DeepCollectionEquality().hash(logs));

@override
String toString() {
  return 'TimelinePhase(id: $id, name: $name, description: $description, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, steps: $steps, logs: $logs)';
}


}

/// @nodoc
abstract mixin class $TimelinePhaseCopyWith<$Res>  {
  factory $TimelinePhaseCopyWith(TimelinePhase value, $Res Function(TimelinePhase) _then) = _$TimelinePhaseCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<TimelineStep> steps, List<TimelineLog> logs
});




}
/// @nodoc
class _$TimelinePhaseCopyWithImpl<$Res>
    implements $TimelinePhaseCopyWith<$Res> {
  _$TimelinePhaseCopyWithImpl(this._self, this._then);

  final TimelinePhase _self;
  final $Res Function(TimelinePhase) _then;

/// Create a copy of TimelinePhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? steps = null,Object? logs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<TimelineStep>,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<TimelineLog>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelinePhase].
extension TimelinePhasePatterns on TimelinePhase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelinePhase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelinePhase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelinePhase value)  $default,){
final _that = this;
switch (_that) {
case _TimelinePhase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelinePhase value)?  $default,){
final _that = this;
switch (_that) {
case _TimelinePhase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelineStep> steps,  List<TimelineLog> logs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelinePhase() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.steps,_that.logs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelineStep> steps,  List<TimelineLog> logs)  $default,) {final _that = this;
switch (_that) {
case _TimelinePhase():
return $default(_that.id,_that.name,_that.description,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.steps,_that.logs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelineStep> steps,  List<TimelineLog> logs)?  $default,) {final _that = this;
switch (_that) {
case _TimelinePhase() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.steps,_that.logs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelinePhase extends TimelinePhase {
  const _TimelinePhase({required this.id, required this.name, this.description, required this.startTime, this.endTime, this.status = TimelineStatus.running, final  Map<String, dynamic> metadata = const {}, final  List<TimelineStep> steps = const [], final  List<TimelineLog> logs = const []}): _metadata = metadata,_steps = steps,_logs = logs,super._();
  factory _TimelinePhase.fromJson(Map<String, dynamic> json) => _$TimelinePhaseFromJson(json);

/// Unique identifier for this phase.
@override final  String id;
/// Human-readable name of the phase.
@override final  String name;
/// Optional description of what this phase does.
@override final  String? description;
/// When this phase started.
@override final  DateTime startTime;
/// When this phase completed (null if still running).
@override final  DateTime? endTime;
/// Current status of the phase.
@override@JsonKey() final  TimelineStatus status;
/// Additional metadata about the phase.
 final  Map<String, dynamic> _metadata;
/// Additional metadata about the phase.
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

/// List of steps that occurred within this phase.
 final  List<TimelineStep> _steps;
/// List of steps that occurred within this phase.
@override@JsonKey() List<TimelineStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

/// List of logs associated with this phase.
 final  List<TimelineLog> _logs;
/// List of logs associated with this phase.
@override@JsonKey() List<TimelineLog> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}


/// Create a copy of TimelinePhase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelinePhaseCopyWith<_TimelinePhase> get copyWith => __$TimelinePhaseCopyWithImpl<_TimelinePhase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelinePhaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelinePhase&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._steps, _steps)&&const DeepCollectionEquality().equals(other._logs, _logs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,startTime,endTime,status,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_logs));

@override
String toString() {
  return 'TimelinePhase(id: $id, name: $name, description: $description, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, steps: $steps, logs: $logs)';
}


}

/// @nodoc
abstract mixin class _$TimelinePhaseCopyWith<$Res> implements $TimelinePhaseCopyWith<$Res> {
  factory _$TimelinePhaseCopyWith(_TimelinePhase value, $Res Function(_TimelinePhase) _then) = __$TimelinePhaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<TimelineStep> steps, List<TimelineLog> logs
});




}
/// @nodoc
class __$TimelinePhaseCopyWithImpl<$Res>
    implements _$TimelinePhaseCopyWith<$Res> {
  __$TimelinePhaseCopyWithImpl(this._self, this._then);

  final _TimelinePhase _self;
  final $Res Function(_TimelinePhase) _then;

/// Create a copy of TimelinePhase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? steps = null,Object? logs = null,}) {
  return _then(_TimelinePhase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<TimelineStep>,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<TimelineLog>,
  ));
}


}

// dart format on
