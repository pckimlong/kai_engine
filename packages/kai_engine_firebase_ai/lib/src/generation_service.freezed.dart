// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenerativeConfig {

 String get model; List<SafetySetting>? get safetySettings; GenerationConfig? get generationConfig; List<FirebaseAiToolSchema>? get toolSchemas; ToolingConfig? get toolConfig; String? get systemPrompt;
/// Create a copy of GenerativeConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerativeConfigCopyWith<GenerativeConfig> get copyWith => _$GenerativeConfigCopyWithImpl<GenerativeConfig>(this as GenerativeConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerativeConfig&&(identical(other.model, model) || other.model == model)&&const DeepCollectionEquality().equals(other.safetySettings, safetySettings)&&(identical(other.generationConfig, generationConfig) || other.generationConfig == generationConfig)&&const DeepCollectionEquality().equals(other.toolSchemas, toolSchemas)&&(identical(other.toolConfig, toolConfig) || other.toolConfig == toolConfig)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt));
}


@override
int get hashCode => Object.hash(runtimeType,model,const DeepCollectionEquality().hash(safetySettings),generationConfig,const DeepCollectionEquality().hash(toolSchemas),toolConfig,systemPrompt);

@override
String toString() {
  return 'GenerativeConfig(model: $model, safetySettings: $safetySettings, generationConfig: $generationConfig, toolSchemas: $toolSchemas, toolConfig: $toolConfig, systemPrompt: $systemPrompt)';
}


}

/// @nodoc
abstract mixin class $GenerativeConfigCopyWith<$Res>  {
  factory $GenerativeConfigCopyWith(GenerativeConfig value, $Res Function(GenerativeConfig) _then) = _$GenerativeConfigCopyWithImpl;
@useResult
$Res call({
 String model, List<SafetySetting>? safetySettings, GenerationConfig? generationConfig, List<FirebaseAiToolSchema>? toolSchemas, ToolingConfig? toolConfig, String? systemPrompt
});


$ToolingConfigCopyWith<$Res>? get toolConfig;

}
/// @nodoc
class _$GenerativeConfigCopyWithImpl<$Res>
    implements $GenerativeConfigCopyWith<$Res> {
  _$GenerativeConfigCopyWithImpl(this._self, this._then);

  final GenerativeConfig _self;
  final $Res Function(GenerativeConfig) _then;

/// Create a copy of GenerativeConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? model = null,Object? safetySettings = freezed,Object? generationConfig = freezed,Object? toolSchemas = freezed,Object? toolConfig = freezed,Object? systemPrompt = freezed,}) {
  return _then(_self.copyWith(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,safetySettings: freezed == safetySettings ? _self.safetySettings : safetySettings // ignore: cast_nullable_to_non_nullable
as List<SafetySetting>?,generationConfig: freezed == generationConfig ? _self.generationConfig : generationConfig // ignore: cast_nullable_to_non_nullable
as GenerationConfig?,toolSchemas: freezed == toolSchemas ? _self.toolSchemas : toolSchemas // ignore: cast_nullable_to_non_nullable
as List<FirebaseAiToolSchema>?,toolConfig: freezed == toolConfig ? _self.toolConfig : toolConfig // ignore: cast_nullable_to_non_nullable
as ToolingConfig?,systemPrompt: freezed == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GenerativeConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToolingConfigCopyWith<$Res>? get toolConfig {
    if (_self.toolConfig == null) {
    return null;
  }

  return $ToolingConfigCopyWith<$Res>(_self.toolConfig!, (value) {
    return _then(_self.copyWith(toolConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [GenerativeConfig].
extension GenerativeConfigPatterns on GenerativeConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerativeConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerativeConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerativeConfig value)  $default,){
final _that = this;
switch (_that) {
case _GenerativeConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerativeConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GenerativeConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String model,  List<SafetySetting>? safetySettings,  GenerationConfig? generationConfig,  List<FirebaseAiToolSchema>? toolSchemas,  ToolingConfig? toolConfig,  String? systemPrompt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerativeConfig() when $default != null:
return $default(_that.model,_that.safetySettings,_that.generationConfig,_that.toolSchemas,_that.toolConfig,_that.systemPrompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String model,  List<SafetySetting>? safetySettings,  GenerationConfig? generationConfig,  List<FirebaseAiToolSchema>? toolSchemas,  ToolingConfig? toolConfig,  String? systemPrompt)  $default,) {final _that = this;
switch (_that) {
case _GenerativeConfig():
return $default(_that.model,_that.safetySettings,_that.generationConfig,_that.toolSchemas,_that.toolConfig,_that.systemPrompt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String model,  List<SafetySetting>? safetySettings,  GenerationConfig? generationConfig,  List<FirebaseAiToolSchema>? toolSchemas,  ToolingConfig? toolConfig,  String? systemPrompt)?  $default,) {final _that = this;
switch (_that) {
case _GenerativeConfig() when $default != null:
return $default(_that.model,_that.safetySettings,_that.generationConfig,_that.toolSchemas,_that.toolConfig,_that.systemPrompt);case _:
  return null;

}
}

}

/// @nodoc


class _GenerativeConfig extends GenerativeConfig {
  const _GenerativeConfig({required this.model, final  List<SafetySetting>? safetySettings, this.generationConfig, final  List<FirebaseAiToolSchema>? toolSchemas, this.toolConfig, this.systemPrompt}): _safetySettings = safetySettings,_toolSchemas = toolSchemas,super._();
  

@override final  String model;
 final  List<SafetySetting>? _safetySettings;
@override List<SafetySetting>? get safetySettings {
  final value = _safetySettings;
  if (value == null) return null;
  if (_safetySettings is EqualUnmodifiableListView) return _safetySettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  GenerationConfig? generationConfig;
 final  List<FirebaseAiToolSchema>? _toolSchemas;
@override List<FirebaseAiToolSchema>? get toolSchemas {
  final value = _toolSchemas;
  if (value == null) return null;
  if (_toolSchemas is EqualUnmodifiableListView) return _toolSchemas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  ToolingConfig? toolConfig;
@override final  String? systemPrompt;

/// Create a copy of GenerativeConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerativeConfigCopyWith<_GenerativeConfig> get copyWith => __$GenerativeConfigCopyWithImpl<_GenerativeConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerativeConfig&&(identical(other.model, model) || other.model == model)&&const DeepCollectionEquality().equals(other._safetySettings, _safetySettings)&&(identical(other.generationConfig, generationConfig) || other.generationConfig == generationConfig)&&const DeepCollectionEquality().equals(other._toolSchemas, _toolSchemas)&&(identical(other.toolConfig, toolConfig) || other.toolConfig == toolConfig)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt));
}


@override
int get hashCode => Object.hash(runtimeType,model,const DeepCollectionEquality().hash(_safetySettings),generationConfig,const DeepCollectionEquality().hash(_toolSchemas),toolConfig,systemPrompt);

@override
String toString() {
  return 'GenerativeConfig(model: $model, safetySettings: $safetySettings, generationConfig: $generationConfig, toolSchemas: $toolSchemas, toolConfig: $toolConfig, systemPrompt: $systemPrompt)';
}


}

/// @nodoc
abstract mixin class _$GenerativeConfigCopyWith<$Res> implements $GenerativeConfigCopyWith<$Res> {
  factory _$GenerativeConfigCopyWith(_GenerativeConfig value, $Res Function(_GenerativeConfig) _then) = __$GenerativeConfigCopyWithImpl;
@override @useResult
$Res call({
 String model, List<SafetySetting>? safetySettings, GenerationConfig? generationConfig, List<FirebaseAiToolSchema>? toolSchemas, ToolingConfig? toolConfig, String? systemPrompt
});


@override $ToolingConfigCopyWith<$Res>? get toolConfig;

}
/// @nodoc
class __$GenerativeConfigCopyWithImpl<$Res>
    implements _$GenerativeConfigCopyWith<$Res> {
  __$GenerativeConfigCopyWithImpl(this._self, this._then);

  final _GenerativeConfig _self;
  final $Res Function(_GenerativeConfig) _then;

/// Create a copy of GenerativeConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? model = null,Object? safetySettings = freezed,Object? generationConfig = freezed,Object? toolSchemas = freezed,Object? toolConfig = freezed,Object? systemPrompt = freezed,}) {
  return _then(_GenerativeConfig(
model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,safetySettings: freezed == safetySettings ? _self._safetySettings : safetySettings // ignore: cast_nullable_to_non_nullable
as List<SafetySetting>?,generationConfig: freezed == generationConfig ? _self.generationConfig : generationConfig // ignore: cast_nullable_to_non_nullable
as GenerationConfig?,toolSchemas: freezed == toolSchemas ? _self._toolSchemas : toolSchemas // ignore: cast_nullable_to_non_nullable
as List<FirebaseAiToolSchema>?,toolConfig: freezed == toolConfig ? _self.toolConfig : toolConfig // ignore: cast_nullable_to_non_nullable
as ToolingConfig?,systemPrompt: freezed == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GenerativeConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToolingConfigCopyWith<$Res>? get toolConfig {
    if (_self.toolConfig == null) {
    return null;
  }

  return $ToolingConfigCopyWith<$Res>(_self.toolConfig!, (value) {
    return _then(_self.copyWith(toolConfig: value));
  });
}
}

// dart format on
