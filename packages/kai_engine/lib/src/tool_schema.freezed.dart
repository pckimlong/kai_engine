// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tool_schema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ToolResult<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToolResult<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ToolResult<$T>()';
}


}

/// @nodoc
class $ToolResultCopyWith<T,$Res>  {
$ToolResultCopyWith(ToolResult<T> _, $Res Function(ToolResult<T>) __);
}


/// Adds pattern-matching-related methods to [ToolResult].
extension ToolResultPatterns<T> on ToolResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ToolResultSuccessWithData<T> value)?  success,TResult Function( _ToolResultFailure<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToolResultSuccessWithData() when success != null:
return success(_that);case _ToolResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ToolResultSuccessWithData<T> value)  success,required TResult Function( _ToolResultFailure<T> value)  failure,}){
final _that = this;
switch (_that) {
case _ToolResultSuccessWithData():
return success(_that);case _ToolResultFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ToolResultSuccessWithData<T> value)?  success,TResult? Function( _ToolResultFailure<T> value)?  failure,}){
final _that = this;
switch (_that) {
case _ToolResultSuccessWithData() when success != null:
return success(_that);case _ToolResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T data,  Map<String, Object?> response)?  success,TResult Function( String error,  StackTrace stackTrace)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToolResultSuccessWithData() when success != null:
return success(_that.data,_that.response);case _ToolResultFailure() when failure != null:
return failure(_that.error,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T data,  Map<String, Object?> response)  success,required TResult Function( String error,  StackTrace stackTrace)  failure,}) {final _that = this;
switch (_that) {
case _ToolResultSuccessWithData():
return success(_that.data,_that.response);case _ToolResultFailure():
return failure(_that.error,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T data,  Map<String, Object?> response)?  success,TResult? Function( String error,  StackTrace stackTrace)?  failure,}) {final _that = this;
switch (_that) {
case _ToolResultSuccessWithData() when success != null:
return success(_that.data,_that.response);case _ToolResultFailure() when failure != null:
return failure(_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _ToolResultSuccessWithData<T> extends ToolResult<T> {
  const _ToolResultSuccessWithData(this.data, final  Map<String, Object?> response): _response = response,super._();
  

 final  T data;
 final  Map<String, Object?> _response;
 Map<String, Object?> get response {
  if (_response is EqualUnmodifiableMapView) return _response;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_response);
}


/// Create a copy of ToolResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolResultSuccessWithDataCopyWith<T, _ToolResultSuccessWithData<T>> get copyWith => __$ToolResultSuccessWithDataCopyWithImpl<T, _ToolResultSuccessWithData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolResultSuccessWithData<T>&&const DeepCollectionEquality().equals(other.data, data)&&const DeepCollectionEquality().equals(other._response, _response));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),const DeepCollectionEquality().hash(_response));

@override
String toString() {
  return 'ToolResult<$T>.success(data: $data, response: $response)';
}


}

/// @nodoc
abstract mixin class _$ToolResultSuccessWithDataCopyWith<T,$Res> implements $ToolResultCopyWith<T, $Res> {
  factory _$ToolResultSuccessWithDataCopyWith(_ToolResultSuccessWithData<T> value, $Res Function(_ToolResultSuccessWithData<T>) _then) = __$ToolResultSuccessWithDataCopyWithImpl;
@useResult
$Res call({
 T data, Map<String, Object?> response
});




}
/// @nodoc
class __$ToolResultSuccessWithDataCopyWithImpl<T,$Res>
    implements _$ToolResultSuccessWithDataCopyWith<T, $Res> {
  __$ToolResultSuccessWithDataCopyWithImpl(this._self, this._then);

  final _ToolResultSuccessWithData<T> _self;
  final $Res Function(_ToolResultSuccessWithData<T>) _then;

/// Create a copy of ToolResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? response = null,}) {
  return _then(_ToolResultSuccessWithData<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,null == response ? _self._response : response // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

/// @nodoc


class _ToolResultFailure<T> extends ToolResult<T> {
  const _ToolResultFailure(this.error, this.stackTrace): super._();
  

 final  String error;
 final  StackTrace stackTrace;

/// Create a copy of ToolResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolResultFailureCopyWith<T, _ToolResultFailure<T>> get copyWith => __$ToolResultFailureCopyWithImpl<T, _ToolResultFailure<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolResultFailure<T>&&(identical(other.error, error) || other.error == error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,error,stackTrace);

@override
String toString() {
  return 'ToolResult<$T>.failure(error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$ToolResultFailureCopyWith<T,$Res> implements $ToolResultCopyWith<T, $Res> {
  factory _$ToolResultFailureCopyWith(_ToolResultFailure<T> value, $Res Function(_ToolResultFailure<T>) _then) = __$ToolResultFailureCopyWithImpl;
@useResult
$Res call({
 String error, StackTrace stackTrace
});




}
/// @nodoc
class __$ToolResultFailureCopyWithImpl<T,$Res>
    implements _$ToolResultFailureCopyWith<T, $Res> {
  __$ToolResultFailureCopyWithImpl(this._self, this._then);

  final _ToolResultFailure<T> _self;
  final $Res Function(_ToolResultFailure<T>) _then;

/// Create a copy of ToolResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? stackTrace = null,}) {
  return _then(_ToolResultFailure<T>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,null == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace,
  ));
}


}

// dart format on
