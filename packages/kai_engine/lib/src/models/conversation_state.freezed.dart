// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConversationState()';
}


}

/// @nodoc
class $ConversationStateCopyWith<$Res>  {
$ConversationStateCopyWith(ConversationState _, $Res Function(ConversationState) __);
}


/// Adds pattern-matching-related methods to [ConversationState].
extension ConversationStatePatterns on ConversationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ConversationStateInitial value)?  initial,TResult Function( _ConversationStateLoading value)?  loading,TResult Function( _ConversationStateLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationStateInitial() when initial != null:
return initial(_that);case _ConversationStateLoading() when loading != null:
return loading(_that);case _ConversationStateLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ConversationStateInitial value)  initial,required TResult Function( _ConversationStateLoading value)  loading,required TResult Function( _ConversationStateLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case _ConversationStateInitial():
return initial(_that);case _ConversationStateLoading():
return loading(_that);case _ConversationStateLoaded():
return loaded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ConversationStateInitial value)?  initial,TResult? Function( _ConversationStateLoading value)?  loading,TResult? Function( _ConversationStateLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case _ConversationStateInitial() when initial != null:
return initial(_that);case _ConversationStateLoading() when loading != null:
return loading(_that);case _ConversationStateLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationStateInitial() when initial != null:
return initial();case _ConversationStateLoading() when loading != null:
return loading();case _ConversationStateLoaded() when loaded != null:
return loaded();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  loaded,}) {final _that = this;
switch (_that) {
case _ConversationStateInitial():
return initial();case _ConversationStateLoading():
return loading();case _ConversationStateLoaded():
return loaded();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  loaded,}) {final _that = this;
switch (_that) {
case _ConversationStateInitial() when initial != null:
return initial();case _ConversationStateLoading() when loading != null:
return loading();case _ConversationStateLoaded() when loaded != null:
return loaded();case _:
  return null;

}
}

}

/// @nodoc


class _ConversationStateInitial extends ConversationState {
  const _ConversationStateInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConversationState.initial()';
}


}




/// @nodoc


class _ConversationStateLoading extends ConversationState {
  const _ConversationStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConversationState.loading()';
}


}




/// @nodoc


class _ConversationStateLoaded extends ConversationState {
  const _ConversationStateLoaded(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationStateLoaded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConversationState.loaded()';
}


}




// dart format on
