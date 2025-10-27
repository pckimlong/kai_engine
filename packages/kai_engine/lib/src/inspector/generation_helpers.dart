import 'models/timeline_types.dart';

/// Helper class injected into GenerationServiceBase methods to provide
/// easy access to step-based logging and inspection functionality.
class GenerationStepHelper {
  final void Function(
    String message, {
    TimelineLogSeverity severity,
    Map<String, dynamic>? metadata,
  })
  _addLog;
  final void Function({int? tokenUsage, double? cost}) _updateAggregates;

  const GenerationStepHelper({
    required void Function(
      String, {
      TimelineLogSeverity severity,
      Map<String, dynamic>? metadata,
    })
    addLog,
    required void Function({int? tokenUsage, double? cost}) updateAggregates,
  }) : _addLog = addLog,
       _updateAggregates = updateAggregates;

  /// Add a log entry to the current step/phase
  void addLog(
    String message, {
    TimelineLogSeverity severity = TimelineLogSeverity.info,
    Map<String, dynamic>? metadata,
  }) {
    _addLog(message, severity: severity, metadata: metadata);
  }

  /// Update session aggregates (token usage, cost)
  void updateAggregates({int? tokenUsage, double? cost}) {
    _updateAggregates(tokenUsage: tokenUsage, cost: cost);
  }

  /// Convenience method for logging with info severity
  void logInfo(String message, [Map<String, dynamic>? metadata]) {
    addLog(message, severity: TimelineLogSeverity.info, metadata: metadata);
  }

  /// Convenience method for logging with warning severity
  void logWarning(String message, [Map<String, dynamic>? metadata]) {
    addLog(message, severity: TimelineLogSeverity.warning, metadata: metadata);
  }

  /// Convenience method for logging with error severity
  void logError(String message, [Map<String, dynamic>? metadata]) {
    addLog(message, severity: TimelineLogSeverity.error, metadata: metadata);
  }

  /// Convenience method for logging token usage
  void logTokenUsage(int tokens, {String? context}) {
    final message = context != null
        ? '$context: $tokens tokens used'
        : '$tokens tokens used';
    addLog(message, metadata: {'token_count': tokens});
    updateAggregates(tokenUsage: tokens);
  }
}
