// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimelineStep {

/// Unique identifier for this step.
 String get id;/// Human-readable name of the step.
 String get name;/// Optional description of what this step does.
 String? get description;/// When this step started.
 DateTime get startTime;/// When this step completed (null if still running).
 DateTime? get endTime;/// Current status of the step.
 TimelineStatus get status;/// Additional metadata about the step.
 Map<String, dynamic> get metadata;/// List of logs associated with this step.
 List<TimelineLog> get logs;/// List of nested steps.
 List<TimelineStep> get steps;
/// Create a copy of TimelineStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineStepCopyWith<TimelineStep> get copyWith => _$TimelineStepCopyWithImpl<TimelineStep>(this as TimelineStep, _$identity);

  /// Serializes this TimelineStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineStep&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.logs, logs)&&const DeepCollectionEquality().equals(other.steps, steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,startTime,endTime,status,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(logs),const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'TimelineStep(id: $id, name: $name, description: $description, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, logs: $logs, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $TimelineStepCopyWith<$Res>  {
  factory $TimelineStepCopyWith(TimelineStep value, $Res Function(TimelineStep) _then) = _$TimelineStepCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<TimelineLog> logs, List<TimelineStep> steps
});




}
/// @nodoc
class _$TimelineStepCopyWithImpl<$Res>
    implements $TimelineStepCopyWith<$Res> {
  _$TimelineStepCopyWithImpl(this._self, this._then);

  final TimelineStep _self;
  final $Res Function(TimelineStep) _then;

/// Create a copy of TimelineStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? logs = null,Object? steps = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<TimelineLog>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<TimelineStep>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineStep].
extension TimelineStepPatterns on TimelineStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineStep value)  $default,){
final _that = this;
switch (_that) {
case _TimelineStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineStep value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelineLog> logs,  List<TimelineStep> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineStep() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.logs,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelineLog> logs,  List<TimelineStep> steps)  $default,) {final _that = this;
switch (_that) {
case _TimelineStep():
return $default(_that.id,_that.name,_that.description,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.logs,_that.steps);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  DateTime startTime,  DateTime? endTime,  TimelineStatus status,  Map<String, dynamic> metadata,  List<TimelineLog> logs,  List<TimelineStep> steps)?  $default,) {final _that = this;
switch (_that) {
case _TimelineStep() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.startTime,_that.endTime,_that.status,_that.metadata,_that.logs,_that.steps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineStep extends TimelineStep {
  const _TimelineStep({required this.id, required this.name, this.description, required this.startTime, this.endTime, this.status = TimelineStatus.running, final  Map<String, dynamic> metadata = const {}, final  List<TimelineLog> logs = const [], final  List<TimelineStep> steps = const []}): _metadata = metadata,_logs = logs,_steps = steps,super._();
  factory _TimelineStep.fromJson(Map<String, dynamic> json) => _$TimelineStepFromJson(json);

/// Unique identifier for this step.
@override final  String id;
/// Human-readable name of the step.
@override final  String name;
/// Optional description of what this step does.
@override final  String? description;
/// When this step started.
@override final  DateTime startTime;
/// When this step completed (null if still running).
@override final  DateTime? endTime;
/// Current status of the step.
@override@JsonKey() final  TimelineStatus status;
/// Additional metadata about the step.
 final  Map<String, dynamic> _metadata;
/// Additional metadata about the step.
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

/// List of logs associated with this step.
 final  List<TimelineLog> _logs;
/// List of logs associated with this step.
@override@JsonKey() List<TimelineLog> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

/// List of nested steps.
 final  List<TimelineStep> _steps;
/// List of nested steps.
@override@JsonKey() List<TimelineStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of TimelineStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineStepCopyWith<_TimelineStep> get copyWith => __$TimelineStepCopyWithImpl<_TimelineStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineStep&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._logs, _logs)&&const DeepCollectionEquality().equals(other._steps, _steps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,startTime,endTime,status,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_logs),const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'TimelineStep(id: $id, name: $name, description: $description, startTime: $startTime, endTime: $endTime, status: $status, metadata: $metadata, logs: $logs, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$TimelineStepCopyWith<$Res> implements $TimelineStepCopyWith<$Res> {
  factory _$TimelineStepCopyWith(_TimelineStep value, $Res Function(_TimelineStep) _then) = __$TimelineStepCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, DateTime startTime, DateTime? endTime, TimelineStatus status, Map<String, dynamic> metadata, List<TimelineLog> logs, List<TimelineStep> steps
});




}
/// @nodoc
class __$TimelineStepCopyWithImpl<$Res>
    implements _$TimelineStepCopyWith<$Res> {
  __$TimelineStepCopyWithImpl(this._self, this._then);

  final _TimelineStep _self;
  final $Res Function(_TimelineStep) _then;

/// Create a copy of TimelineStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? startTime = null,Object? endTime = freezed,Object? status = null,Object? metadata = null,Object? logs = null,Object? steps = null,}) {
  return _then(_TimelineStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimelineStatus,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<TimelineLog>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<TimelineStep>,
  ));
}


}

// dart format on
