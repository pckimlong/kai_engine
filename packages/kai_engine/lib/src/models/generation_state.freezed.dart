// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoadingPhase {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingPhase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoadingPhase()';
}


}

/// @nodoc
class $LoadingPhaseCopyWith<$Res>  {
$LoadingPhaseCopyWith(LoadingPhase _, $Res Function(LoadingPhase) __);
}


/// Adds pattern-matching-related methods to [LoadingPhase].
extension LoadingPhasePatterns on LoadingPhase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DefaultLoadingPhase value)?  initial,TResult Function( _ProcessingQueryPhase value)?  processingQuery,TResult Function( _BuildingContextPhase value)?  buildContext,TResult Function( _BuildingResponsePhase value)?  buildingResponse,TResult Function( _GeneratingResponsePhase value)?  generatingResponse,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DefaultLoadingPhase() when initial != null:
return initial(_that);case _ProcessingQueryPhase() when processingQuery != null:
return processingQuery(_that);case _BuildingContextPhase() when buildContext != null:
return buildContext(_that);case _BuildingResponsePhase() when buildingResponse != null:
return buildingResponse(_that);case _GeneratingResponsePhase() when generatingResponse != null:
return generatingResponse(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DefaultLoadingPhase value)  initial,required TResult Function( _ProcessingQueryPhase value)  processingQuery,required TResult Function( _BuildingContextPhase value)  buildContext,required TResult Function( _BuildingResponsePhase value)  buildingResponse,required TResult Function( _GeneratingResponsePhase value)  generatingResponse,}){
final _that = this;
switch (_that) {
case _DefaultLoadingPhase():
return initial(_that);case _ProcessingQueryPhase():
return processingQuery(_that);case _BuildingContextPhase():
return buildContext(_that);case _BuildingResponsePhase():
return buildingResponse(_that);case _GeneratingResponsePhase():
return generatingResponse(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DefaultLoadingPhase value)?  initial,TResult? Function( _ProcessingQueryPhase value)?  processingQuery,TResult? Function( _BuildingContextPhase value)?  buildContext,TResult? Function( _BuildingResponsePhase value)?  buildingResponse,TResult? Function( _GeneratingResponsePhase value)?  generatingResponse,}){
final _that = this;
switch (_that) {
case _DefaultLoadingPhase() when initial != null:
return initial(_that);case _ProcessingQueryPhase() when processingQuery != null:
return processingQuery(_that);case _BuildingContextPhase() when buildContext != null:
return buildContext(_that);case _BuildingResponsePhase() when buildingResponse != null:
return buildingResponse(_that);case _GeneratingResponsePhase() when generatingResponse != null:
return generatingResponse(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( String? stageName)?  processingQuery,TResult Function( String? stageName)?  buildContext,TResult Function( String? stageName)?  buildingResponse,TResult Function( String? stageName,  String? message)?  generatingResponse,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DefaultLoadingPhase() when initial != null:
return initial();case _ProcessingQueryPhase() when processingQuery != null:
return processingQuery(_that.stageName);case _BuildingContextPhase() when buildContext != null:
return buildContext(_that.stageName);case _BuildingResponsePhase() when buildingResponse != null:
return buildingResponse(_that.stageName);case _GeneratingResponsePhase() when generatingResponse != null:
return generatingResponse(_that.stageName,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( String? stageName)  processingQuery,required TResult Function( String? stageName)  buildContext,required TResult Function( String? stageName)  buildingResponse,required TResult Function( String? stageName,  String? message)  generatingResponse,}) {final _that = this;
switch (_that) {
case _DefaultLoadingPhase():
return initial();case _ProcessingQueryPhase():
return processingQuery(_that.stageName);case _BuildingContextPhase():
return buildContext(_that.stageName);case _BuildingResponsePhase():
return buildingResponse(_that.stageName);case _GeneratingResponsePhase():
return generatingResponse(_that.stageName,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( String? stageName)?  processingQuery,TResult? Function( String? stageName)?  buildContext,TResult? Function( String? stageName)?  buildingResponse,TResult? Function( String? stageName,  String? message)?  generatingResponse,}) {final _that = this;
switch (_that) {
case _DefaultLoadingPhase() when initial != null:
return initial();case _ProcessingQueryPhase() when processingQuery != null:
return processingQuery(_that.stageName);case _BuildingContextPhase() when buildContext != null:
return buildContext(_that.stageName);case _BuildingResponsePhase() when buildingResponse != null:
return buildingResponse(_that.stageName);case _GeneratingResponsePhase() when generatingResponse != null:
return generatingResponse(_that.stageName,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _DefaultLoadingPhase extends LoadingPhase {
  const _DefaultLoadingPhase(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DefaultLoadingPhase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoadingPhase.initial()';
}


}




/// @nodoc


class _ProcessingQueryPhase extends LoadingPhase {
  const _ProcessingQueryPhase([this.stageName]): super._();
  

 final  String? stageName;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessingQueryPhaseCopyWith<_ProcessingQueryPhase> get copyWith => __$ProcessingQueryPhaseCopyWithImpl<_ProcessingQueryPhase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessingQueryPhase&&(identical(other.stageName, stageName) || other.stageName == stageName));
}


@override
int get hashCode => Object.hash(runtimeType,stageName);

@override
String toString() {
  return 'LoadingPhase.processingQuery(stageName: $stageName)';
}


}

/// @nodoc
abstract mixin class _$ProcessingQueryPhaseCopyWith<$Res> implements $LoadingPhaseCopyWith<$Res> {
  factory _$ProcessingQueryPhaseCopyWith(_ProcessingQueryPhase value, $Res Function(_ProcessingQueryPhase) _then) = __$ProcessingQueryPhaseCopyWithImpl;
@useResult
$Res call({
 String? stageName
});




}
/// @nodoc
class __$ProcessingQueryPhaseCopyWithImpl<$Res>
    implements _$ProcessingQueryPhaseCopyWith<$Res> {
  __$ProcessingQueryPhaseCopyWithImpl(this._self, this._then);

  final _ProcessingQueryPhase _self;
  final $Res Function(_ProcessingQueryPhase) _then;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stageName = freezed,}) {
  return _then(_ProcessingQueryPhase(
freezed == stageName ? _self.stageName : stageName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _BuildingContextPhase extends LoadingPhase {
  const _BuildingContextPhase([this.stageName]): super._();
  

 final  String? stageName;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildingContextPhaseCopyWith<_BuildingContextPhase> get copyWith => __$BuildingContextPhaseCopyWithImpl<_BuildingContextPhase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildingContextPhase&&(identical(other.stageName, stageName) || other.stageName == stageName));
}


@override
int get hashCode => Object.hash(runtimeType,stageName);

@override
String toString() {
  return 'LoadingPhase.buildContext(stageName: $stageName)';
}


}

/// @nodoc
abstract mixin class _$BuildingContextPhaseCopyWith<$Res> implements $LoadingPhaseCopyWith<$Res> {
  factory _$BuildingContextPhaseCopyWith(_BuildingContextPhase value, $Res Function(_BuildingContextPhase) _then) = __$BuildingContextPhaseCopyWithImpl;
@useResult
$Res call({
 String? stageName
});




}
/// @nodoc
class __$BuildingContextPhaseCopyWithImpl<$Res>
    implements _$BuildingContextPhaseCopyWith<$Res> {
  __$BuildingContextPhaseCopyWithImpl(this._self, this._then);

  final _BuildingContextPhase _self;
  final $Res Function(_BuildingContextPhase) _then;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stageName = freezed,}) {
  return _then(_BuildingContextPhase(
freezed == stageName ? _self.stageName : stageName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _BuildingResponsePhase extends LoadingPhase {
  const _BuildingResponsePhase([this.stageName]): super._();
  

 final  String? stageName;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuildingResponsePhaseCopyWith<_BuildingResponsePhase> get copyWith => __$BuildingResponsePhaseCopyWithImpl<_BuildingResponsePhase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuildingResponsePhase&&(identical(other.stageName, stageName) || other.stageName == stageName));
}


@override
int get hashCode => Object.hash(runtimeType,stageName);

@override
String toString() {
  return 'LoadingPhase.buildingResponse(stageName: $stageName)';
}


}

/// @nodoc
abstract mixin class _$BuildingResponsePhaseCopyWith<$Res> implements $LoadingPhaseCopyWith<$Res> {
  factory _$BuildingResponsePhaseCopyWith(_BuildingResponsePhase value, $Res Function(_BuildingResponsePhase) _then) = __$BuildingResponsePhaseCopyWithImpl;
@useResult
$Res call({
 String? stageName
});




}
/// @nodoc
class __$BuildingResponsePhaseCopyWithImpl<$Res>
    implements _$BuildingResponsePhaseCopyWith<$Res> {
  __$BuildingResponsePhaseCopyWithImpl(this._self, this._then);

  final _BuildingResponsePhase _self;
  final $Res Function(_BuildingResponsePhase) _then;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stageName = freezed,}) {
  return _then(_BuildingResponsePhase(
freezed == stageName ? _self.stageName : stageName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _GeneratingResponsePhase extends LoadingPhase {
  const _GeneratingResponsePhase([this.stageName, this.message]): super._();
  

 final  String? stageName;
 final  String? message;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratingResponsePhaseCopyWith<_GeneratingResponsePhase> get copyWith => __$GeneratingResponsePhaseCopyWithImpl<_GeneratingResponsePhase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratingResponsePhase&&(identical(other.stageName, stageName) || other.stageName == stageName)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,stageName,message);

@override
String toString() {
  return 'LoadingPhase.generatingResponse(stageName: $stageName, message: $message)';
}


}

/// @nodoc
abstract mixin class _$GeneratingResponsePhaseCopyWith<$Res> implements $LoadingPhaseCopyWith<$Res> {
  factory _$GeneratingResponsePhaseCopyWith(_GeneratingResponsePhase value, $Res Function(_GeneratingResponsePhase) _then) = __$GeneratingResponsePhaseCopyWithImpl;
@useResult
$Res call({
 String? stageName, String? message
});




}
/// @nodoc
class __$GeneratingResponsePhaseCopyWithImpl<$Res>
    implements _$GeneratingResponsePhaseCopyWith<$Res> {
  __$GeneratingResponsePhaseCopyWithImpl(this._self, this._then);

  final _GeneratingResponsePhase _self;
  final $Res Function(_GeneratingResponsePhase) _then;

/// Create a copy of LoadingPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stageName = freezed,Object? message = freezed,}) {
  return _then(_GeneratingResponsePhase(
freezed == stageName ? _self.stageName : stageName // ignore: cast_nullable_to_non_nullable
as String?,freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$GenerationState<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GenerationState<$T>()';
}


}

/// @nodoc
class $GenerationStateCopyWith<T,$Res>  {
$GenerationStateCopyWith(GenerationState<T> _, $Res Function(GenerationState<T>) __);
}


/// Adds pattern-matching-related methods to [GenerationState].
extension GenerationStatePatterns<T> on GenerationState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GenerationInitialState<T> value)?  initial,TResult Function( GenerationLoadingState<T> value)?  loading,TResult Function( GenerationStreamingTextState<T> value)?  streamingText,TResult Function( GenerationFunctionCallingState<T> value)?  functionCalling,TResult Function( GenerationCompleteState<T> value)?  complete,TResult Function( GenerationErrorState<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GenerationInitialState() when initial != null:
return initial(_that);case GenerationLoadingState() when loading != null:
return loading(_that);case GenerationStreamingTextState() when streamingText != null:
return streamingText(_that);case GenerationFunctionCallingState() when functionCalling != null:
return functionCalling(_that);case GenerationCompleteState() when complete != null:
return complete(_that);case GenerationErrorState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GenerationInitialState<T> value)  initial,required TResult Function( GenerationLoadingState<T> value)  loading,required TResult Function( GenerationStreamingTextState<T> value)  streamingText,required TResult Function( GenerationFunctionCallingState<T> value)  functionCalling,required TResult Function( GenerationCompleteState<T> value)  complete,required TResult Function( GenerationErrorState<T> value)  error,}){
final _that = this;
switch (_that) {
case GenerationInitialState():
return initial(_that);case GenerationLoadingState():
return loading(_that);case GenerationStreamingTextState():
return streamingText(_that);case GenerationFunctionCallingState():
return functionCalling(_that);case GenerationCompleteState():
return complete(_that);case GenerationErrorState():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GenerationInitialState<T> value)?  initial,TResult? Function( GenerationLoadingState<T> value)?  loading,TResult? Function( GenerationStreamingTextState<T> value)?  streamingText,TResult? Function( GenerationFunctionCallingState<T> value)?  functionCalling,TResult? Function( GenerationCompleteState<T> value)?  complete,TResult? Function( GenerationErrorState<T> value)?  error,}){
final _that = this;
switch (_that) {
case GenerationInitialState() when initial != null:
return initial(_that);case GenerationLoadingState() when loading != null:
return loading(_that);case GenerationStreamingTextState() when streamingText != null:
return streamingText(_that);case GenerationFunctionCallingState() when functionCalling != null:
return functionCalling(_that);case GenerationCompleteState() when complete != null:
return complete(_that);case GenerationErrorState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( LoadingPhase phase)?  loading,TResult Function( String text)?  streamingText,TResult Function( String names)?  functionCalling,TResult Function( T result)?  complete,TResult Function( KaiException exception)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GenerationInitialState() when initial != null:
return initial();case GenerationLoadingState() when loading != null:
return loading(_that.phase);case GenerationStreamingTextState() when streamingText != null:
return streamingText(_that.text);case GenerationFunctionCallingState() when functionCalling != null:
return functionCalling(_that.names);case GenerationCompleteState() when complete != null:
return complete(_that.result);case GenerationErrorState() when error != null:
return error(_that.exception);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( LoadingPhase phase)  loading,required TResult Function( String text)  streamingText,required TResult Function( String names)  functionCalling,required TResult Function( T result)  complete,required TResult Function( KaiException exception)  error,}) {final _that = this;
switch (_that) {
case GenerationInitialState():
return initial();case GenerationLoadingState():
return loading(_that.phase);case GenerationStreamingTextState():
return streamingText(_that.text);case GenerationFunctionCallingState():
return functionCalling(_that.names);case GenerationCompleteState():
return complete(_that.result);case GenerationErrorState():
return error(_that.exception);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( LoadingPhase phase)?  loading,TResult? Function( String text)?  streamingText,TResult? Function( String names)?  functionCalling,TResult? Function( T result)?  complete,TResult? Function( KaiException exception)?  error,}) {final _that = this;
switch (_that) {
case GenerationInitialState() when initial != null:
return initial();case GenerationLoadingState() when loading != null:
return loading(_that.phase);case GenerationStreamingTextState() when streamingText != null:
return streamingText(_that.text);case GenerationFunctionCallingState() when functionCalling != null:
return functionCalling(_that.names);case GenerationCompleteState() when complete != null:
return complete(_that.result);case GenerationErrorState() when error != null:
return error(_that.exception);case _:
  return null;

}
}

}

/// @nodoc


class GenerationInitialState<T> extends GenerationState<T> {
  const GenerationInitialState(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationInitialState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GenerationState<$T>.initial()';
}


}




/// @nodoc


class GenerationLoadingState<T> extends GenerationState<T> {
  const GenerationLoadingState([this.phase = const LoadingPhase.initial()]): super._();
  

@JsonKey() final  LoadingPhase phase;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationLoadingStateCopyWith<T, GenerationLoadingState<T>> get copyWith => _$GenerationLoadingStateCopyWithImpl<T, GenerationLoadingState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationLoadingState<T>&&(identical(other.phase, phase) || other.phase == phase));
}


@override
int get hashCode => Object.hash(runtimeType,phase);

@override
String toString() {
  return 'GenerationState<$T>.loading(phase: $phase)';
}


}

/// @nodoc
abstract mixin class $GenerationLoadingStateCopyWith<T,$Res> implements $GenerationStateCopyWith<T, $Res> {
  factory $GenerationLoadingStateCopyWith(GenerationLoadingState<T> value, $Res Function(GenerationLoadingState<T>) _then) = _$GenerationLoadingStateCopyWithImpl;
@useResult
$Res call({
 LoadingPhase phase
});


$LoadingPhaseCopyWith<$Res> get phase;

}
/// @nodoc
class _$GenerationLoadingStateCopyWithImpl<T,$Res>
    implements $GenerationLoadingStateCopyWith<T, $Res> {
  _$GenerationLoadingStateCopyWithImpl(this._self, this._then);

  final GenerationLoadingState<T> _self;
  final $Res Function(GenerationLoadingState<T>) _then;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,}) {
  return _then(GenerationLoadingState<T>(
null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as LoadingPhase,
  ));
}

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoadingPhaseCopyWith<$Res> get phase {
  
  return $LoadingPhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}

/// @nodoc


class GenerationStreamingTextState<T> extends GenerationState<T> {
  const GenerationStreamingTextState(this.text): super._();
  

 final  String text;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationStreamingTextStateCopyWith<T, GenerationStreamingTextState<T>> get copyWith => _$GenerationStreamingTextStateCopyWithImpl<T, GenerationStreamingTextState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationStreamingTextState<T>&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'GenerationState<$T>.streamingText(text: $text)';
}


}

/// @nodoc
abstract mixin class $GenerationStreamingTextStateCopyWith<T,$Res> implements $GenerationStateCopyWith<T, $Res> {
  factory $GenerationStreamingTextStateCopyWith(GenerationStreamingTextState<T> value, $Res Function(GenerationStreamingTextState<T>) _then) = _$GenerationStreamingTextStateCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$GenerationStreamingTextStateCopyWithImpl<T,$Res>
    implements $GenerationStreamingTextStateCopyWith<T, $Res> {
  _$GenerationStreamingTextStateCopyWithImpl(this._self, this._then);

  final GenerationStreamingTextState<T> _self;
  final $Res Function(GenerationStreamingTextState<T>) _then;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(GenerationStreamingTextState<T>(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GenerationFunctionCallingState<T> extends GenerationState<T> {
  const GenerationFunctionCallingState(this.names): super._();
  

 final  String names;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationFunctionCallingStateCopyWith<T, GenerationFunctionCallingState<T>> get copyWith => _$GenerationFunctionCallingStateCopyWithImpl<T, GenerationFunctionCallingState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationFunctionCallingState<T>&&(identical(other.names, names) || other.names == names));
}


@override
int get hashCode => Object.hash(runtimeType,names);

@override
String toString() {
  return 'GenerationState<$T>.functionCalling(names: $names)';
}


}

/// @nodoc
abstract mixin class $GenerationFunctionCallingStateCopyWith<T,$Res> implements $GenerationStateCopyWith<T, $Res> {
  factory $GenerationFunctionCallingStateCopyWith(GenerationFunctionCallingState<T> value, $Res Function(GenerationFunctionCallingState<T>) _then) = _$GenerationFunctionCallingStateCopyWithImpl;
@useResult
$Res call({
 String names
});




}
/// @nodoc
class _$GenerationFunctionCallingStateCopyWithImpl<T,$Res>
    implements $GenerationFunctionCallingStateCopyWith<T, $Res> {
  _$GenerationFunctionCallingStateCopyWithImpl(this._self, this._then);

  final GenerationFunctionCallingState<T> _self;
  final $Res Function(GenerationFunctionCallingState<T>) _then;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? names = null,}) {
  return _then(GenerationFunctionCallingState<T>(
null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GenerationCompleteState<T> extends GenerationState<T> {
  const GenerationCompleteState(this.result): super._();
  

 final  T result;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationCompleteStateCopyWith<T, GenerationCompleteState<T>> get copyWith => _$GenerationCompleteStateCopyWithImpl<T, GenerationCompleteState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationCompleteState<T>&&const DeepCollectionEquality().equals(other.result, result));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(result));

@override
String toString() {
  return 'GenerationState<$T>.complete(result: $result)';
}


}

/// @nodoc
abstract mixin class $GenerationCompleteStateCopyWith<T,$Res> implements $GenerationStateCopyWith<T, $Res> {
  factory $GenerationCompleteStateCopyWith(GenerationCompleteState<T> value, $Res Function(GenerationCompleteState<T>) _then) = _$GenerationCompleteStateCopyWithImpl;
@useResult
$Res call({
 T result
});




}
/// @nodoc
class _$GenerationCompleteStateCopyWithImpl<T,$Res>
    implements $GenerationCompleteStateCopyWith<T, $Res> {
  _$GenerationCompleteStateCopyWithImpl(this._self, this._then);

  final GenerationCompleteState<T> _self;
  final $Res Function(GenerationCompleteState<T>) _then;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? result = freezed,}) {
  return _then(GenerationCompleteState<T>(
freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class GenerationErrorState<T> extends GenerationState<T> {
  const GenerationErrorState(this.exception): super._();
  

 final  KaiException exception;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationErrorStateCopyWith<T, GenerationErrorState<T>> get copyWith => _$GenerationErrorStateCopyWithImpl<T, GenerationErrorState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationErrorState<T>&&(identical(other.exception, exception) || other.exception == exception));
}


@override
int get hashCode => Object.hash(runtimeType,exception);

@override
String toString() {
  return 'GenerationState<$T>.error(exception: $exception)';
}


}

/// @nodoc
abstract mixin class $GenerationErrorStateCopyWith<T,$Res> implements $GenerationStateCopyWith<T, $Res> {
  factory $GenerationErrorStateCopyWith(GenerationErrorState<T> value, $Res Function(GenerationErrorState<T>) _then) = _$GenerationErrorStateCopyWithImpl;
@useResult
$Res call({
 KaiException exception
});


$KaiExceptionCopyWith<$Res> get exception;

}
/// @nodoc
class _$GenerationErrorStateCopyWithImpl<T,$Res>
    implements $GenerationErrorStateCopyWith<T, $Res> {
  _$GenerationErrorStateCopyWithImpl(this._self, this._then);

  final GenerationErrorState<T> _self;
  final $Res Function(GenerationErrorState<T>) _then;

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exception = null,}) {
  return _then(GenerationErrorState<T>(
null == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as KaiException,
  ));
}

/// Create a copy of GenerationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KaiExceptionCopyWith<$Res> get exception {
  
  return $KaiExceptionCopyWith<$Res>(_self.exception, (value) {
    return _then(_self.copyWith(exception: value));
  });
}
}

// dart format on
