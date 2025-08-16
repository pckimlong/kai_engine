// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationSession {

 String get id; DateTime? get createdAt; Map<String, dynamic> get metadata;
/// Create a copy of ConversationSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationSessionCopyWith<ConversationSession> get copyWith => _$ConversationSessionCopyWithImpl<ConversationSession>(this as ConversationSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationSession&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ConversationSession(id: $id, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ConversationSessionCopyWith<$Res>  {
  factory $ConversationSessionCopyWith(ConversationSession value, $Res Function(ConversationSession) _then) = _$ConversationSessionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime? createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$ConversationSessionCopyWithImpl<$Res>
    implements $ConversationSessionCopyWith<$Res> {
  _$ConversationSessionCopyWithImpl(this._self, this._then);

  final ConversationSession _self;
  final $Res Function(ConversationSession) _then;

/// Create a copy of ConversationSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationSession].
extension ConversationSessionPatterns on ConversationSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationSession value)  $default,){
final _that = this;
switch (_that) {
case _ConversationSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationSession value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime? createdAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationSession() when $default != null:
return $default(_that.id,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime? createdAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _ConversationSession():
return $default(_that.id,_that.createdAt,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime? createdAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _ConversationSession() when $default != null:
return $default(_that.id,_that.createdAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationSession implements ConversationSession {
  const _ConversationSession({required this.id, this.createdAt, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata;
  

@override final  String id;
@override final  DateTime? createdAt;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of ConversationSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationSessionCopyWith<_ConversationSession> get copyWith => __$ConversationSessionCopyWithImpl<_ConversationSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationSession&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ConversationSession(id: $id, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ConversationSessionCopyWith<$Res> implements $ConversationSessionCopyWith<$Res> {
  factory _$ConversationSessionCopyWith(_ConversationSession value, $Res Function(_ConversationSession) _then) = __$ConversationSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime? createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$ConversationSessionCopyWithImpl<$Res>
    implements _$ConversationSessionCopyWith<$Res> {
  __$ConversationSessionCopyWithImpl(this._self, this._then);

  final _ConversationSession _self;
  final $Res Function(_ConversationSession) _then;

/// Create a copy of ConversationSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = freezed,Object? metadata = null,}) {
  return _then(_ConversationSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
