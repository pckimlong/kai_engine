// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_service_base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ToolingConfig {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToolingConfig);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ToolingConfig()';
}


}

/// @nodoc
class $ToolingConfigCopyWith<$Res>  {
$ToolingConfigCopyWith(ToolingConfig _, $Res Function(ToolingConfig) __);
}


/// Adds pattern-matching-related methods to [ToolingConfig].
extension ToolingConfigPatterns on ToolingConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ToolingConfigAuto value)?  auto,TResult Function( _ToolingConfigAny value)?  any,TResult Function( _ToolingConfigNone value)?  none,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToolingConfigAuto() when auto != null:
return auto(_that);case _ToolingConfigAny() when any != null:
return any(_that);case _ToolingConfigNone() when none != null:
return none(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ToolingConfigAuto value)  auto,required TResult Function( _ToolingConfigAny value)  any,required TResult Function( _ToolingConfigNone value)  none,}){
final _that = this;
switch (_that) {
case _ToolingConfigAuto():
return auto(_that);case _ToolingConfigAny():
return any(_that);case _ToolingConfigNone():
return none(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ToolingConfigAuto value)?  auto,TResult? Function( _ToolingConfigAny value)?  any,TResult? Function( _ToolingConfigNone value)?  none,}){
final _that = this;
switch (_that) {
case _ToolingConfigAuto() when auto != null:
return auto(_that);case _ToolingConfigAny() when any != null:
return any(_that);case _ToolingConfigNone() when none != null:
return none(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  auto,TResult Function( Set<String> allowedFunctionNames)?  any,TResult Function()?  none,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToolingConfigAuto() when auto != null:
return auto();case _ToolingConfigAny() when any != null:
return any(_that.allowedFunctionNames);case _ToolingConfigNone() when none != null:
return none();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  auto,required TResult Function( Set<String> allowedFunctionNames)  any,required TResult Function()  none,}) {final _that = this;
switch (_that) {
case _ToolingConfigAuto():
return auto();case _ToolingConfigAny():
return any(_that.allowedFunctionNames);case _ToolingConfigNone():
return none();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  auto,TResult? Function( Set<String> allowedFunctionNames)?  any,TResult? Function()?  none,}) {final _that = this;
switch (_that) {
case _ToolingConfigAuto() when auto != null:
return auto();case _ToolingConfigAny() when any != null:
return any(_that.allowedFunctionNames);case _ToolingConfigNone() when none != null:
return none();case _:
  return null;

}
}

}

/// @nodoc


class _ToolingConfigAuto extends ToolingConfig {
  const _ToolingConfigAuto(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolingConfigAuto);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ToolingConfig.auto()';
}


}




/// @nodoc


class _ToolingConfigAny extends ToolingConfig {
  const _ToolingConfigAny(final  Set<String> allowedFunctionNames): _allowedFunctionNames = allowedFunctionNames,super._();
  

 final  Set<String> _allowedFunctionNames;
 Set<String> get allowedFunctionNames {
  if (_allowedFunctionNames is EqualUnmodifiableSetView) return _allowedFunctionNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_allowedFunctionNames);
}


/// Create a copy of ToolingConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolingConfigAnyCopyWith<_ToolingConfigAny> get copyWith => __$ToolingConfigAnyCopyWithImpl<_ToolingConfigAny>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolingConfigAny&&const DeepCollectionEquality().equals(other._allowedFunctionNames, _allowedFunctionNames));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_allowedFunctionNames));

@override
String toString() {
  return 'ToolingConfig.any(allowedFunctionNames: $allowedFunctionNames)';
}


}

/// @nodoc
abstract mixin class _$ToolingConfigAnyCopyWith<$Res> implements $ToolingConfigCopyWith<$Res> {
  factory _$ToolingConfigAnyCopyWith(_ToolingConfigAny value, $Res Function(_ToolingConfigAny) _then) = __$ToolingConfigAnyCopyWithImpl;
@useResult
$Res call({
 Set<String> allowedFunctionNames
});




}
/// @nodoc
class __$ToolingConfigAnyCopyWithImpl<$Res>
    implements _$ToolingConfigAnyCopyWith<$Res> {
  __$ToolingConfigAnyCopyWithImpl(this._self, this._then);

  final _ToolingConfigAny _self;
  final $Res Function(_ToolingConfigAny) _then;

/// Create a copy of ToolingConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? allowedFunctionNames = null,}) {
  return _then(_ToolingConfigAny(
null == allowedFunctionNames ? _self._allowedFunctionNames : allowedFunctionNames // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc


class _ToolingConfigNone extends ToolingConfig {
  const _ToolingConfigNone(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToolingConfigNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ToolingConfig.none()';
}


}




// dart format on
