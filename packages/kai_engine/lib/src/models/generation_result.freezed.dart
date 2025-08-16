// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenerationResult {

/// The original request message
 CoreMessage get requestMessage;/// Generate messages result per request, not including previous context and user messages
 IList<CoreMessage> get generatedMessage; Map<String, dynamic>? get extensions;
/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationResultCopyWith<GenerationResult> get copyWith => _$GenerationResultCopyWithImpl<GenerationResult>(this as GenerationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationResult&&(identical(other.requestMessage, requestMessage) || other.requestMessage == requestMessage)&&const DeepCollectionEquality().equals(other.generatedMessage, generatedMessage)&&const DeepCollectionEquality().equals(other.extensions, extensions));
}


@override
int get hashCode => Object.hash(runtimeType,requestMessage,const DeepCollectionEquality().hash(generatedMessage),const DeepCollectionEquality().hash(extensions));

@override
String toString() {
  return 'GenerationResult(requestMessage: $requestMessage, generatedMessage: $generatedMessage, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class $GenerationResultCopyWith<$Res>  {
  factory $GenerationResultCopyWith(GenerationResult value, $Res Function(GenerationResult) _then) = _$GenerationResultCopyWithImpl;
@useResult
$Res call({
 CoreMessage requestMessage, IList<CoreMessage> generatedMessage, Map<String, dynamic>? extensions
});


$CoreMessageCopyWith<$Res> get requestMessage;

}
/// @nodoc
class _$GenerationResultCopyWithImpl<$Res>
    implements $GenerationResultCopyWith<$Res> {
  _$GenerationResultCopyWithImpl(this._self, this._then);

  final GenerationResult _self;
  final $Res Function(GenerationResult) _then;

/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestMessage = null,Object? generatedMessage = null,Object? extensions = freezed,}) {
  return _then(_self.copyWith(
requestMessage: null == requestMessage ? _self.requestMessage : requestMessage // ignore: cast_nullable_to_non_nullable
as CoreMessage,generatedMessage: null == generatedMessage ? _self.generatedMessage : generatedMessage // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,extensions: freezed == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMessageCopyWith<$Res> get requestMessage {
  
  return $CoreMessageCopyWith<$Res>(_self.requestMessage, (value) {
    return _then(_self.copyWith(requestMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [GenerationResult].
extension GenerationResultPatterns on GenerationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerationResult value)  $default,){
final _that = this;
switch (_that) {
case _GenerationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerationResult value)?  $default,){
final _that = this;
switch (_that) {
case _GenerationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CoreMessage requestMessage,  IList<CoreMessage> generatedMessage,  Map<String, dynamic>? extensions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationResult() when $default != null:
return $default(_that.requestMessage,_that.generatedMessage,_that.extensions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CoreMessage requestMessage,  IList<CoreMessage> generatedMessage,  Map<String, dynamic>? extensions)  $default,) {final _that = this;
switch (_that) {
case _GenerationResult():
return $default(_that.requestMessage,_that.generatedMessage,_that.extensions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CoreMessage requestMessage,  IList<CoreMessage> generatedMessage,  Map<String, dynamic>? extensions)?  $default,) {final _that = this;
switch (_that) {
case _GenerationResult() when $default != null:
return $default(_that.requestMessage,_that.generatedMessage,_that.extensions);case _:
  return null;

}
}

}

/// @nodoc


class _GenerationResult extends GenerationResult {
  const _GenerationResult({required this.requestMessage, required this.generatedMessage, final  Map<String, dynamic>? extensions}): _extensions = extensions,super._();
  

/// The original request message
@override final  CoreMessage requestMessage;
/// Generate messages result per request, not including previous context and user messages
@override final  IList<CoreMessage> generatedMessage;
 final  Map<String, dynamic>? _extensions;
@override Map<String, dynamic>? get extensions {
  final value = _extensions;
  if (value == null) return null;
  if (_extensions is EqualUnmodifiableMapView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationResultCopyWith<_GenerationResult> get copyWith => __$GenerationResultCopyWithImpl<_GenerationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationResult&&(identical(other.requestMessage, requestMessage) || other.requestMessage == requestMessage)&&const DeepCollectionEquality().equals(other.generatedMessage, generatedMessage)&&const DeepCollectionEquality().equals(other._extensions, _extensions));
}


@override
int get hashCode => Object.hash(runtimeType,requestMessage,const DeepCollectionEquality().hash(generatedMessage),const DeepCollectionEquality().hash(_extensions));

@override
String toString() {
  return 'GenerationResult(requestMessage: $requestMessage, generatedMessage: $generatedMessage, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class _$GenerationResultCopyWith<$Res> implements $GenerationResultCopyWith<$Res> {
  factory _$GenerationResultCopyWith(_GenerationResult value, $Res Function(_GenerationResult) _then) = __$GenerationResultCopyWithImpl;
@override @useResult
$Res call({
 CoreMessage requestMessage, IList<CoreMessage> generatedMessage, Map<String, dynamic>? extensions
});


@override $CoreMessageCopyWith<$Res> get requestMessage;

}
/// @nodoc
class __$GenerationResultCopyWithImpl<$Res>
    implements _$GenerationResultCopyWith<$Res> {
  __$GenerationResultCopyWithImpl(this._self, this._then);

  final _GenerationResult _self;
  final $Res Function(_GenerationResult) _then;

/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestMessage = null,Object? generatedMessage = null,Object? extensions = freezed,}) {
  return _then(_GenerationResult(
requestMessage: null == requestMessage ? _self.requestMessage : requestMessage // ignore: cast_nullable_to_non_nullable
as CoreMessage,generatedMessage: null == generatedMessage ? _self.generatedMessage : generatedMessage // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,extensions: freezed == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMessageCopyWith<$Res> get requestMessage {
  
  return $CoreMessageCopyWith<$Res>(_self.requestMessage, (value) {
    return _then(_self.copyWith(requestMessage: value));
  });
}
}

// dart format on
