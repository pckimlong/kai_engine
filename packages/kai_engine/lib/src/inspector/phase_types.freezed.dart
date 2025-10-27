// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phase_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QueryEngineInput {

 String get rawInput; ConversationSession get session; IList<CoreMessage> get histories;
/// Create a copy of QueryEngineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueryEngineInputCopyWith<QueryEngineInput> get copyWith => _$QueryEngineInputCopyWithImpl<QueryEngineInput>(this as QueryEngineInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueryEngineInput&&(identical(other.rawInput, rawInput) || other.rawInput == rawInput)&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other.histories, histories));
}


@override
int get hashCode => Object.hash(runtimeType,rawInput,session,const DeepCollectionEquality().hash(histories));

@override
String toString() {
  return 'QueryEngineInput(rawInput: $rawInput, session: $session, histories: $histories)';
}


}

/// @nodoc
abstract mixin class $QueryEngineInputCopyWith<$Res>  {
  factory $QueryEngineInputCopyWith(QueryEngineInput value, $Res Function(QueryEngineInput) _then) = _$QueryEngineInputCopyWithImpl;
@useResult
$Res call({
 String rawInput, ConversationSession session, IList<CoreMessage> histories
});


$ConversationSessionCopyWith<$Res> get session;

}
/// @nodoc
class _$QueryEngineInputCopyWithImpl<$Res>
    implements $QueryEngineInputCopyWith<$Res> {
  _$QueryEngineInputCopyWithImpl(this._self, this._then);

  final QueryEngineInput _self;
  final $Res Function(QueryEngineInput) _then;

/// Create a copy of QueryEngineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawInput = null,Object? session = null,Object? histories = null,}) {
  return _then(_self.copyWith(
rawInput: null == rawInput ? _self.rawInput : rawInput // ignore: cast_nullable_to_non_nullable
as String,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ConversationSession,histories: null == histories ? _self.histories : histories // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,
  ));
}
/// Create a copy of QueryEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationSessionCopyWith<$Res> get session {
  
  return $ConversationSessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [QueryEngineInput].
extension QueryEngineInputPatterns on QueryEngineInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueryEngineInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueryEngineInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueryEngineInput value)  $default,){
final _that = this;
switch (_that) {
case _QueryEngineInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueryEngineInput value)?  $default,){
final _that = this;
switch (_that) {
case _QueryEngineInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawInput,  ConversationSession session,  IList<CoreMessage> histories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueryEngineInput() when $default != null:
return $default(_that.rawInput,_that.session,_that.histories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawInput,  ConversationSession session,  IList<CoreMessage> histories)  $default,) {final _that = this;
switch (_that) {
case _QueryEngineInput():
return $default(_that.rawInput,_that.session,_that.histories);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawInput,  ConversationSession session,  IList<CoreMessage> histories)?  $default,) {final _that = this;
switch (_that) {
case _QueryEngineInput() when $default != null:
return $default(_that.rawInput,_that.session,_that.histories);case _:
  return null;

}
}

}

/// @nodoc


class _QueryEngineInput implements QueryEngineInput {
  const _QueryEngineInput({required this.rawInput, required this.session, required this.histories});
  

@override final  String rawInput;
@override final  ConversationSession session;
@override final  IList<CoreMessage> histories;

/// Create a copy of QueryEngineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueryEngineInputCopyWith<_QueryEngineInput> get copyWith => __$QueryEngineInputCopyWithImpl<_QueryEngineInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueryEngineInput&&(identical(other.rawInput, rawInput) || other.rawInput == rawInput)&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other.histories, histories));
}


@override
int get hashCode => Object.hash(runtimeType,rawInput,session,const DeepCollectionEquality().hash(histories));

@override
String toString() {
  return 'QueryEngineInput(rawInput: $rawInput, session: $session, histories: $histories)';
}


}

/// @nodoc
abstract mixin class _$QueryEngineInputCopyWith<$Res> implements $QueryEngineInputCopyWith<$Res> {
  factory _$QueryEngineInputCopyWith(_QueryEngineInput value, $Res Function(_QueryEngineInput) _then) = __$QueryEngineInputCopyWithImpl;
@override @useResult
$Res call({
 String rawInput, ConversationSession session, IList<CoreMessage> histories
});


@override $ConversationSessionCopyWith<$Res> get session;

}
/// @nodoc
class __$QueryEngineInputCopyWithImpl<$Res>
    implements _$QueryEngineInputCopyWith<$Res> {
  __$QueryEngineInputCopyWithImpl(this._self, this._then);

  final _QueryEngineInput _self;
  final $Res Function(_QueryEngineInput) _then;

/// Create a copy of QueryEngineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawInput = null,Object? session = null,Object? histories = null,}) {
  return _then(_QueryEngineInput(
rawInput: null == rawInput ? _self.rawInput : rawInput // ignore: cast_nullable_to_non_nullable
as String,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ConversationSession,histories: null == histories ? _self.histories : histories // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,
  ));
}

/// Create a copy of QueryEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationSessionCopyWith<$Res> get session {
  
  return $ConversationSessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc
mixin _$ContextEngineInput {

 QueryContext get inputQuery; IList<CoreMessage> get conversationMessages; CoreMessage? get providedUserMessage;
/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContextEngineInputCopyWith<ContextEngineInput> get copyWith => _$ContextEngineInputCopyWithImpl<ContextEngineInput>(this as ContextEngineInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContextEngineInput&&(identical(other.inputQuery, inputQuery) || other.inputQuery == inputQuery)&&const DeepCollectionEquality().equals(other.conversationMessages, conversationMessages)&&(identical(other.providedUserMessage, providedUserMessage) || other.providedUserMessage == providedUserMessage));
}


@override
int get hashCode => Object.hash(runtimeType,inputQuery,const DeepCollectionEquality().hash(conversationMessages),providedUserMessage);

@override
String toString() {
  return 'ContextEngineInput(inputQuery: $inputQuery, conversationMessages: $conversationMessages, providedUserMessage: $providedUserMessage)';
}


}

/// @nodoc
abstract mixin class $ContextEngineInputCopyWith<$Res>  {
  factory $ContextEngineInputCopyWith(ContextEngineInput value, $Res Function(ContextEngineInput) _then) = _$ContextEngineInputCopyWithImpl;
@useResult
$Res call({
 QueryContext inputQuery, IList<CoreMessage> conversationMessages, CoreMessage? providedUserMessage
});


$QueryContextCopyWith<$Res> get inputQuery;$CoreMessageCopyWith<$Res>? get providedUserMessage;

}
/// @nodoc
class _$ContextEngineInputCopyWithImpl<$Res>
    implements $ContextEngineInputCopyWith<$Res> {
  _$ContextEngineInputCopyWithImpl(this._self, this._then);

  final ContextEngineInput _self;
  final $Res Function(ContextEngineInput) _then;

/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inputQuery = null,Object? conversationMessages = null,Object? providedUserMessage = freezed,}) {
  return _then(_self.copyWith(
inputQuery: null == inputQuery ? _self.inputQuery : inputQuery // ignore: cast_nullable_to_non_nullable
as QueryContext,conversationMessages: null == conversationMessages ? _self.conversationMessages : conversationMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,providedUserMessage: freezed == providedUserMessage ? _self.providedUserMessage : providedUserMessage // ignore: cast_nullable_to_non_nullable
as CoreMessage?,
  ));
}
/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueryContextCopyWith<$Res> get inputQuery {
  
  return $QueryContextCopyWith<$Res>(_self.inputQuery, (value) {
    return _then(_self.copyWith(inputQuery: value));
  });
}/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMessageCopyWith<$Res>? get providedUserMessage {
    if (_self.providedUserMessage == null) {
    return null;
  }

  return $CoreMessageCopyWith<$Res>(_self.providedUserMessage!, (value) {
    return _then(_self.copyWith(providedUserMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContextEngineInput].
extension ContextEngineInputPatterns on ContextEngineInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContextEngineInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContextEngineInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContextEngineInput value)  $default,){
final _that = this;
switch (_that) {
case _ContextEngineInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContextEngineInput value)?  $default,){
final _that = this;
switch (_that) {
case _ContextEngineInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QueryContext inputQuery,  IList<CoreMessage> conversationMessages,  CoreMessage? providedUserMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContextEngineInput() when $default != null:
return $default(_that.inputQuery,_that.conversationMessages,_that.providedUserMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QueryContext inputQuery,  IList<CoreMessage> conversationMessages,  CoreMessage? providedUserMessage)  $default,) {final _that = this;
switch (_that) {
case _ContextEngineInput():
return $default(_that.inputQuery,_that.conversationMessages,_that.providedUserMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QueryContext inputQuery,  IList<CoreMessage> conversationMessages,  CoreMessage? providedUserMessage)?  $default,) {final _that = this;
switch (_that) {
case _ContextEngineInput() when $default != null:
return $default(_that.inputQuery,_that.conversationMessages,_that.providedUserMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ContextEngineInput implements ContextEngineInput {
  const _ContextEngineInput({required this.inputQuery, required this.conversationMessages, required this.providedUserMessage});
  

@override final  QueryContext inputQuery;
@override final  IList<CoreMessage> conversationMessages;
@override final  CoreMessage? providedUserMessage;

/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContextEngineInputCopyWith<_ContextEngineInput> get copyWith => __$ContextEngineInputCopyWithImpl<_ContextEngineInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContextEngineInput&&(identical(other.inputQuery, inputQuery) || other.inputQuery == inputQuery)&&const DeepCollectionEquality().equals(other.conversationMessages, conversationMessages)&&(identical(other.providedUserMessage, providedUserMessage) || other.providedUserMessage == providedUserMessage));
}


@override
int get hashCode => Object.hash(runtimeType,inputQuery,const DeepCollectionEquality().hash(conversationMessages),providedUserMessage);

@override
String toString() {
  return 'ContextEngineInput(inputQuery: $inputQuery, conversationMessages: $conversationMessages, providedUserMessage: $providedUserMessage)';
}


}

/// @nodoc
abstract mixin class _$ContextEngineInputCopyWith<$Res> implements $ContextEngineInputCopyWith<$Res> {
  factory _$ContextEngineInputCopyWith(_ContextEngineInput value, $Res Function(_ContextEngineInput) _then) = __$ContextEngineInputCopyWithImpl;
@override @useResult
$Res call({
 QueryContext inputQuery, IList<CoreMessage> conversationMessages, CoreMessage? providedUserMessage
});


@override $QueryContextCopyWith<$Res> get inputQuery;@override $CoreMessageCopyWith<$Res>? get providedUserMessage;

}
/// @nodoc
class __$ContextEngineInputCopyWithImpl<$Res>
    implements _$ContextEngineInputCopyWith<$Res> {
  __$ContextEngineInputCopyWithImpl(this._self, this._then);

  final _ContextEngineInput _self;
  final $Res Function(_ContextEngineInput) _then;

/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inputQuery = null,Object? conversationMessages = null,Object? providedUserMessage = freezed,}) {
  return _then(_ContextEngineInput(
inputQuery: null == inputQuery ? _self.inputQuery : inputQuery // ignore: cast_nullable_to_non_nullable
as QueryContext,conversationMessages: null == conversationMessages ? _self.conversationMessages : conversationMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,providedUserMessage: freezed == providedUserMessage ? _self.providedUserMessage : providedUserMessage // ignore: cast_nullable_to_non_nullable
as CoreMessage?,
  ));
}

/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueryContextCopyWith<$Res> get inputQuery {
  
  return $QueryContextCopyWith<$Res>(_self.inputQuery, (value) {
    return _then(_self.copyWith(inputQuery: value));
  });
}/// Create a copy of ContextEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMessageCopyWith<$Res>? get providedUserMessage {
    if (_self.providedUserMessage == null) {
    return null;
  }

  return $CoreMessageCopyWith<$Res>(_self.providedUserMessage!, (value) {
    return _then(_self.copyWith(providedUserMessage: value));
  });
}
}

/// @nodoc
mixin _$ContextEngineOutput {

 IList<CoreMessage> get prompts;
/// Create a copy of ContextEngineOutput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContextEngineOutputCopyWith<ContextEngineOutput> get copyWith => _$ContextEngineOutputCopyWithImpl<ContextEngineOutput>(this as ContextEngineOutput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContextEngineOutput&&const DeepCollectionEquality().equals(other.prompts, prompts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(prompts));

@override
String toString() {
  return 'ContextEngineOutput(prompts: $prompts)';
}


}

/// @nodoc
abstract mixin class $ContextEngineOutputCopyWith<$Res>  {
  factory $ContextEngineOutputCopyWith(ContextEngineOutput value, $Res Function(ContextEngineOutput) _then) = _$ContextEngineOutputCopyWithImpl;
@useResult
$Res call({
 IList<CoreMessage> prompts
});




}
/// @nodoc
class _$ContextEngineOutputCopyWithImpl<$Res>
    implements $ContextEngineOutputCopyWith<$Res> {
  _$ContextEngineOutputCopyWithImpl(this._self, this._then);

  final ContextEngineOutput _self;
  final $Res Function(ContextEngineOutput) _then;

/// Create a copy of ContextEngineOutput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompts = null,}) {
  return _then(_self.copyWith(
prompts: null == prompts ? _self.prompts : prompts // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContextEngineOutput].
extension ContextEngineOutputPatterns on ContextEngineOutput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContextEngineOutput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContextEngineOutput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContextEngineOutput value)  $default,){
final _that = this;
switch (_that) {
case _ContextEngineOutput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContextEngineOutput value)?  $default,){
final _that = this;
switch (_that) {
case _ContextEngineOutput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IList<CoreMessage> prompts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContextEngineOutput() when $default != null:
return $default(_that.prompts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IList<CoreMessage> prompts)  $default,) {final _that = this;
switch (_that) {
case _ContextEngineOutput():
return $default(_that.prompts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IList<CoreMessage> prompts)?  $default,) {final _that = this;
switch (_that) {
case _ContextEngineOutput() when $default != null:
return $default(_that.prompts);case _:
  return null;

}
}

}

/// @nodoc


class _ContextEngineOutput implements ContextEngineOutput {
  const _ContextEngineOutput({required this.prompts});
  

@override final  IList<CoreMessage> prompts;

/// Create a copy of ContextEngineOutput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContextEngineOutputCopyWith<_ContextEngineOutput> get copyWith => __$ContextEngineOutputCopyWithImpl<_ContextEngineOutput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContextEngineOutput&&const DeepCollectionEquality().equals(other.prompts, prompts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(prompts));

@override
String toString() {
  return 'ContextEngineOutput(prompts: $prompts)';
}


}

/// @nodoc
abstract mixin class _$ContextEngineOutputCopyWith<$Res> implements $ContextEngineOutputCopyWith<$Res> {
  factory _$ContextEngineOutputCopyWith(_ContextEngineOutput value, $Res Function(_ContextEngineOutput) _then) = __$ContextEngineOutputCopyWithImpl;
@override @useResult
$Res call({
 IList<CoreMessage> prompts
});




}
/// @nodoc
class __$ContextEngineOutputCopyWithImpl<$Res>
    implements _$ContextEngineOutputCopyWith<$Res> {
  __$ContextEngineOutputCopyWithImpl(this._self, this._then);

  final _ContextEngineOutput _self;
  final $Res Function(_ContextEngineOutput) _then;

/// Create a copy of ContextEngineOutput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompts = null,}) {
  return _then(_ContextEngineOutput(
prompts: null == prompts ? _self.prompts : prompts // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,
  ));
}


}

/// @nodoc
mixin _$GenerationServiceInput {

 IList<CoreMessage> get prompts; CancelToken? get cancelToken; List<ToolSchema> get tools; Map<String, dynamic>? get config;
/// Create a copy of GenerationServiceInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationServiceInputCopyWith<GenerationServiceInput> get copyWith => _$GenerationServiceInputCopyWithImpl<GenerationServiceInput>(this as GenerationServiceInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationServiceInput&&const DeepCollectionEquality().equals(other.prompts, prompts)&&(identical(other.cancelToken, cancelToken) || other.cancelToken == cancelToken)&&const DeepCollectionEquality().equals(other.tools, tools)&&const DeepCollectionEquality().equals(other.config, config));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(prompts),cancelToken,const DeepCollectionEquality().hash(tools),const DeepCollectionEquality().hash(config));

@override
String toString() {
  return 'GenerationServiceInput(prompts: $prompts, cancelToken: $cancelToken, tools: $tools, config: $config)';
}


}

/// @nodoc
abstract mixin class $GenerationServiceInputCopyWith<$Res>  {
  factory $GenerationServiceInputCopyWith(GenerationServiceInput value, $Res Function(GenerationServiceInput) _then) = _$GenerationServiceInputCopyWithImpl;
@useResult
$Res call({
 IList<CoreMessage> prompts, CancelToken? cancelToken, List<ToolSchema> tools, Map<String, dynamic>? config
});




}
/// @nodoc
class _$GenerationServiceInputCopyWithImpl<$Res>
    implements $GenerationServiceInputCopyWith<$Res> {
  _$GenerationServiceInputCopyWithImpl(this._self, this._then);

  final GenerationServiceInput _self;
  final $Res Function(GenerationServiceInput) _then;

/// Create a copy of GenerationServiceInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prompts = null,Object? cancelToken = freezed,Object? tools = null,Object? config = freezed,}) {
  return _then(_self.copyWith(
prompts: null == prompts ? _self.prompts : prompts // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,cancelToken: freezed == cancelToken ? _self.cancelToken : cancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken?,tools: null == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolSchema>,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GenerationServiceInput].
extension GenerationServiceInputPatterns on GenerationServiceInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerationServiceInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerationServiceInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerationServiceInput value)  $default,){
final _that = this;
switch (_that) {
case _GenerationServiceInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerationServiceInput value)?  $default,){
final _that = this;
switch (_that) {
case _GenerationServiceInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IList<CoreMessage> prompts,  CancelToken? cancelToken,  List<ToolSchema> tools,  Map<String, dynamic>? config)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationServiceInput() when $default != null:
return $default(_that.prompts,_that.cancelToken,_that.tools,_that.config);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IList<CoreMessage> prompts,  CancelToken? cancelToken,  List<ToolSchema> tools,  Map<String, dynamic>? config)  $default,) {final _that = this;
switch (_that) {
case _GenerationServiceInput():
return $default(_that.prompts,_that.cancelToken,_that.tools,_that.config);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IList<CoreMessage> prompts,  CancelToken? cancelToken,  List<ToolSchema> tools,  Map<String, dynamic>? config)?  $default,) {final _that = this;
switch (_that) {
case _GenerationServiceInput() when $default != null:
return $default(_that.prompts,_that.cancelToken,_that.tools,_that.config);case _:
  return null;

}
}

}

/// @nodoc


class _GenerationServiceInput implements GenerationServiceInput {
  const _GenerationServiceInput({required this.prompts, this.cancelToken, final  List<ToolSchema> tools = const [], final  Map<String, dynamic>? config}): _tools = tools,_config = config;
  

@override final  IList<CoreMessage> prompts;
@override final  CancelToken? cancelToken;
 final  List<ToolSchema> _tools;
@override@JsonKey() List<ToolSchema> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}

 final  Map<String, dynamic>? _config;
@override Map<String, dynamic>? get config {
  final value = _config;
  if (value == null) return null;
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GenerationServiceInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationServiceInputCopyWith<_GenerationServiceInput> get copyWith => __$GenerationServiceInputCopyWithImpl<_GenerationServiceInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationServiceInput&&const DeepCollectionEquality().equals(other.prompts, prompts)&&(identical(other.cancelToken, cancelToken) || other.cancelToken == cancelToken)&&const DeepCollectionEquality().equals(other._tools, _tools)&&const DeepCollectionEquality().equals(other._config, _config));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(prompts),cancelToken,const DeepCollectionEquality().hash(_tools),const DeepCollectionEquality().hash(_config));

@override
String toString() {
  return 'GenerationServiceInput(prompts: $prompts, cancelToken: $cancelToken, tools: $tools, config: $config)';
}


}

/// @nodoc
abstract mixin class _$GenerationServiceInputCopyWith<$Res> implements $GenerationServiceInputCopyWith<$Res> {
  factory _$GenerationServiceInputCopyWith(_GenerationServiceInput value, $Res Function(_GenerationServiceInput) _then) = __$GenerationServiceInputCopyWithImpl;
@override @useResult
$Res call({
 IList<CoreMessage> prompts, CancelToken? cancelToken, List<ToolSchema> tools, Map<String, dynamic>? config
});




}
/// @nodoc
class __$GenerationServiceInputCopyWithImpl<$Res>
    implements _$GenerationServiceInputCopyWith<$Res> {
  __$GenerationServiceInputCopyWithImpl(this._self, this._then);

  final _GenerationServiceInput _self;
  final $Res Function(_GenerationServiceInput) _then;

/// Create a copy of GenerationServiceInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prompts = null,Object? cancelToken = freezed,Object? tools = null,Object? config = freezed,}) {
  return _then(_GenerationServiceInput(
prompts: null == prompts ? _self.prompts : prompts // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,cancelToken: freezed == cancelToken ? _self.cancelToken : cancelToken // ignore: cast_nullable_to_non_nullable
as CancelToken?,tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<ToolSchema>,config: freezed == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc
mixin _$GenerationServiceOutput {

 GenerationResult get result;
/// Create a copy of GenerationServiceOutput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerationServiceOutputCopyWith<GenerationServiceOutput> get copyWith => _$GenerationServiceOutputCopyWithImpl<GenerationServiceOutput>(this as GenerationServiceOutput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerationServiceOutput&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,result);

@override
String toString() {
  return 'GenerationServiceOutput(result: $result)';
}


}

/// @nodoc
abstract mixin class $GenerationServiceOutputCopyWith<$Res>  {
  factory $GenerationServiceOutputCopyWith(GenerationServiceOutput value, $Res Function(GenerationServiceOutput) _then) = _$GenerationServiceOutputCopyWithImpl;
@useResult
$Res call({
 GenerationResult result
});


$GenerationResultCopyWith<$Res> get result;

}
/// @nodoc
class _$GenerationServiceOutputCopyWithImpl<$Res>
    implements $GenerationServiceOutputCopyWith<$Res> {
  _$GenerationServiceOutputCopyWithImpl(this._self, this._then);

  final GenerationServiceOutput _self;
  final $Res Function(GenerationServiceOutput) _then;

/// Create a copy of GenerationServiceOutput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? result = null,}) {
  return _then(_self.copyWith(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GenerationResult,
  ));
}
/// Create a copy of GenerationServiceOutput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerationResultCopyWith<$Res> get result {
  
  return $GenerationResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [GenerationServiceOutput].
extension GenerationServiceOutputPatterns on GenerationServiceOutput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerationServiceOutput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerationServiceOutput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerationServiceOutput value)  $default,){
final _that = this;
switch (_that) {
case _GenerationServiceOutput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerationServiceOutput value)?  $default,){
final _that = this;
switch (_that) {
case _GenerationServiceOutput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GenerationResult result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerationServiceOutput() when $default != null:
return $default(_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GenerationResult result)  $default,) {final _that = this;
switch (_that) {
case _GenerationServiceOutput():
return $default(_that.result);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GenerationResult result)?  $default,) {final _that = this;
switch (_that) {
case _GenerationServiceOutput() when $default != null:
return $default(_that.result);case _:
  return null;

}
}

}

/// @nodoc


class _GenerationServiceOutput implements GenerationServiceOutput {
  const _GenerationServiceOutput({required this.result});
  

@override final  GenerationResult result;

/// Create a copy of GenerationServiceOutput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerationServiceOutputCopyWith<_GenerationServiceOutput> get copyWith => __$GenerationServiceOutputCopyWithImpl<_GenerationServiceOutput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerationServiceOutput&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,result);

@override
String toString() {
  return 'GenerationServiceOutput(result: $result)';
}


}

/// @nodoc
abstract mixin class _$GenerationServiceOutputCopyWith<$Res> implements $GenerationServiceOutputCopyWith<$Res> {
  factory _$GenerationServiceOutputCopyWith(_GenerationServiceOutput value, $Res Function(_GenerationServiceOutput) _then) = __$GenerationServiceOutputCopyWithImpl;
@override @useResult
$Res call({
 GenerationResult result
});


@override $GenerationResultCopyWith<$Res> get result;

}
/// @nodoc
class __$GenerationServiceOutputCopyWithImpl<$Res>
    implements _$GenerationServiceOutputCopyWith<$Res> {
  __$GenerationServiceOutputCopyWithImpl(this._self, this._then);

  final _GenerationServiceOutput _self;
  final $Res Function(_GenerationServiceOutput) _then;

/// Create a copy of GenerationServiceOutput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? result = null,}) {
  return _then(_GenerationServiceOutput(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GenerationResult,
  ));
}

/// Create a copy of GenerationServiceOutput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerationResultCopyWith<$Res> get result {
  
  return $GenerationResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

/// @nodoc
mixin _$PostResponseEngineInput {

 QueryContext get input;/// The last user message which trigger this generation
/// it differs from requestMessages which include all the message
 String get initialRequestMessageId; IList<CoreMessage> get requestMessages; GenerationResult get result; ConversationManager get conversationManager;
/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostResponseEngineInputCopyWith<PostResponseEngineInput> get copyWith => _$PostResponseEngineInputCopyWithImpl<PostResponseEngineInput>(this as PostResponseEngineInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostResponseEngineInput&&(identical(other.input, input) || other.input == input)&&(identical(other.initialRequestMessageId, initialRequestMessageId) || other.initialRequestMessageId == initialRequestMessageId)&&const DeepCollectionEquality().equals(other.requestMessages, requestMessages)&&(identical(other.result, result) || other.result == result)&&(identical(other.conversationManager, conversationManager) || other.conversationManager == conversationManager));
}


@override
int get hashCode => Object.hash(runtimeType,input,initialRequestMessageId,const DeepCollectionEquality().hash(requestMessages),result,conversationManager);

@override
String toString() {
  return 'PostResponseEngineInput(input: $input, initialRequestMessageId: $initialRequestMessageId, requestMessages: $requestMessages, result: $result, conversationManager: $conversationManager)';
}


}

/// @nodoc
abstract mixin class $PostResponseEngineInputCopyWith<$Res>  {
  factory $PostResponseEngineInputCopyWith(PostResponseEngineInput value, $Res Function(PostResponseEngineInput) _then) = _$PostResponseEngineInputCopyWithImpl;
@useResult
$Res call({
 QueryContext input, String initialRequestMessageId, IList<CoreMessage> requestMessages, GenerationResult result, ConversationManager conversationManager
});


$QueryContextCopyWith<$Res> get input;$GenerationResultCopyWith<$Res> get result;

}
/// @nodoc
class _$PostResponseEngineInputCopyWithImpl<$Res>
    implements $PostResponseEngineInputCopyWith<$Res> {
  _$PostResponseEngineInputCopyWithImpl(this._self, this._then);

  final PostResponseEngineInput _self;
  final $Res Function(PostResponseEngineInput) _then;

/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? input = null,Object? initialRequestMessageId = null,Object? requestMessages = null,Object? result = null,Object? conversationManager = null,}) {
  return _then(_self.copyWith(
input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as QueryContext,initialRequestMessageId: null == initialRequestMessageId ? _self.initialRequestMessageId : initialRequestMessageId // ignore: cast_nullable_to_non_nullable
as String,requestMessages: null == requestMessages ? _self.requestMessages : requestMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GenerationResult,conversationManager: null == conversationManager ? _self.conversationManager : conversationManager // ignore: cast_nullable_to_non_nullable
as ConversationManager,
  ));
}
/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueryContextCopyWith<$Res> get input {
  
  return $QueryContextCopyWith<$Res>(_self.input, (value) {
    return _then(_self.copyWith(input: value));
  });
}/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerationResultCopyWith<$Res> get result {
  
  return $GenerationResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostResponseEngineInput].
extension PostResponseEngineInputPatterns on PostResponseEngineInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostResponseEngineInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostResponseEngineInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostResponseEngineInput value)  $default,){
final _that = this;
switch (_that) {
case _PostResponseEngineInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostResponseEngineInput value)?  $default,){
final _that = this;
switch (_that) {
case _PostResponseEngineInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QueryContext input,  String initialRequestMessageId,  IList<CoreMessage> requestMessages,  GenerationResult result,  ConversationManager conversationManager)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostResponseEngineInput() when $default != null:
return $default(_that.input,_that.initialRequestMessageId,_that.requestMessages,_that.result,_that.conversationManager);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QueryContext input,  String initialRequestMessageId,  IList<CoreMessage> requestMessages,  GenerationResult result,  ConversationManager conversationManager)  $default,) {final _that = this;
switch (_that) {
case _PostResponseEngineInput():
return $default(_that.input,_that.initialRequestMessageId,_that.requestMessages,_that.result,_that.conversationManager);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QueryContext input,  String initialRequestMessageId,  IList<CoreMessage> requestMessages,  GenerationResult result,  ConversationManager conversationManager)?  $default,) {final _that = this;
switch (_that) {
case _PostResponseEngineInput() when $default != null:
return $default(_that.input,_that.initialRequestMessageId,_that.requestMessages,_that.result,_that.conversationManager);case _:
  return null;

}
}

}

/// @nodoc


class _PostResponseEngineInput extends PostResponseEngineInput {
  const _PostResponseEngineInput({required this.input, required this.initialRequestMessageId, required this.requestMessages, required this.result, required this.conversationManager}): super._();
  

@override final  QueryContext input;
/// The last user message which trigger this generation
/// it differs from requestMessages which include all the message
@override final  String initialRequestMessageId;
@override final  IList<CoreMessage> requestMessages;
@override final  GenerationResult result;
@override final  ConversationManager conversationManager;

/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostResponseEngineInputCopyWith<_PostResponseEngineInput> get copyWith => __$PostResponseEngineInputCopyWithImpl<_PostResponseEngineInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostResponseEngineInput&&(identical(other.input, input) || other.input == input)&&(identical(other.initialRequestMessageId, initialRequestMessageId) || other.initialRequestMessageId == initialRequestMessageId)&&const DeepCollectionEquality().equals(other.requestMessages, requestMessages)&&(identical(other.result, result) || other.result == result)&&(identical(other.conversationManager, conversationManager) || other.conversationManager == conversationManager));
}


@override
int get hashCode => Object.hash(runtimeType,input,initialRequestMessageId,const DeepCollectionEquality().hash(requestMessages),result,conversationManager);

@override
String toString() {
  return 'PostResponseEngineInput(input: $input, initialRequestMessageId: $initialRequestMessageId, requestMessages: $requestMessages, result: $result, conversationManager: $conversationManager)';
}


}

/// @nodoc
abstract mixin class _$PostResponseEngineInputCopyWith<$Res> implements $PostResponseEngineInputCopyWith<$Res> {
  factory _$PostResponseEngineInputCopyWith(_PostResponseEngineInput value, $Res Function(_PostResponseEngineInput) _then) = __$PostResponseEngineInputCopyWithImpl;
@override @useResult
$Res call({
 QueryContext input, String initialRequestMessageId, IList<CoreMessage> requestMessages, GenerationResult result, ConversationManager conversationManager
});


@override $QueryContextCopyWith<$Res> get input;@override $GenerationResultCopyWith<$Res> get result;

}
/// @nodoc
class __$PostResponseEngineInputCopyWithImpl<$Res>
    implements _$PostResponseEngineInputCopyWith<$Res> {
  __$PostResponseEngineInputCopyWithImpl(this._self, this._then);

  final _PostResponseEngineInput _self;
  final $Res Function(_PostResponseEngineInput) _then;

/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? input = null,Object? initialRequestMessageId = null,Object? requestMessages = null,Object? result = null,Object? conversationManager = null,}) {
  return _then(_PostResponseEngineInput(
input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as QueryContext,initialRequestMessageId: null == initialRequestMessageId ? _self.initialRequestMessageId : initialRequestMessageId // ignore: cast_nullable_to_non_nullable
as String,requestMessages: null == requestMessages ? _self.requestMessages : requestMessages // ignore: cast_nullable_to_non_nullable
as IList<CoreMessage>,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GenerationResult,conversationManager: null == conversationManager ? _self.conversationManager : conversationManager // ignore: cast_nullable_to_non_nullable
as ConversationManager,
  ));
}

/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueryContextCopyWith<$Res> get input {
  
  return $QueryContextCopyWith<$Res>(_self.input, (value) {
    return _then(_self.copyWith(input: value));
  });
}/// Create a copy of PostResponseEngineInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenerationResultCopyWith<$Res> get result {
  
  return $GenerationResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
