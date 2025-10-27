// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_execute_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenerationExecuteConfig {

 List<ToolSchema> get tools; ToolingConfig? get toolingConfig; Map<String, dynamic>? get config;
/// Create a copy of GenerationExecuteConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationExecuteConfigCopyWith<GenerationExecuteConfig> get copyWith => _$GenerationExecuteConfigCopyWithImpl<GenerationExecuteConfig>(this as GenerationExecuteConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationExecuteConfig&&const DeepCollectionEquality().equals(other.tools, tools)&&(identical(other.toolingConfig, toolingConfig) || other.toolingConfig == toolingConfig)&&const DeepCollectionEquality().equals(other.config, config));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tools),toolingConfig,const DeepCollectionEquality().hash(config));

@override
String toString() {
  return 'GenerationExecuteConfig(tools: $tools, toolingConfig: $toolingConfig, config: $config)';
}


}

/// @nodoc
abstract mixin class $GenerationExecuteConfigCopyWith<$Res>  {
  factory $GenerationExecuteConfigCopyWith(GenerationExecuteConfig value, $Res Function(GenerationExecuteConfig) _then) = _$GenerationExecuteConfigCopyWithImpl;
@useResult
$Res call({
 List<ToolSchema> tools, ToolingConfig? toolingConfig, Map<String, dynamic>? config
});


$ToolingConfigCopyWith<$Res>? get toolingConfig;

}
/// @nodoc
class _$GenerationExecuteConfigCopyWithImpl<$Res>
    implements $GenerationExecuteConfigCopyWith<$Res> {
  _$GenerationExecuteConfigCopyWithImpl(this._self, this._then);

  final GenerationExecuteConfig _self;
  final $Res Function(GenerationExecuteConfig) _then;

/// Create a copy of GenerationExecuteConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tools = null,Object? toolingConfig = freezed,Object? config = freezed,}) {
  return _then(_self.copyWith(
tools: null == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolSchema>,toolingConfig: freezed == toolingConfig ? _self.toolingConfig : toolingConfig // ignore: cast_nullable_to_non_nullable
as ToolingConfig?,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of GenerationExecuteConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToolingConfigCopyWith<$Res>? get toolingConfig {
    if (_self.toolingConfig == null) {
    return null;
  }

  return $ToolingConfigCopyWith<$Res>(_self.toolingConfig!, (value) {
    return _then(_self.copyWith(toolingConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [GenerationExecuteConfig].
extension GenerationExecuteConfigPatterns on GenerationExecuteConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerationExecuteConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerationExecuteConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerationExecuteConfig value)  $default,){
final _that = this;
switch (_that) {
case _GenerationExecuteConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerationExecuteConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GenerationExecuteConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ToolSchema> tools,  ToolingConfig? toolingConfig,  Map<String, dynamic>? config)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationExecuteConfig() when $default != null:
return $default(_that.tools,_that.toolingConfig,_that.config);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ToolSchema> tools,  ToolingConfig? toolingConfig,  Map<String, dynamic>? config)  $default,) {final _that = this;
switch (_that) {
case _GenerationExecuteConfig():
return $default(_that.tools,_that.toolingConfig,_that.config);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ToolSchema> tools,  ToolingConfig? toolingConfig,  Map<String, dynamic>? config)?  $default,) {final _that = this;
switch (_that) {
case _GenerationExecuteConfig() when $default != null:
return $default(_that.tools,_that.toolingConfig,_that.config);case _:
  return null;

}
}

}

/// @nodoc


class _GenerationExecuteConfig extends GenerationExecuteConfig {
  const _GenerationExecuteConfig({final  List<ToolSchema> tools = const [], this.toolingConfig, final  Map<String, dynamic>? config}): _tools = tools,_config = config,super._();
  

 final  List<ToolSchema> _tools;
@override@JsonKey() List<ToolSchema> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}

@override final  ToolingConfig? toolingConfig;
 final  Map<String, dynamic>? _config;
@override Map<String, dynamic>? get config {
  final value = _config;
  if (value == null) return null;
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GenerationExecuteConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationExecuteConfigCopyWith<_GenerationExecuteConfig> get copyWith => __$GenerationExecuteConfigCopyWithImpl<_GenerationExecuteConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationExecuteConfig&&const DeepCollectionEquality().equals(other._tools, _tools)&&(identical(other.toolingConfig, toolingConfig) || other.toolingConfig == toolingConfig)&&const DeepCollectionEquality().equals(other._config, _config));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tools),toolingConfig,const DeepCollectionEquality().hash(_config));

@override
String toString() {
  return 'GenerationExecuteConfig(tools: $tools, toolingConfig: $toolingConfig, config: $config)';
}


}

/// @nodoc
abstract mixin class _$GenerationExecuteConfigCopyWith<$Res> implements $GenerationExecuteConfigCopyWith<$Res> {
  factory _$GenerationExecuteConfigCopyWith(_GenerationExecuteConfig value, $Res Function(_GenerationExecuteConfig) _then) = __$GenerationExecuteConfigCopyWithImpl;
@override @useResult
$Res call({
 List<ToolSchema> tools, ToolingConfig? toolingConfig, Map<String, dynamic>? config
});


@override $ToolingConfigCopyWith<$Res>? get toolingConfig;

}
/// @nodoc
class __$GenerationExecuteConfigCopyWithImpl<$Res>
    implements _$GenerationExecuteConfigCopyWith<$Res> {
  __$GenerationExecuteConfigCopyWithImpl(this._self, this._then);

  final _GenerationExecuteConfig _self;
  final $Res Function(_GenerationExecuteConfig) _then;

/// Create a copy of GenerationExecuteConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tools = null,Object? toolingConfig = freezed,Object? config = freezed,}) {
  return _then(_GenerationExecuteConfig(
tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolSchema>,toolingConfig: freezed == toolingConfig ? _self.toolingConfig : toolingConfig // ignore: cast_nullable_to_non_nullable
as ToolingConfig?,config: freezed == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of GenerationExecuteConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToolingConfigCopyWith<$Res>? get toolingConfig {
    if (_self.toolingConfig == null) {
    return null;
  }

  return $ToolingConfigCopyWith<$Res>(_self.toolingConfig!, (value) {
    return _then(_self.copyWith(toolingConfig: value));
  });
}
}

// dart format on
