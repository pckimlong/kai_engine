// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kai_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KaiException {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KaiException);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'KaiException()';
}


}

/// @nodoc
class $KaiExceptionCopyWith<$Res>  {
$KaiExceptionCopyWith(KaiException _, $Res Function(KaiException) __);
}


/// Adds pattern-matching-related methods to [KaiException].
extension KaiExceptionPatterns on KaiException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _KaiException value)?  exception,TResult Function( _KaiExceptionCancelled value)?  cancelled,TResult Function( _KaiExceptionNoResponse value)?  noResponse,TResult Function( _KaiExceptionToolFailure value)?  toolFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KaiException() when exception != null:
return exception(_that);case _KaiExceptionCancelled() when cancelled != null:
return cancelled(_that);case _KaiExceptionNoResponse() when noResponse != null:
return noResponse(_that);case _KaiExceptionToolFailure() when toolFailure != null:
return toolFailure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _KaiException value)  exception,required TResult Function( _KaiExceptionCancelled value)  cancelled,required TResult Function( _KaiExceptionNoResponse value)  noResponse,required TResult Function( _KaiExceptionToolFailure value)  toolFailure,}){
final _that = this;
switch (_that) {
case _KaiException():
return exception(_that);case _KaiExceptionCancelled():
return cancelled(_that);case _KaiExceptionNoResponse():
return noResponse(_that);case _KaiExceptionToolFailure():
return toolFailure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _KaiException value)?  exception,TResult? Function( _KaiExceptionCancelled value)?  cancelled,TResult? Function( _KaiExceptionNoResponse value)?  noResponse,TResult? Function( _KaiExceptionToolFailure value)?  toolFailure,}){
final _that = this;
switch (_that) {
case _KaiException() when exception != null:
return exception(_that);case _KaiExceptionCancelled() when cancelled != null:
return cancelled(_that);case _KaiExceptionNoResponse() when noResponse != null:
return noResponse(_that);case _KaiExceptionToolFailure() when toolFailure != null:
return toolFailure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message,  StackTrace? stackTrace)?  exception,TResult Function()?  cancelled,TResult Function()?  noResponse,TResult Function( String? reason,  StackTrace? stackTrace)?  toolFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KaiException() when exception != null:
return exception(_that.message,_that.stackTrace);case _KaiExceptionCancelled() when cancelled != null:
return cancelled();case _KaiExceptionNoResponse() when noResponse != null:
return noResponse();case _KaiExceptionToolFailure() when toolFailure != null:
return toolFailure(_that.reason,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message,  StackTrace? stackTrace)  exception,required TResult Function()  cancelled,required TResult Function()  noResponse,required TResult Function( String? reason,  StackTrace? stackTrace)  toolFailure,}) {final _that = this;
switch (_that) {
case _KaiException():
return exception(_that.message,_that.stackTrace);case _KaiExceptionCancelled():
return cancelled();case _KaiExceptionNoResponse():
return noResponse();case _KaiExceptionToolFailure():
return toolFailure(_that.reason,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message,  StackTrace? stackTrace)?  exception,TResult? Function()?  cancelled,TResult? Function()?  noResponse,TResult? Function( String? reason,  StackTrace? stackTrace)?  toolFailure,}) {final _that = this;
switch (_that) {
case _KaiException() when exception != null:
return exception(_that.message,_that.stackTrace);case _KaiExceptionCancelled() when cancelled != null:
return cancelled();case _KaiExceptionNoResponse() when noResponse != null:
return noResponse();case _KaiExceptionToolFailure() when toolFailure != null:
return toolFailure(_that.reason,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _KaiException extends KaiException {
  const _KaiException([this.message, this.stackTrace]): super._();
  

 final  String? message;
 final  StackTrace? stackTrace;

/// Create a copy of KaiException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KaiExceptionCopyWith<_KaiException> get copyWith => __$KaiExceptionCopyWithImpl<_KaiException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaiException&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,stackTrace);

@override
String toString() {
  return 'KaiException.exception(message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$KaiExceptionCopyWith<$Res> implements $KaiExceptionCopyWith<$Res> {
  factory _$KaiExceptionCopyWith(_KaiException value, $Res Function(_KaiException) _then) = __$KaiExceptionCopyWithImpl;
@useResult
$Res call({
 String? message, StackTrace? stackTrace
});




}
/// @nodoc
class __$KaiExceptionCopyWithImpl<$Res>
    implements _$KaiExceptionCopyWith<$Res> {
  __$KaiExceptionCopyWithImpl(this._self, this._then);

  final _KaiException _self;
  final $Res Function(_KaiException) _then;

/// Create a copy of KaiException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? stackTrace = freezed,}) {
  return _then(_KaiException(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

/// @nodoc


class _KaiExceptionCancelled extends KaiException {
  const _KaiExceptionCancelled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaiExceptionCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'KaiException.cancelled()';
}


}




/// @nodoc


class _KaiExceptionNoResponse extends KaiException {
  const _KaiExceptionNoResponse(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaiExceptionNoResponse);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'KaiException.noResponse()';
}


}




/// @nodoc


class _KaiExceptionToolFailure extends KaiException {
  const _KaiExceptionToolFailure([this.reason, this.stackTrace]): super._();
  

 final  String? reason;
 final  StackTrace? stackTrace;

/// Create a copy of KaiException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KaiExceptionToolFailureCopyWith<_KaiExceptionToolFailure> get copyWith => __$KaiExceptionToolFailureCopyWithImpl<_KaiExceptionToolFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KaiExceptionToolFailure&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,reason,stackTrace);

@override
String toString() {
  return 'KaiException.toolFailure(reason: $reason, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$KaiExceptionToolFailureCopyWith<$Res> implements $KaiExceptionCopyWith<$Res> {
  factory _$KaiExceptionToolFailureCopyWith(_KaiExceptionToolFailure value, $Res Function(_KaiExceptionToolFailure) _then) = __$KaiExceptionToolFailureCopyWithImpl;
@useResult
$Res call({
 String? reason, StackTrace? stackTrace
});




}
/// @nodoc
class __$KaiExceptionToolFailureCopyWithImpl<$Res>
    implements _$KaiExceptionToolFailureCopyWith<$Res> {
  __$KaiExceptionToolFailureCopyWithImpl(this._self, this._then);

  final _KaiExceptionToolFailure _self;
  final $Res Function(_KaiExceptionToolFailure) _then;

/// Create a copy of KaiException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = freezed,Object? stackTrace = freezed,}) {
  return _then(_KaiExceptionToolFailure(
freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
