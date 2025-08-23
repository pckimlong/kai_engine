import 'package:freezed_annotation/freezed_annotation.dart';

part 'kai_exception.freezed.dart';

@freezed
sealed class KaiException with _$KaiException implements Exception {
  const KaiException._();

  const factory KaiException.exception([
    String? message,
    StackTrace? stackTrace,
  ]) = _KaiException;

  const factory KaiException.cancelled() = _KaiExceptionCancelled;
  const factory KaiException.noResponse() = _KaiExceptionNoResponse;
  const factory KaiException.toolFailure([String? reason]) =
      _KaiExceptionToolFailure;

  ({String message, StackTrace? stackTrace}) get errorDetails => when(
    exception: (e, s) => (message: e.toString(), stackTrace: s),
    cancelled: () => (message: 'Request was cancelled', stackTrace: null),
    noResponse: () => (message: 'No response received', stackTrace: null),
    toolFailure: (tool) => (message: 'Tool failed: $tool', stackTrace: null),
  );
}
