// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompt_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PromptTemplate {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromptTemplate);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PromptTemplate()';
}


}

/// @nodoc
class $PromptTemplateCopyWith<$Res>  {
$PromptTemplateCopyWith(PromptTemplate _, $Res Function(PromptTemplate) __);
}


/// Adds pattern-matching-related methods to [PromptTemplate].
extension PromptTemplatePatterns on PromptTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SystemPromptTemplate value)?  system,TResult Function( _BuildParallelPromptTemplate value)?  buildParallel,TResult Function( _BuildSequentialPromptTemplate value)?  buildSequential,TResult Function( _InputPromptTemplate value)?  input,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemPromptTemplate() when system != null:
return system(_that);case _BuildParallelPromptTemplate() when buildParallel != null:
return buildParallel(_that);case _BuildSequentialPromptTemplate() when buildSequential != null:
return buildSequential(_that);case _InputPromptTemplate() when input != null:
return input(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SystemPromptTemplate value)  system,required TResult Function( _BuildParallelPromptTemplate value)  buildParallel,required TResult Function( _BuildSequentialPromptTemplate value)  buildSequential,required TResult Function( _InputPromptTemplate value)  input,}){
final _that = this;
switch (_that) {
case _SystemPromptTemplate():
return system(_that);case _BuildParallelPromptTemplate():
return buildParallel(_that);case _BuildSequentialPromptTemplate():
return buildSequential(_that);case _InputPromptTemplate():
return input(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SystemPromptTemplate value)?  system,TResult? Function( _BuildParallelPromptTemplate value)?  buildParallel,TResult? Function( _BuildSequentialPromptTemplate value)?  buildSequential,TResult? Function( _InputPromptTemplate value)?  input,}){
final _that = this;
switch (_that) {
case _SystemPromptTemplate() when system != null:
return system(_that);case _BuildParallelPromptTemplate() when buildParallel != null:
return buildParallel(_that);case _BuildSequentialPromptTemplate() when buildSequential != null:
return buildSequential(_that);case _InputPromptTemplate() when input != null:
return input(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  system,TResult Function( ParallelContextBuilder builder)?  buildParallel,TResult Function( SequentialContextBuilder builder)?  buildSequential,TResult Function( FutureOr<String> Function(String raw)? prompt)?  input,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemPromptTemplate() when system != null:
return system(_that.text);case _BuildParallelPromptTemplate() when buildParallel != null:
return buildParallel(_that.builder);case _BuildSequentialPromptTemplate() when buildSequential != null:
return buildSequential(_that.builder);case _InputPromptTemplate() when input != null:
return input(_that.prompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  system,required TResult Function( ParallelContextBuilder builder)  buildParallel,required TResult Function( SequentialContextBuilder builder)  buildSequential,required TResult Function( FutureOr<String> Function(String raw)? prompt)  input,}) {final _that = this;
switch (_that) {
case _SystemPromptTemplate():
return system(_that.text);case _BuildParallelPromptTemplate():
return buildParallel(_that.builder);case _BuildSequentialPromptTemplate():
return buildSequential(_that.builder);case _InputPromptTemplate():
return input(_that.prompt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  system,TResult? Function( ParallelContextBuilder builder)?  buildParallel,TResult? Function( SequentialContextBuilder builder)?  buildSequential,TResult? Function( FutureOr<String> Function(String raw)? prompt)?  input,}) {final _that = this;
switch (_that) {
case _SystemPromptTemplate() when system != null:
return system(_that.text);case _BuildParallelPromptTemplate() when buildParallel != null:
return buildParallel(_that.builder);case _BuildSequentialPromptTemplate() when buildSequential != null:
return buildSequential(_that.builder);case _InputPromptTemplate() when input != null:
return input(_that.prompt);case _:
  return null;

}
}

}

/// @nodoc


class _SystemPromptTemplate extends PromptTemplate {
  const _SystemPromptTemplate(this.text): super._();
  

 final  String text;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemPromptTemplateCopyWith<_SystemPromptTemplate> get copyWith => __$SystemPromptTemplateCopyWithImpl<_SystemPromptTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemPromptTemplate&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'PromptTemplate.system(text: $text)';
}


}

/// @nodoc
abstract mixin class _$SystemPromptTemplateCopyWith<$Res> implements $PromptTemplateCopyWith<$Res> {
  factory _$SystemPromptTemplateCopyWith(_SystemPromptTemplate value, $Res Function(_SystemPromptTemplate) _then) = __$SystemPromptTemplateCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class __$SystemPromptTemplateCopyWithImpl<$Res>
    implements _$SystemPromptTemplateCopyWith<$Res> {
  __$SystemPromptTemplateCopyWithImpl(this._self, this._then);

  final _SystemPromptTemplate _self;
  final $Res Function(_SystemPromptTemplate) _then;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(_SystemPromptTemplate(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _BuildParallelPromptTemplate extends PromptTemplate {
  const _BuildParallelPromptTemplate(this.builder): super._();
  

 final  ParallelContextBuilder builder;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildParallelPromptTemplateCopyWith<_BuildParallelPromptTemplate> get copyWith => __$BuildParallelPromptTemplateCopyWithImpl<_BuildParallelPromptTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildParallelPromptTemplate&&(identical(other.builder, builder) || other.builder == builder));
}


@override
int get hashCode => Object.hash(runtimeType,builder);

@override
String toString() {
  return 'PromptTemplate.buildParallel(builder: $builder)';
}


}

/// @nodoc
abstract mixin class _$BuildParallelPromptTemplateCopyWith<$Res> implements $PromptTemplateCopyWith<$Res> {
  factory _$BuildParallelPromptTemplateCopyWith(_BuildParallelPromptTemplate value, $Res Function(_BuildParallelPromptTemplate) _then) = __$BuildParallelPromptTemplateCopyWithImpl;
@useResult
$Res call({
 ParallelContextBuilder builder
});




}
/// @nodoc
class __$BuildParallelPromptTemplateCopyWithImpl<$Res>
    implements _$BuildParallelPromptTemplateCopyWith<$Res> {
  __$BuildParallelPromptTemplateCopyWithImpl(this._self, this._then);

  final _BuildParallelPromptTemplate _self;
  final $Res Function(_BuildParallelPromptTemplate) _then;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? builder = null,}) {
  return _then(_BuildParallelPromptTemplate(
null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as ParallelContextBuilder,
  ));
}


}

/// @nodoc


class _BuildSequentialPromptTemplate extends PromptTemplate {
  const _BuildSequentialPromptTemplate(this.builder): super._();
  

 final  SequentialContextBuilder builder;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildSequentialPromptTemplateCopyWith<_BuildSequentialPromptTemplate> get copyWith => __$BuildSequentialPromptTemplateCopyWithImpl<_BuildSequentialPromptTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildSequentialPromptTemplate&&(identical(other.builder, builder) || other.builder == builder));
}


@override
int get hashCode => Object.hash(runtimeType,builder);

@override
String toString() {
  return 'PromptTemplate.buildSequential(builder: $builder)';
}


}

/// @nodoc
abstract mixin class _$BuildSequentialPromptTemplateCopyWith<$Res> implements $PromptTemplateCopyWith<$Res> {
  factory _$BuildSequentialPromptTemplateCopyWith(_BuildSequentialPromptTemplate value, $Res Function(_BuildSequentialPromptTemplate) _then) = __$BuildSequentialPromptTemplateCopyWithImpl;
@useResult
$Res call({
 SequentialContextBuilder builder
});




}
/// @nodoc
class __$BuildSequentialPromptTemplateCopyWithImpl<$Res>
    implements _$BuildSequentialPromptTemplateCopyWith<$Res> {
  __$BuildSequentialPromptTemplateCopyWithImpl(this._self, this._then);

  final _BuildSequentialPromptTemplate _self;
  final $Res Function(_BuildSequentialPromptTemplate) _then;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? builder = null,}) {
  return _then(_BuildSequentialPromptTemplate(
null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as SequentialContextBuilder,
  ));
}


}

/// @nodoc


class _InputPromptTemplate extends PromptTemplate {
  const _InputPromptTemplate([this.prompt]): super._();
  

 final  FutureOr<String> Function(String raw)? prompt;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InputPromptTemplateCopyWith<_InputPromptTemplate> get copyWith => __$InputPromptTemplateCopyWithImpl<_InputPromptTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InputPromptTemplate&&(identical(other.prompt, prompt) || other.prompt == prompt));
}


@override
int get hashCode => Object.hash(runtimeType,prompt);

@override
String toString() {
  return 'PromptTemplate.input(prompt: $prompt)';
}


}

/// @nodoc
abstract mixin class _$InputPromptTemplateCopyWith<$Res> implements $PromptTemplateCopyWith<$Res> {
  factory _$InputPromptTemplateCopyWith(_InputPromptTemplate value, $Res Function(_InputPromptTemplate) _then) = __$InputPromptTemplateCopyWithImpl;
@useResult
$Res call({
 FutureOr<String> Function(String raw)? prompt
});




}
/// @nodoc
class __$InputPromptTemplateCopyWithImpl<$Res>
    implements _$InputPromptTemplateCopyWith<$Res> {
  __$InputPromptTemplateCopyWithImpl(this._self, this._then);

  final _InputPromptTemplate _self;
  final $Res Function(_InputPromptTemplate) _then;

/// Create a copy of PromptTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prompt = freezed,}) {
  return _then(_InputPromptTemplate(
freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as FutureOr<String> Function(String raw)?,
  ));
}


}

// dart format on
