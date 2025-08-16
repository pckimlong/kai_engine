import 'package:kai_engine/src/models/conversation_session.dart';

import 'models/core_message.dart';

/// Class response for transform CoreMessage type to any type
abstract interface class MessageAdapterBase<T> {
  T fromCoreMessage(CoreMessage message, {required ConversationSession session});
  CoreMessage toCoreMessage(T object);
}

/// Adapter for convert CoreMessage to AI-generated messages
abstract interface class GenerativeMessageAdapterBase<T> {
  T fromCoreMessage(CoreMessage message);
  CoreMessage toCoreMessage(T object);
}

/// Prebuilt adapter for CoreMessage which required for simple transformations
/// eg memory conversation
final class CoreMessageAdapter implements MessageAdapterBase<CoreMessage> {
  @override
  CoreMessage fromCoreMessage(CoreMessage message, {required ConversationSession session}) {
    return message;
  }

  @override
  CoreMessage toCoreMessage(CoreMessage object) {
    return object;
  }
}
