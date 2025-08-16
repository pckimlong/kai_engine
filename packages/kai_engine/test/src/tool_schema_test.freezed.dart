// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tool_schema_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestToolCall {

 String get query; int get limit;
/// Create a copy of TestToolCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestToolCallCopyWith<TestToolCall> get copyWith => _$TestToolCallCopyWithImpl<TestToolCall>(this as TestToolCall, _$identity);

  /// Serializes this TestToolCall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestToolCall&&(identical(other.query, query) || other.query == query)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,limit);

@override
String toString() {
  return 'TestToolCall(query: $query, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $TestToolCallCopyWith<$Res>  {
  factory $TestToolCallCopyWith(TestToolCall value, $Res Function(TestToolCall) _then) = _$TestToolCallCopyWithImpl;
@useResult
$Res call({
 String query, int limit
});




}
/// @nodoc
class _$TestToolCallCopyWithImpl<$Res>
    implements $TestToolCallCopyWith<$Res> {
  _$TestToolCallCopyWithImpl(this._self, this._then);

  final TestToolCall _self;
  final $Res Function(TestToolCall) _then;

/// Create a copy of TestToolCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? limit = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TestToolCall].
extension TestToolCallPatterns on TestToolCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestToolCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestToolCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestToolCall value)  $default,){
final _that = this;
switch (_that) {
case _TestToolCall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestToolCall value)?  $default,){
final _that = this;
switch (_that) {
case _TestToolCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestToolCall() when $default != null:
return $default(_that.query,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  int limit)  $default,) {final _that = this;
switch (_that) {
case _TestToolCall():
return $default(_that.query,_that.limit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _TestToolCall() when $default != null:
return $default(_that.query,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TestToolCall extends TestToolCall {
  const _TestToolCall({required this.query, this.limit = 10}): super._();
  factory _TestToolCall.fromJson(Map<String, dynamic> json) => _$TestToolCallFromJson(json);

@override final  String query;
@override@JsonKey() final  int limit;

/// Create a copy of TestToolCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestToolCallCopyWith<_TestToolCall> get copyWith => __$TestToolCallCopyWithImpl<_TestToolCall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TestToolCallToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestToolCall&&(identical(other.query, query) || other.query == query)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,limit);

@override
String toString() {
  return 'TestToolCall(query: $query, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$TestToolCallCopyWith<$Res> implements $TestToolCallCopyWith<$Res> {
  factory _$TestToolCallCopyWith(_TestToolCall value, $Res Function(_TestToolCall) _then) = __$TestToolCallCopyWithImpl;
@override @useResult
$Res call({
 String query, int limit
});




}
/// @nodoc
class __$TestToolCallCopyWithImpl<$Res>
    implements _$TestToolCallCopyWith<$Res> {
  __$TestToolCallCopyWithImpl(this._self, this._then);

  final _TestToolCall _self;
  final $Res Function(_TestToolCall) _then;

/// Create a copy of TestToolCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? limit = null,}) {
  return _then(_TestToolCall(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
