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
}
