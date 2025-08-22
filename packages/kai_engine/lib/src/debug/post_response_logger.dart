import 'debug_mixin.dart';

/// A convenient logger for tracking post-response engine processes.
///
/// This class provides an easy-to-use API for developers to log
/// their post-response processing steps with automatic timing
/// and error handling.
///
/// Usage example:
/// ```dart
/// final logger = PostResponseLogger(messageId);
///
/// // Start a step
/// final stepLogger = logger.startStep('data_processing',
///   description: 'Processing user data');
///
/// try {
///   // Your implementation logic here
///   stepLogger.info('Started data validation');
///   // ... processing logic ...
///   stepLogger.info('Data validation completed');
///
///   stepLogger.complete(result: {'processed': true});
/// } catch (e) {
///   stepLogger.error('Failed to process data: $e');
///   stepLogger.fail(e);
/// }
/// ```
class PostResponseLogger with DebugTrackingMixin {
  final String messageId;
  final Map<String, DateTime> _stepStartTimes = {};

  PostResponseLogger(this.messageId);

  /// Start a new post-response processing step
  PostResponseStepLogger startStep(
    String stepName, {
    String? description,
    Map<String, dynamic>? data,
  }) {
    _stepStartTimes[stepName] = DateTime.now();
    debugStartPostResponseStep(
      messageId,
      stepName,
      description: description,
      data: data,
    );
    return PostResponseStepLogger._(this, stepName);
  }

  /// Log a message to a specific step
  void logToStep(
    String stepName,
    String level,
    String message, {
    Map<String, dynamic>? data,
  }) {
    debugLogPostResponse(messageId, stepName, level, message, data: data);
  }

  /// Complete a step with optional result data
  void completeStep(
    String stepName, {
    Map<String, dynamic>? result,
    String? status,
  }) {
    final startTime = _stepStartTimes[stepName];
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : Duration.zero;
    debugCompletePostResponseStep(
      messageId,
      stepName,
      duration,
      result: result,
      status: status,
    );
    _stepStartTimes.remove(stepName);
  }

  /// Mark a step as failed with error details
  void failStep(String stepName, Exception error, {String? errorDetails}) {
    final startTime = _stepStartTimes[stepName];
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : Duration.zero;
    debugFailPostResponseStep(
      messageId,
      stepName,
      duration,
      error,
      errorDetails: errorDetails,
    );
    _stepStartTimes.remove(stepName);
  }
}

/// A convenient logger for a specific post-response processing step.
///
/// This class provides logging methods that automatically associate
/// logs with the correct step and handle timing automatically.
class PostResponseStepLogger {
  final PostResponseLogger _parent;
  final String _stepName;

  PostResponseStepLogger._(this._parent, this._stepName);

  /// Log an info message for this step
  void info(String message, {Map<String, dynamic>? data}) {
    _parent.logToStep(_stepName, 'info', message, data: data);
  }

  /// Log a warning message for this step
  void warning(String message, {Map<String, dynamic>? data}) {
    _parent.logToStep(_stepName, 'warning', message, data: data);
  }

  /// Log an error message for this step
  void error(String message, {Map<String, dynamic>? data}) {
    _parent.logToStep(_stepName, 'error', message, data: data);
  }

  /// Log a debug message for this step
  void debug(String message, {Map<String, dynamic>? data}) {
    _parent.logToStep(_stepName, 'debug', message, data: data);
  }

  /// Complete this step with optional result data
  void complete({Map<String, dynamic>? result, String? status}) {
    _parent.completeStep(_stepName, result: result, status: status);
  }

  /// Mark this step as failed with error details
  void fail(Exception error, {String? errorDetails}) {
    _parent.failStep(_stepName, error, errorDetails: errorDetails);
  }

  /// Execute a function and automatically handle completion/failure
  ///
  /// Usage:
  /// ```dart
  /// await stepLogger.execute(() async {
  ///   // Your implementation logic here
  ///   return {'result': 'success'};
  /// });
  /// ```
  Future<T> execute<T>(
    Future<T> Function() action, {
    String? successStatus,
  }) async {
    try {
      final result = await action();

      // If result is a Map, use it as the result data
      if (result is Map<String, dynamic>) {
        complete(result: result, status: successStatus);
      } else {
        complete(result: {'value': result}, status: successStatus);
      }

      return result;
    } catch (e) {
      final exception = e is Exception ? e : Exception(e.toString());
      error('Step failed: $e');
      fail(exception, errorDetails: e.toString());
      rethrow;
    }
  }

  /// Execute a synchronous function and automatically handle completion/failure
  T executeSync<T>(T Function() action, {String? successStatus}) {
    try {
      final result = action();

      // If result is a Map, use it as the result data
      if (result is Map<String, dynamic>) {
        complete(result: result, status: successStatus);
      } else {
        complete(result: {'value': result}, status: successStatus);
      }

      return result;
    } catch (e) {
      final exception = e is Exception ? e : Exception(e.toString());
      error('Step failed: $e');
      fail(exception, errorDetails: e.toString());
      rethrow;
    }
  }
}
