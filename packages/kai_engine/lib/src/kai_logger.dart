/// Abstract logger for Kai engine operations
abstract class KaiLogger {
  /// Log informational messages
  Future<void> logInfo(String message, {Object? data});

  /// Log error messages
  Future<void> logError(String message, {Object? error, StackTrace? stackTrace});
}

/// No-op implementation of KaiLogger
class NoOpKaiLogger implements KaiLogger {
  const NoOpKaiLogger();

  @override
  Future<void> logInfo(String message, {Object? data}) async {}

  @override
  Future<void> logError(String message, {Object? error, StackTrace? stackTrace}) async {}
}