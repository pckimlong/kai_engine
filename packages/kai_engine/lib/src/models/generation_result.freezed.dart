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
 IList<CoreMessage> get requestMessages;/// Generate messages result per request, not including previous context and user messages
 IList<CoreMessage> get generatedMessages;/// The usage information for the generation, this is optional
 GenerationUsage? get usage; Map<String, dynamic>? get extensions; String? get responseText;
/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationResultCopyWith<GenerationResult> get copyWith => _$GenerationResultCopyWithImpl<GenerationResult>(this as GenerationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationResult&&const DeepCollectionEquality().equals(other.requestMessages, requestMessages)&&const DeepCollectionEquality().equals(other.generatedMessages, generatedMessages)&&(identical(other.usage, usage) || other.usage == usage)&&const DeepCollectionEquality().equals(other.extensions, extensions)&&(identical(other.responseText, responseText) || other.responseText == responseText));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(requestMessages),const DeepCollectionEquality().hash(generatedMessages),usage,const DeepCollectionEquality().hash(extensions),responseText);

@override
String toString() {
  return 'GenerationResult(requestMessages: $requestMessages, generatedMessages: $generatedMessages, usage: $usage, extensions: $extensions, responseText: $responseText)';
}


}

/// @nodoc
abstract mixin class $GenerationResultCopyWith<$Res>  {
  factory $GenerationResultCopyWith(GenerationResult value, $Res Function(GenerationResult) _then) = _$GenerationResultCopyWithImpl;
@useResult
$Res call({
 IList<CoreMessage> requestMessages, IList<CoreMessage> generatedMessages, GenerationUsage? usage, Map<String, dynamic>? extensions, String? responseText
});


$GenerationUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class _$GenerationResultCopyWithImpl<$Res>
    implements $GenerationResultCopyWith<$Res> {
  _$GenerationResultCopyWithImpl(this._self, this._then);

  final GenerationResult _self;
  final $Res Function(GenerationResult) _then;

/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestMessages = null,Object? generatedMessages = null,Object? usage = freezed,Object? extensions = freezed,Object? responseText = freezed,}) {
  return _then(_self.copyWith(
requestMessages: null == requestMessages ? _self.requestMessages : requestMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,generatedMessages: null == generatedMessages ? _self.generatedMessages : generatedMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as GenerationUsage?,extensions: freezed == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,responseText: freezed == responseText ? _self.responseText : responseText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerationUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $GenerationUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IList<CoreMessage> requestMessages,  IList<CoreMessage> generatedMessages,  GenerationUsage? usage,  Map<String, dynamic>? extensions,  String? responseText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationResult() when $default != null:
return $default(_that.requestMessages,_that.generatedMessages,_that.usage,_that.extensions,_that.responseText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IList<CoreMessage> requestMessages,  IList<CoreMessage> generatedMessages,  GenerationUsage? usage,  Map<String, dynamic>? extensions,  String? responseText)  $default,) {final _that = this;
switch (_that) {
case _GenerationResult():
return $default(_that.requestMessages,_that.generatedMessages,_that.usage,_that.extensions,_that.responseText);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IList<CoreMessage> requestMessages,  IList<CoreMessage> generatedMessages,  GenerationUsage? usage,  Map<String, dynamic>? extensions,  String? responseText)?  $default,) {final _that = this;
switch (_that) {
case _GenerationResult() when $default != null:
return $default(_that.requestMessages,_that.generatedMessages,_that.usage,_that.extensions,_that.responseText);case _:
  return null;

}
}

}

/// @nodoc


class _GenerationResult extends GenerationResult {
  const _GenerationResult({required this.requestMessages, required this.generatedMessages, required this.usage, final  Map<String, dynamic>? extensions, this.responseText}): _extensions = extensions,super._();
  

/// The original request message
@override final  IList<CoreMessage> requestMessages;
/// Generate messages result per request, not including previous context and user messages
@override final  IList<CoreMessage> generatedMessages;
/// The usage information for the generation, this is optional
@override final  GenerationUsage? usage;
 final  Map<String, dynamic>? _extensions;
@override Map<String, dynamic>? get extensions {
  final value = _extensions;
  if (value == null) return null;
  if (_extensions is EqualUnmodifiableMapView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? responseText;

/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationResultCopyWith<_GenerationResult> get copyWith => __$GenerationResultCopyWithImpl<_GenerationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationResult&&const DeepCollectionEquality().equals(other.requestMessages, requestMessages)&&const DeepCollectionEquality().equals(other.generatedMessages, generatedMessages)&&(identical(other.usage, usage) || other.usage == usage)&&const DeepCollectionEquality().equals(other._extensions, _extensions)&&(identical(other.responseText, responseText) || other.responseText == responseText));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(requestMessages),const DeepCollectionEquality().hash(generatedMessages),usage,const DeepCollectionEquality().hash(_extensions),responseText);

@override
String toString() {
  return 'GenerationResult(requestMessages: $requestMessages, generatedMessages: $generatedMessages, usage: $usage, extensions: $extensions, responseText: $responseText)';
}


}

/// @nodoc
abstract mixin class _$GenerationResultCopyWith<$Res> implements $GenerationResultCopyWith<$Res> {
  factory _$GenerationResultCopyWith(_GenerationResult value, $Res Function(_GenerationResult) _then) = __$GenerationResultCopyWithImpl;
@override @useResult
$Res call({
 IList<CoreMessage> requestMessages, IList<CoreMessage> generatedMessages, GenerationUsage? usage, Map<String, dynamic>? extensions, String? responseText
});


@override $GenerationUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class __$GenerationResultCopyWithImpl<$Res>
    implements _$GenerationResultCopyWith<$Res> {
  __$GenerationResultCopyWithImpl(this._self, this._then);

  final _GenerationResult _self;
  final $Res Function(_GenerationResult) _then;

/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestMessages = null,Object? generatedMessages = null,Object? usage = freezed,Object? extensions = freezed,Object? responseText = freezed,}) {
  return _then(_GenerationResult(
requestMessages: null == requestMessages ? _self.requestMessages : requestMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,generatedMessages: null == generatedMessages ? _self.generatedMessages : generatedMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as GenerationUsage?,extensions: freezed == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,responseText: freezed == responseText ? _self.responseText : responseText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GenerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerationUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $GenerationUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}

/// @nodoc
mixin _$GenerationUsage {

 int? get inputToken; int? get outputToken; int? get apiCallCount; Map<String, dynamic>? get extensions;
/// Create a copy of GenerationUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationUsageCopyWith<GenerationUsage> get copyWith => _$GenerationUsageCopyWithImpl<GenerationUsage>(this as GenerationUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationUsage&&(identical(other.inputToken, inputToken) || other.inputToken == inputToken)&&(identical(other.outputToken, outputToken) || other.outputToken == outputToken)&&(identical(other.apiCallCount, apiCallCount) || other.apiCallCount == apiCallCount)&&const DeepCollectionEquality().equals(other.extensions, extensions));
}


@override
int get hashCode => Object.hash(runtimeType,inputToken,outputToken,apiCallCount,const DeepCollectionEquality().hash(extensions));

@override
String toString() {
  return 'GenerationUsage(inputToken: $inputToken, outputToken: $outputToken, apiCallCount: $apiCallCount, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class $GenerationUsageCopyWith<$Res>  {
  factory $GenerationUsageCopyWith(GenerationUsage value, $Res Function(GenerationUsage) _then) = _$GenerationUsageCopyWithImpl;
@useResult
$Res call({
 int? inputToken, int? outputToken, int? apiCallCount, Map<String, dynamic>? extensions
});




}
/// @nodoc
class _$GenerationUsageCopyWithImpl<$Res>
    implements $GenerationUsageCopyWith<$Res> {
  _$GenerationUsageCopyWithImpl(this._self, this._then);

  final GenerationUsage _self;
  final $Res Function(GenerationUsage) _then;

/// Create a copy of GenerationUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inputToken = freezed,Object? outputToken = freezed,Object? apiCallCount = freezed,Object? extensions = freezed,}) {
  return _then(_self.copyWith(
inputToken: freezed == inputToken ? _self.inputToken : inputToken // ignore: cast_nullable_to_non_nullable
as int?,outputToken: freezed == outputToken ? _self.outputToken : outputToken // ignore: cast_nullable_to_non_nullable
as int?,apiCallCount: freezed == apiCallCount ? _self.apiCallCount : apiCallCount // ignore: cast_nullable_to_non_nullable
as int?,extensions: freezed == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GenerationUsage].
extension GenerationUsagePatterns on GenerationUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerationUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerationUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerationUsage value)  $default,){
final _that = this;
switch (_that) {
case _GenerationUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerationUsage value)?  $default,){
final _that = this;
switch (_that) {
case _GenerationUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? inputToken,  int? outputToken,  int? apiCallCount,  Map<String, dynamic>? extensions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationUsage() when $default != null:
return $default(_that.inputToken,_that.outputToken,_that.apiCallCount,_that.extensions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? inputToken,  int? outputToken,  int? apiCallCount,  Map<String, dynamic>? extensions)  $default,) {final _that = this;
switch (_that) {
case _GenerationUsage():
return $default(_that.inputToken,_that.outputToken,_that.apiCallCount,_that.extensions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? inputToken,  int? outputToken,  int? apiCallCount,  Map<String, dynamic>? extensions)?  $default,) {final _that = this;
switch (_that) {
case _GenerationUsage() when $default != null:
return $default(_that.inputToken,_that.outputToken,_that.apiCallCount,_that.extensions);case _:
  return null;

}
}

}

/// @nodoc


class _GenerationUsage extends GenerationUsage {
  const _GenerationUsage({required this.inputToken, required this.outputToken, required this.apiCallCount, final  Map<String, dynamic>? extensions}): _extensions = extensions,super._();
  

@override final  int? inputToken;
@override final  int? outputToken;
@override final  int? apiCallCount;
 final  Map<String, dynamic>? _extensions;
@override Map<String, dynamic>? get extensions {
  final value = _extensions;
  if (value == null) return null;
  if (_extensions is EqualUnmodifiableMapView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GenerationUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationUsageCopyWith<_GenerationUsage> get copyWith => __$GenerationUsageCopyWithImpl<_GenerationUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationUsage&&(identical(other.inputToken, inputToken) || other.inputToken == inputToken)&&(identical(other.outputToken, outputToken) || other.outputToken == outputToken)&&(identical(other.apiCallCount, apiCallCount) || other.apiCallCount == apiCallCount)&&const DeepCollectionEquality().equals(other._extensions, _extensions));
}


@override
int get hashCode => Object.hash(runtimeType,inputToken,outputToken,apiCallCount,const DeepCollectionEquality().hash(_extensions));

@override
String toString() {
  return 'GenerationUsage(inputToken: $inputToken, outputToken: $outputToken, apiCallCount: $apiCallCount, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class _$GenerationUsageCopyWith<$Res> implements $GenerationUsageCopyWith<$Res> {
  factory _$GenerationUsageCopyWith(_GenerationUsage value, $Res Function(_GenerationUsage) _then) = __$GenerationUsageCopyWithImpl;
@override @useResult
$Res call({
 int? inputToken, int? outputToken, int? apiCallCount, Map<String, dynamic>? extensions
});




}
/// @nodoc
class __$GenerationUsageCopyWithImpl<$Res>
    implements _$GenerationUsageCopyWith<$Res> {
  __$GenerationUsageCopyWithImpl(this._self, this._then);

  final _GenerationUsage _self;
  final $Res Function(_GenerationUsage) _then;

/// Create a copy of GenerationUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inputToken = freezed,Object? outputToken = freezed,Object? apiCallCount = freezed,Object? extensions = freezed,}) {
  return _then(_GenerationUsage(
inputToken: freezed == inputToken ? _self.inputToken : inputToken // ignore: cast_nullable_to_non_nullable
as int?,outputToken: freezed == outputToken ? _self.outputToken : outputToken // ignore: cast_nullable_to_non_nullable
as int?,apiCallCount: freezed == apiCallCount ? _self.apiCallCount : apiCallCount // ignore: cast_nullable_to_non_nullable
as int?,extensions: freezed == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
