import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_state.freezed.dart';

@freezed
sealed class ConversationState with _$ConversationState {
  const ConversationState._();

  const factory ConversationState.initial() = _ConversationStateInitial;
  const factory ConversationState.loading() = _ConversationStateLoading;
  const factory ConversationState.loaded() = _ConversationStateLoaded;
}
