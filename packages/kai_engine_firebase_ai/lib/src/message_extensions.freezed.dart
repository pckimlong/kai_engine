// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_extensions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GenerationUsage {

 int? get inputToken; int? get outputToken; int? get apiCallCount;
/// Create a copy of GenerationUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationUsageCopyWith<GenerationUsage> get copyWith => _$GenerationUsageCopyWithImpl<GenerationUsage>(this as GenerationUsage, _$identity);

  /// Serializes this GenerationUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationUsage&&(identical(other.inputToken, inputToken) || other.inputToken == inputToken)&&(identical(other.outputToken, outputToken) || other.outputToken == outputToken)&&(identical(other.apiCallCount, apiCallCount) || other.apiCallCount == apiCallCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inputToken,outputToken,apiCallCount);

@override
String toString() {
  return 'GenerationUsage(inputToken: $inputToken, outputToken: $outputToken, apiCallCount: $apiCallCount)';
}


}

/// @nodoc
abstract mixin class $GenerationUsageCopyWith<$Res>  {
  factory $GenerationUsageCopyWith(GenerationUsage value, $Res Function(GenerationUsage) _then) = _$GenerationUsageCopyWithImpl;
@useResult
$Res call({
 int? inputToken, int? outputToken, int? apiCallCount
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
@pragma('vm:prefer-inline') @override $Res call({Object? inputToken = freezed,Object? outputToken = freezed,Object? apiCallCount = freezed,}) {
  return _then(_self.copyWith(
inputToken: freezed == inputToken ? _self.inputToken : inputToken // ignore: cast_nullable_to_non_nullable
as int?,outputToken: freezed == outputToken ? _self.outputToken : outputToken // ignore: cast_nullable_to_non_nullable
as int?,apiCallCount: freezed == apiCallCount ? _self.apiCallCount : apiCallCount // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? inputToken,  int? outputToken,  int? apiCallCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationUsage() when $default != null:
return $default(_that.inputToken,_that.outputToken,_that.apiCallCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? inputToken,  int? outputToken,  int? apiCallCount)  $default,) {final _that = this;
switch (_that) {
case _GenerationUsage():
return $default(_that.inputToken,_that.outputToken,_that.apiCallCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? inputToken,  int? outputToken,  int? apiCallCount)?  $default,) {final _that = this;
switch (_that) {
case _GenerationUsage() when $default != null:
return $default(_that.inputToken,_that.outputToken,_that.apiCallCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenerationUsage extends GenerationUsage {
  const _GenerationUsage({required this.inputToken, required this.outputToken, required this.apiCallCount}): super._();
  factory _GenerationUsage.fromJson(Map<String, dynamic> json) => _$GenerationUsageFromJson(json);

@override final  int? inputToken;
@override final  int? outputToken;
@override final  int? apiCallCount;

/// Create a copy of GenerationUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationUsageCopyWith<_GenerationUsage> get copyWith => __$GenerationUsageCopyWithImpl<_GenerationUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenerationUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationUsage&&(identical(other.inputToken, inputToken) || other.inputToken == inputToken)&&(identical(other.outputToken, outputToken) || other.outputToken == outputToken)&&(identical(other.apiCallCount, apiCallCount) || other.apiCallCount == apiCallCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inputToken,outputToken,apiCallCount);

@override
String toString() {
  return 'GenerationUsage(inputToken: $inputToken, outputToken: $outputToken, apiCallCount: $apiCallCount)';
}


}

/// @nodoc
abstract mixin class _$GenerationUsageCopyWith<$Res> implements $GenerationUsageCopyWith<$Res> {
  factory _$GenerationUsageCopyWith(_GenerationUsage value, $Res Function(_GenerationUsage) _then) = __$GenerationUsageCopyWithImpl;
@override @useResult
$Res call({
 int? inputToken, int? outputToken, int? apiCallCount
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
@override @pragma('vm:prefer-inline') $Res call({Object? inputToken = freezed,Object? outputToken = freezed,Object? apiCallCount = freezed,}) {
  return _then(_GenerationUsage(
inputToken: freezed == inputToken ? _self.inputToken : inputToken // ignore: cast_nullable_to_non_nullable
as int?,outputToken: freezed == outputToken ? _self.outputToken : outputToken // ignore: cast_nullable_to_non_nullable
as int?,apiCallCount: freezed == apiCallCount ? _self.apiCallCount : apiCallCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
