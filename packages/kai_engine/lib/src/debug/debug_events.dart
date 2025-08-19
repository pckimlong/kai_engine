import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../models/core_message.dart';
import '../models/generation_result.dart';
import '../models/query_context.dart';
import 'debug_data.dart';

/// Debug events for decoupled tracking
abstract class DebugEvent {
  final String messageId;
  final DateTime timestamp;

  DebugEvent(this.messageId) : timestamp = DateTime.now();
}

class MessageStartedEvent extends DebugEvent {
  final String originalInput;
  MessageStartedEvent(super.messageId, this.originalInput);
}

class PhaseStartedEvent extends DebugEvent {
  final String phase;
  PhaseStartedEvent(super.messageId, this.phase);
}

class PhaseEndedEvent extends DebugEvent {
  final String phase;
  PhaseEndedEvent(super.messageId, this.phase);
}

class QueryProcessedEvent extends DebugEvent {
  final QueryContext processedQuery;
  QueryProcessedEvent(super.messageId, this.processedQuery);
}

class ContextBuiltEvent extends DebugEvent {
  final IList<CoreMessage> contextMessages;
  final IList<CoreMessage> finalPrompts;
  ContextBuiltEvent(super.messageId, this.contextMessages, this.finalPrompts);
}

class GenerationConfiguredEvent extends DebugEvent {
  final DebugGenerationConfig config;
  GenerationConfiguredEvent(super.messageId, this.config);
}

class StreamingChunkEvent extends DebugEvent {
  final String chunk;
  StreamingChunkEvent(super.messageId, this.chunk);
}

class MessageCompletedEvent extends DebugEvent {
  final IList<CoreMessage> generatedMessages;
  final GenerationUsage? usage;
  MessageCompletedEvent(super.messageId, this.generatedMessages, [this.usage]);
}

class MessageFailedEvent extends DebugEvent {
  final Exception error;
  final String phase;
  MessageFailedEvent(super.messageId, this.error, this.phase);
}

class MetadataAddedEvent extends DebugEvent {
  final String key;
  final dynamic value;
  MetadataAddedEvent(super.messageId, this.key, this.value);
}