// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'query_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QueryContext {

 ConversationSession get session;/// Original input from user
 String get originalQuery; String get processedQuery; IList<double> get embeddings;/// Extensible map for more specific data
 Map<String, dynamic> get metadata;
/// Create a copy of QueryContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueryContextCopyWith<QueryContext> get copyWith => _$QueryContextCopyWithImpl<QueryContext>(this as QueryContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueryContext&&(identical(other.session, session) || other.session == session)&&(identical(other.originalQuery, originalQuery) || other.originalQuery == originalQuery)&&(identical(other.processedQuery, processedQuery) || other.processedQuery == processedQuery)&&const DeepCollectionEquality().equals(other.embeddings, embeddings)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,session,originalQuery,processedQuery,const DeepCollectionEquality().hash(embeddings),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'QueryContext(session: $session, originalQuery: $originalQuery, processedQuery: $processedQuery, embeddings: $embeddings, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $QueryContextCopyWith<$Res>  {
  factory $QueryContextCopyWith(QueryContext value, $Res Function(QueryContext) _then) = _$QueryContextCopyWithImpl;
@useResult
$Res call({
 ConversationSession session, String originalQuery, String processedQuery, IList<double> embeddings, Map<String, dynamic> metadata
});


$ConversationSessionCopyWith<$Res> get session;

}
/// @nodoc
class _$QueryContextCopyWithImpl<$Res>
    implements $QueryContextCopyWith<$Res> {
  _$QueryContextCopyWithImpl(this._self, this._then);

  final QueryContext _self;
  final $Res Function(QueryContext) _then;

/// Create a copy of QueryContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? session = null,Object? originalQuery = null,Object? processedQuery = null,Object? embeddings = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ConversationSession,originalQuery: null == originalQuery ? _self.originalQuery : originalQuery // ignore: cast_nullable_to_non_nullable
as String,processedQuery: null == processedQuery ? _self.processedQuery : processedQuery // ignore: cast_nullable_to_non_nullable
as String,embeddings: null == embeddings ? _self.embeddings : embeddings // ignore: cast_nullable_to_non_nullable
as IList<double>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of QueryContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationSessionCopyWith<$Res> get session {
  
  return $ConversationSessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [QueryContext].
extension QueryContextPatterns on QueryContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueryContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueryContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueryContext value)  $default,){
final _that = this;
switch (_that) {
case _QueryContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueryContext value)?  $default,){
final _that = this;
switch (_that) {
case _QueryContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConversationSession session,  String originalQuery,  String processedQuery,  IList<double> embeddings,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueryContext() when $default != null:
return $default(_that.session,_that.originalQuery,_that.processedQuery,_that.embeddings,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConversationSession session,  String originalQuery,  String processedQuery,  IList<double> embeddings,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _QueryContext():
return $default(_that.session,_that.originalQuery,_that.processedQuery,_that.embeddings,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConversationSession session,  String originalQuery,  String processedQuery,  IList<double> embeddings,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _QueryContext() when $default != null:
return $default(_that.session,_that.originalQuery,_that.processedQuery,_that.embeddings,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _QueryContext extends QueryContext {
  const _QueryContext({required this.session, required this.originalQuery, required this.processedQuery, this.embeddings = const IList.empty(), final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  

@override final  ConversationSession session;
/// Original input from user
@override final  String originalQuery;
@override final  String processedQuery;
@override@JsonKey() final  IList<double> embeddings;
/// Extensible map for more specific data
 final  Map<String, dynamic> _metadata;
/// Extensible map for more specific data
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of QueryContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueryContextCopyWith<_QueryContext> get copyWith => __$QueryContextCopyWithImpl<_QueryContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueryContext&&(identical(other.session, session) || other.session == session)&&(identical(other.originalQuery, originalQuery) || other.originalQuery == originalQuery)&&(identical(other.processedQuery, processedQuery) || other.processedQuery == processedQuery)&&const DeepCollectionEquality().equals(other.embeddings, embeddings)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,session,originalQuery,processedQuery,const DeepCollectionEquality().hash(embeddings),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'QueryContext(session: $session, originalQuery: $originalQuery, processedQuery: $processedQuery, embeddings: $embeddings, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$QueryContextCopyWith<$Res> implements $QueryContextCopyWith<$Res> {
  factory _$QueryContextCopyWith(_QueryContext value, $Res Function(_QueryContext) _then) = __$QueryContextCopyWithImpl;
@override @useResult
$Res call({
 ConversationSession session, String originalQuery, String processedQuery, IList<double> embeddings, Map<String, dynamic> metadata
});


@override $ConversationSessionCopyWith<$Res> get session;

}
/// @nodoc
class __$QueryContextCopyWithImpl<$Res>
    implements _$QueryContextCopyWith<$Res> {
  __$QueryContextCopyWithImpl(this._self, this._then);

  final _QueryContext _self;
  final $Res Function(_QueryContext) _then;

/// Create a copy of QueryContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = null,Object? originalQuery = null,Object? processedQuery = null,Object? embeddings = null,Object? metadata = null,}) {
  return _then(_QueryContext(
session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ConversationSession,originalQuery: null == originalQuery ? _self.originalQuery : originalQuery // ignore: cast_nullable_to_non_nullable
as String,processedQuery: null == processedQuery ? _self.processedQuery : processedQuery // ignore: cast_nullable_to_non_nullable
as String,embeddings: null == embeddings ? _self.embeddings : embeddings // ignore: cast_nullable_to_non_nullable
as IList<double>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of QueryContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationSessionCopyWith<$Res> get session {
  
  return $ConversationSessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

// dart format on
