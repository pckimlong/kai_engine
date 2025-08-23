import 'package:kai_engine/src/inspector/execution_timeline.dart';
import 'package:kai_engine/src/inspector/models/timeline_phase.dart';
import 'package:kai_engine/src/inspector/models/timeline_session.dart';
import 'package:kai_engine/src/inspector/models/timeline_step.dart';
import 'package:kai_engine/src/inspector/models/timeline_types.dart';
import 'package:kai_engine/src/models/core_message.dart';

/// Adapts inspector timeline data to UI-friendly format for debug screens
class DebugDataAdapter {
  /// Converts TimelineSession to UI timeline overview data
  static SessionOverviewData convertSessionOverview(TimelineSession session) {
    final timelines = session.timelines;
    final totalDuration = session.duration ??
        (timelines.isNotEmpty && timelines.last.endTime != null
            ? timelines.last.endTime!.difference(session.startTime)
            : null);

    // Aggregate phase statistics across all timelines
    final phaseStats = <String, PhaseStatistics>{};
    var totalErrors = 0;
    var totalWarnings = 0;

    for (final timeline in timelines) {
      for (final phase in timeline.phases) {
        final existing = phaseStats[phase.name];
        final duration = phase.duration?.inMilliseconds ?? 0;
        final errorCount = _countLogsByLevel(phase.logs, TimelineLogSeverity.error);
        final warningCount = _countLogsByLevel(phase.logs, TimelineLogSeverity.warning);

        if (existing == null) {
          phaseStats[phase.name] = PhaseStatistics(
            phaseName: phase.name,
            executionCount: 1,
            totalDurationMs: duration,
            averageDurationMs: duration,
            minDurationMs: duration,
            maxDurationMs: duration,
            errorCount: errorCount,
            warningCount: warningCount,
          );
        } else {
          final newCount = existing.executionCount + 1;
          final newTotal = existing.totalDurationMs + duration;
          phaseStats[phase.name] = existing.copyWith(
            executionCount: newCount,
            totalDurationMs: newTotal,
            averageDurationMs: (newTotal / newCount).round(),
            minDurationMs: duration < existing.minDurationMs ? duration : existing.minDurationMs,
            maxDurationMs: duration > existing.maxDurationMs ? duration : existing.maxDurationMs,
            errorCount: existing.errorCount + errorCount,
            warningCount: existing.warningCount + warningCount,
          );
        }

        totalErrors += errorCount;
        totalWarnings += warningCount;
      }
    }

    return SessionOverviewData(
      sessionId: session.id,
      startTime: session.startTime,
      endTime: session.endTime,
      duration: totalDuration,
      status: session.status,
      messageCount: timelines.length,
      totalTokenUsage: session.totalTokenUsage,
      totalCost: session.totalCost,
      totalErrors: totalErrors,
      totalWarnings: totalWarnings,
      phaseStatistics: phaseStats.values.toList()
        ..sort((a, b) => a.phaseName.compareTo(b.phaseName)),
    );
  }

  /// Converts ExecutionTimeline to UI timeline data
  static TimelineOverviewData convertTimelineOverview(ExecutionTimeline timeline) {
    final duration = timeline.duration;
    final totalTokens = _extractTotalTokensFromPhases(timeline.phases);
    final errors = _countTimelineErrors(timeline);
    final warnings = _countTimelineWarnings(timeline);
    final promptPipeline = _extractPromptPipeline(timeline);
    final promptMessages = _extractPromptMessages(timeline);
    final generatedMessages = _extractGeneratedMessages(timeline);

    return TimelineOverviewData(
      timelineId: timeline.id,
      userMessage: timeline.userMessage,
      startTime: timeline.startTime,
      endTime: timeline.endTime,
      duration: duration,
      status: timeline.status,
      phaseCount: timeline.phases.length,
      totalTokens: totalTokens,
      errorCount: errors,
      warningCount: warnings,
      phases: timeline.phases.map(convertPhaseOverview).toList(),
      promptPipeline: promptPipeline,
      promptMessages: promptMessages,
      generatedMessages: generatedMessages,
    );
  }

  /// Converts TimelinePhase to UI phase data
  static PhaseOverviewData convertPhaseOverview(TimelinePhase phase) {
    final tokenMetadata = _extractTokenMetadata(phase);
    final streamingMetadata = _extractStreamingMetadata(phase);

    return PhaseOverviewData(
      phaseId: phase.id,
      phaseName: phase.name,
      description: phase.description,
      startTime: phase.startTime,
      endTime: phase.endTime,
      duration: phase.duration,
      status: phase.status,
      stepCount: phase.steps.length,
      logCount: phase.logs.length,
      errorCount: _countLogsByLevel(phase.logs, TimelineLogSeverity.error),
      warningCount: _countLogsByLevel(phase.logs, TimelineLogSeverity.warning),
      tokenMetadata: tokenMetadata,
      streamingMetadata: streamingMetadata,
      steps: phase.steps.map(convertStepOverview).toList(),
      logs: phase.logs.map(convertLog).toList(),
    );
  }

  /// Converts TimelineStep to UI step data
  static StepOverviewData convertStepOverview(TimelineStep step) {
    return StepOverviewData(
      stepId: step.id,
      stepName: step.name,
      description: step.description,
      startTime: step.startTime,
      endTime: step.endTime,
      duration: step.duration,
      status: step.status,
      logCount: step.logs.length,
      metadata: step.metadata,
      logs: step.logs.map(convertLog).toList(),
    );
  }

  /// Converts TimelineLog to UI log data
  static LogEntryData convertLog(TimelineLog log) {
    return LogEntryData(
      message: log.message,
      timestamp: log.timestamp,
      severity: log.severity,
      metadata: log.metadata,
    );
  }

  /// Extracts token metadata from phase logs and metadata
  static TokenMetadata? _extractTokenMetadata(TimelinePhase phase) {
    // Look for token metadata in phase logs
    for (final log in phase.logs) {
      final metadata = log.metadata;
      if (metadata.containsKey('total_tokens')) {
        return TokenMetadata(
          totalTokens: metadata['total_tokens'] as int? ?? 0,
          inputTokens: metadata['input_tokens'] as int?,
          outputTokens: metadata['output_tokens'] as int?,
          apiCallCount: metadata['api_call_count'] as int?,
          tokensPerSecond: double.tryParse(metadata['tokens_per_second']?.toString() ?? ''),
          tokensPerMs: double.tryParse(metadata['tokens_per_ms']?.toString() ?? ''),
        );
      }
    }
    return null;
  }

  /// Extracts streaming metadata from phase logs
  static StreamingMetadata? _extractStreamingMetadata(TimelinePhase phase) {
    for (final log in phase.logs) {
      final metadata = log.metadata;
      if (metadata.containsKey('stream_events')) {
        return StreamingMetadata(
          streamEvents: metadata['stream_events'] as int? ?? 0,
          chunksReceived: metadata['chunks_received'] as int? ?? 0,
          totalCharacters: metadata['total_characters'] as int? ?? 0,
          averageChunkSize: metadata['average_chunk_size'] as int? ?? 0,
          timeToFirstChunkMs: metadata['time_to_first_chunk_ms'] as int?,
          functionCallsMade: (metadata['function_calls_made'] as List?)?.cast<String>() ?? [],
        );
      }
    }
    return null;
  }

  /// Counts logs by severity level
  static int _countLogsByLevel(List<TimelineLog> logs, TimelineLogSeverity severity) {
    return logs.where((log) => log.severity == severity).length;
  }

  /// Counts total errors in timeline
  static int _countTimelineErrors(ExecutionTimeline timeline) {
    return timeline.phases
        .fold(0, (sum, phase) => sum + _countLogsByLevel(phase.logs, TimelineLogSeverity.error));
  }

  /// Counts total warnings in timeline
  static int _countTimelineWarnings(ExecutionTimeline timeline) {
    return timeline.phases
        .fold(0, (sum, phase) => sum + _countLogsByLevel(phase.logs, TimelineLogSeverity.warning));
  }

  /// Extracts total token usage from phases
  static int _extractTotalTokensFromPhases(List<TimelinePhase> phases) {
    for (final phase in phases) {
      final tokenMetadata = _extractTokenMetadata(phase);
      if (tokenMetadata != null && tokenMetadata.totalTokens > 0) {
        return tokenMetadata.totalTokens;
      }
    }
    return 0;
  }

  /// Extracts real prompt messages from Context Building phase logs
  static PromptMessagesData? _extractPromptMessages(ExecutionTimeline timeline) {
    final contextPhase =
        timeline.phases.where((phase) => phase.name.toLowerCase().contains('context')).firstOrNull;

    if (contextPhase == null) return null;

    // Look for specialized PromptMessagesLog
    for (final promptLog in contextPhase.promptMessagesLogs) {
      final messages = <MessageDisplayData>[];
      var totalCharacters = 0;

      for (final coreMessage in promptLog.promptMessages) {
        final content = coreMessage.content;
        final messageType = _parseMessageTypeFromCoreMessage(coreMessage);

        totalCharacters += content.length;

        messages.add(MessageDisplayData(
          id: coreMessage.messageId,
          type: messageType,
          content: content,
          characterCount: content.length,
          timestamp: coreMessage.timestamp.toIso8601String(),
          coreMessage: coreMessage,
        ));
      }

      return PromptMessagesData(
        messages: messages,
        totalCharacterCount: totalCharacters,
        originalUserInput: timeline.userMessage,
      );
    }

    return null;
  }

  /// Extracts generated messages from AI Generation phase logs
  static GeneratedMessagesData? _extractGeneratedMessages(ExecutionTimeline timeline) {
    final generationPhase = timeline.phases
        .where((phase) => phase.name.toLowerCase().contains('generation'))
        .firstOrNull;

    if (generationPhase == null) return null;

    // Look for specialized GeneratedMessagesLog
    for (final generatedLog in generationPhase.generatedMessagesLogs) {
      final messages = <MessageDisplayData>[];
      var totalCharacters = 0;

      for (final coreMessage in generatedLog.generatedMessages) {
        final content = coreMessage.content;
        final messageType = _parseMessageTypeFromCoreMessage(coreMessage);

        totalCharacters += content.length;

        messages.add(MessageDisplayData(
          id: coreMessage.messageId,
          type: messageType,
          content: content,
          characterCount: content.length,
          timestamp: coreMessage.timestamp.toIso8601String(),
          coreMessage: coreMessage,
        ));
      }

      return GeneratedMessagesData(
        messages: messages,
        totalCharacterCount: totalCharacters,
      );
    }

    return null;
  }

  /// Parses message type from CoreMessage object (preferred method)
  static MessageType _parseMessageTypeFromCoreMessage(CoreMessage coreMessage) {
    switch (coreMessage.type) {
      case CoreMessageType.system:
        return MessageType.system;
      case CoreMessageType.user:
        return MessageType.human;
      case CoreMessageType.ai:
        return MessageType.ai;
      case CoreMessageType.function:
        return MessageType.functionCall;
      case CoreMessageType.unknown:
        return MessageType.unknown;
    }
  }

  /// Extracts complete prompt pipeline from timeline phases
  static PromptPipelineData? _extractPromptPipeline(ExecutionTimeline timeline) {
    final prompts = <PromptSegment>[];

    // Look for Context Building phase to extract structured prompt data
    final contextPhase =
        timeline.phases.where((phase) => phase.name.toLowerCase().contains('context')).firstOrNull;

    // Look for AI Generation phase to get final prompt structure
    final generationPhase = timeline.phases
        .where((phase) => phase.name.toLowerCase().contains('generation'))
        .firstOrNull;

    String systemPrompt = '';
    String contextMessages = '';
    final userInput = timeline.userMessage;
    int promptCount = 1;

    // Extract from context building phase logs
    if (contextPhase != null) {
      for (final log in contextPhase.logs) {
        final metadata = log.metadata;

        // Look for template information
        if (metadata.containsKey('prompt-templates')) {
          final templateCount = metadata['prompt-templates'] as int? ?? 0;
          // Multiple templates suggest system + context + user
          if (templateCount >= 3) {
            systemPrompt = 'System prompt: You\'re kai, a useful friendly personal assistant.';
          }
        }

        // Look for final context messages count
        if (metadata.containsKey('final-context-messages')) {
          final contextCount = metadata['final-context-messages'] as int? ?? 0;
          if (contextCount > 0) {
            contextMessages =
                'Historical context: $contextCount previous messages included for conversation continuity.';
          }
        }

        // Extract from step logs with more detail
        if (log.message.contains('Built') && metadata.containsKey('source-messages')) {
          final sourceCount = metadata['source-messages'] as int? ?? 0;
          if (sourceCount > 0 && contextMessages.isEmpty) {
            contextMessages = 'Conversation history: $sourceCount messages processed for context.';
          }
        }
      }

      // Process step data for more granular information
      for (final step in contextPhase.steps) {
        for (final log in step.logs) {
          if (log.message.contains('Built') && log.message.contains('messages')) {
            final parts = log.message.split(' ');
            final builtCount = int.tryParse(parts.isNotEmpty ? parts[1] : '');
            if (builtCount != null && builtCount > 0) {
              if (step.name.contains('parallel') || step.name.contains('sequential')) {
                contextMessages = contextMessages.isEmpty
                    ? 'Context building: $builtCount messages processed from conversation history.'
                    : contextMessages;
              }
            }
          }
        }
      }
    }

    // Extract final prompt count from generation phase
    if (generationPhase != null) {
      for (final log in generationPhase.logs) {
        if (log.message.contains('Starting AI generation') &&
            log.metadata.containsKey('prompt_count')) {
          promptCount = log.metadata['prompt_count'] as int? ?? 1;
          break;
        }
      }
    }

    // Build structured prompt segments
    if (systemPrompt.isNotEmpty || promptCount > 1) {
      // Multi-part prompt structure
      if (systemPrompt.isEmpty && promptCount >= 2) {
        systemPrompt = 'System prompt: Default AI assistant personality and instructions.';
      }

      if (systemPrompt.isNotEmpty) {
        prompts.add(PromptSegment(
          type: PromptSegmentType.system,
          content: systemPrompt,
          characterCount: systemPrompt.length,
        ));
      }

      if (contextMessages.isNotEmpty) {
        prompts.add(PromptSegment(
          type: PromptSegmentType.context,
          content: contextMessages,
          characterCount: contextMessages.length,
        ));
      } else if (promptCount >= 3) {
        // Infer context from prompt count
        final inferredContext =
            'Context messages: Conversation history included in prompt construction.';
        prompts.add(PromptSegment(
          type: PromptSegmentType.context,
          content: inferredContext,
          characterCount: inferredContext.length,
        ));
      }
    }

    // Always add user input
    prompts.add(PromptSegment(
      type: PromptSegmentType.userInput,
      content: userInput,
      characterCount: userInput.length,
    ));

    return PromptPipelineData(
      totalCharacterCount: prompts.fold(0, (sum, p) => sum + p.characterCount),
      segments: prompts,
    );
  }
}

/// UI-friendly data classes

class SessionOverviewData {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int messageCount;
  final int totalTokenUsage;
  final double totalCost;
  final int totalErrors;
  final int totalWarnings;
  final List<PhaseStatistics> phaseStatistics;

  const SessionOverviewData({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.messageCount,
    required this.totalTokenUsage,
    required this.totalCost,
    required this.totalErrors,
    required this.totalWarnings,
    required this.phaseStatistics,
  });
}

class PhaseStatistics {
  final String phaseName;
  final int executionCount;
  final int totalDurationMs;
  final int averageDurationMs;
  final int minDurationMs;
  final int maxDurationMs;
  final int errorCount;
  final int warningCount;

  const PhaseStatistics({
    required this.phaseName,
    required this.executionCount,
    required this.totalDurationMs,
    required this.averageDurationMs,
    required this.minDurationMs,
    required this.maxDurationMs,
    required this.errorCount,
    required this.warningCount,
  });

  PhaseStatistics copyWith({
    String? phaseName,
    int? executionCount,
    int? totalDurationMs,
    int? averageDurationMs,
    int? minDurationMs,
    int? maxDurationMs,
    int? errorCount,
    int? warningCount,
  }) {
    return PhaseStatistics(
      phaseName: phaseName ?? this.phaseName,
      executionCount: executionCount ?? this.executionCount,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      averageDurationMs: averageDurationMs ?? this.averageDurationMs,
      minDurationMs: minDurationMs ?? this.minDurationMs,
      maxDurationMs: maxDurationMs ?? this.maxDurationMs,
      errorCount: errorCount ?? this.errorCount,
      warningCount: warningCount ?? this.warningCount,
    );
  }
}

class TimelineOverviewData {
  final String timelineId;
  final String userMessage;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int phaseCount;
  final int totalTokens;
  final int errorCount;
  final int warningCount;
  final List<PhaseOverviewData> phases;
  final PromptPipelineData? promptPipeline;
  final PromptMessagesData? promptMessages;
  final GeneratedMessagesData? generatedMessages;

  const TimelineOverviewData({
    required this.timelineId,
    required this.userMessage,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.phaseCount,
    required this.totalTokens,
    required this.errorCount,
    required this.warningCount,
    required this.phases,
    this.promptPipeline,
    this.promptMessages,
    this.generatedMessages,
  });
}

class PhaseOverviewData {
  final String phaseId;
  final String phaseName;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int stepCount;
  final int logCount;
  final int errorCount;
  final int warningCount;
  final TokenMetadata? tokenMetadata;
  final StreamingMetadata? streamingMetadata;
  final List<StepOverviewData> steps;
  final List<LogEntryData> logs;

  const PhaseOverviewData({
    required this.phaseId,
    required this.phaseName,
    this.description,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.stepCount,
    required this.logCount,
    required this.errorCount,
    required this.warningCount,
    this.tokenMetadata,
    this.streamingMetadata,
    required this.steps,
    required this.logs,
  });
}

class StepOverviewData {
  final String stepId;
  final String stepName;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final TimelineStatus status;
  final int logCount;
  final Map<String, dynamic> metadata;
  final List<LogEntryData> logs;

  const StepOverviewData({
    required this.stepId,
    required this.stepName,
    this.description,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.logCount,
    required this.metadata,
    required this.logs,
  });
}

class LogEntryData {
  final String message;
  final DateTime timestamp;
  final TimelineLogSeverity severity;
  final Map<String, dynamic> metadata;

  const LogEntryData({
    required this.message,
    required this.timestamp,
    required this.severity,
    required this.metadata,
  });
}

class TokenMetadata {
  final int totalTokens;
  final int? inputTokens;
  final int? outputTokens;
  final int? apiCallCount;
  final double? tokensPerSecond;
  final double? tokensPerMs;

  const TokenMetadata({
    required this.totalTokens,
    this.inputTokens,
    this.outputTokens,
    this.apiCallCount,
    this.tokensPerSecond,
    this.tokensPerMs,
  });
}

class StreamingMetadata {
  final int streamEvents;
  final int chunksReceived;
  final int totalCharacters;
  final int averageChunkSize;
  final int? timeToFirstChunkMs;
  final List<String> functionCallsMade;

  const StreamingMetadata({
    required this.streamEvents,
    required this.chunksReceived,
    required this.totalCharacters,
    required this.averageChunkSize,
    this.timeToFirstChunkMs,
    required this.functionCallsMade,
  });
}

/// Data class for prompt pipeline information
class PromptPipelineData {
  final int totalCharacterCount;
  final List<PromptSegment> segments;

  const PromptPipelineData({
    required this.totalCharacterCount,
    required this.segments,
  });
}

/// Individual segment in the prompt pipeline
class PromptSegment {
  final PromptSegmentType type;
  final String content;
  final int characterCount;

  const PromptSegment({
    required this.type,
    required this.content,
    required this.characterCount,
  });
}

/// Types of prompt segments
enum PromptSegmentType {
  system,
  context,
  userInput,
}

/// Data class for real prompt messages from CoreMessage objects
class PromptMessagesData {
  final List<MessageDisplayData> messages;
  final int totalCharacterCount;
  final String originalUserInput;

  const PromptMessagesData({
    required this.messages,
    required this.totalCharacterCount,
    required this.originalUserInput,
  });
}

/// Data class for generated messages from CoreMessage objects
class GeneratedMessagesData {
  final List<MessageDisplayData> messages;
  final int totalCharacterCount;

  const GeneratedMessagesData({
    required this.messages,
    required this.totalCharacterCount,
  });
}

/// Individual message display data from CoreMessage
class MessageDisplayData {
  final String id;
  final MessageType type;
  final String content;
  final int characterCount;
  final String? timestamp;
  final Map<String, dynamic>? metadata;
  final CoreMessage coreMessage;

  const MessageDisplayData({
    required this.coreMessage,
    required this.id,
    required this.type,
    required this.content,
    required this.characterCount,
    this.timestamp,
    this.metadata,
  });
}

/// Message types for UI display
enum MessageType {
  system,
  human,
  ai,
  functionCall,
  functionResponse,
  unknown,
}
