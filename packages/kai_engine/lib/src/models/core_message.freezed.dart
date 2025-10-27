// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'core_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoreMessage {

 String get messageId; CoreMessageType get type; String get content;/// Whether this message is part of a background context, used for internal processing
/// it won't show in the user interface and is not persisted.
 bool get isBackgroundContext;/// Need this to function correctly
 DateTime get timestamp; Map<String, dynamic> get extensions;
/// Create a copy of CoreMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreMessageCopyWith<CoreMessage> get copyWith => _$CoreMessageCopyWithImpl<CoreMessage>(this as CoreMessage, _$identity);

  /// Serializes this CoreMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreMessage&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.isBackgroundContext, isBackgroundContext) || other.isBackgroundContext == isBackgroundContext)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.extensions, extensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,type,content,isBackgroundContext,timestamp,const DeepCollectionEquality().hash(extensions));

@override
String toString() {
  return 'CoreMessage(messageId: $messageId, type: $type, content: $content, isBackgroundContext: $isBackgroundContext, timestamp: $timestamp, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class $CoreMessageCopyWith<$Res>  {
  factory $CoreMessageCopyWith(CoreMessage value, $Res Function(CoreMessage) _then) = _$CoreMessageCopyWithImpl;
@useResult
$Res call({
 String messageId, CoreMessageType type, String content, bool isBackgroundContext, DateTime timestamp, Map<String, dynamic> extensions
});




}
/// @nodoc
class _$CoreMessageCopyWithImpl<$Res>
    implements $CoreMessageCopyWith<$Res> {
  _$CoreMessageCopyWithImpl(this._self, this._then);

  final CoreMessage _self;
  final $Res Function(CoreMessage) _then;

/// Create a copy of CoreMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? type = null,Object? content = null,Object? isBackgroundContext = null,Object? timestamp = null,Object? extensions = null,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoreMessageType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isBackgroundContext: null == isBackgroundContext ? _self.isBackgroundContext : isBackgroundContext // ignore: cast_nullable_to_non_nullable
as bool,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,extensions: null == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreMessage].
extension CoreMessagePatterns on CoreMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreMessage value)  $default,){
final _that = this;
switch (_that) {
case _CoreMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CoreMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId,  CoreMessageType type,  String content,  bool isBackgroundContext,  DateTime timestamp,  Map<String, dynamic> extensions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreMessage() when $default != null:
return $default(_that.messageId,_that.type,_that.content,_that.isBackgroundContext,_that.timestamp,_that.extensions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId,  CoreMessageType type,  String content,  bool isBackgroundContext,  DateTime timestamp,  Map<String, dynamic> extensions)  $default,) {final _that = this;
switch (_that) {
case _CoreMessage():
return $default(_that.messageId,_that.type,_that.content,_that.isBackgroundContext,_that.timestamp,_that.extensions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId,  CoreMessageType type,  String content,  bool isBackgroundContext,  DateTime timestamp,  Map<String, dynamic> extensions)?  $default,) {final _that = this;
switch (_that) {
case _CoreMessage() when $default != null:
return $default(_that.messageId,_that.type,_that.content,_that.isBackgroundContext,_that.timestamp,_that.extensions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreMessage extends CoreMessage {
  const _CoreMessage({required this.messageId, required this.type, required this.content, this.isBackgroundContext = false, required this.timestamp, final  Map<String, dynamic> extensions = const <String, dynamic>{}}): _extensions = extensions,super._();
  factory _CoreMessage.fromJson(Map<String, dynamic> json) => _$CoreMessageFromJson(json);

@override final  String messageId;
@override final  CoreMessageType type;
@override final  String content;
/// Whether this message is part of a background context, used for internal processing
/// it won't show in the user interface and is not persisted.
@override@JsonKey() final  bool isBackgroundContext;
/// Need this to function correctly
@override final  DateTime timestamp;
 final  Map<String, dynamic> _extensions;
@override@JsonKey() Map<String, dynamic> get extensions {
  if (_extensions is EqualUnmodifiableMapView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extensions);
}


/// Create a copy of CoreMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreMessageCopyWith<_CoreMessage> get copyWith => __$CoreMessageCopyWithImpl<_CoreMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreMessage&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.isBackgroundContext, isBackgroundContext) || other.isBackgroundContext == isBackgroundContext)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._extensions, _extensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,type,content,isBackgroundContext,timestamp,const DeepCollectionEquality().hash(_extensions));

@override
String toString() {
  return 'CoreMessage(messageId: $messageId, type: $type, content: $content, isBackgroundContext: $isBackgroundContext, timestamp: $timestamp, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class _$CoreMessageCopyWith<$Res> implements $CoreMessageCopyWith<$Res> {
  factory _$CoreMessageCopyWith(_CoreMessage value, $Res Function(_CoreMessage) _then) = __$CoreMessageCopyWithImpl;
@override @useResult
$Res call({
 String messageId, CoreMessageType type, String content, bool isBackgroundContext, DateTime timestamp, Map<String, dynamic> extensions
});




}
/// @nodoc
class __$CoreMessageCopyWithImpl<$Res>
    implements _$CoreMessageCopyWith<$Res> {
  __$CoreMessageCopyWithImpl(this._self, this._then);

  final _CoreMessage _self;
  final $Res Function(_CoreMessage) _then;

/// Create a copy of CoreMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? type = null,Object? content = null,Object? isBackgroundContext = null,Object? timestamp = null,Object? extensions = null,}) {
  return _then(_CoreMessage(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoreMessageType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isBackgroundContext: null == isBackgroundContext ? _self.isBackgroundContext : isBackgroundContext // ignore: cast_nullable_to_non_nullable
as bool,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,extensions: null == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
