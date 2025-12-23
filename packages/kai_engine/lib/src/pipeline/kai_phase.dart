/// Minimal phase abstraction for the Kai Engine pipeline.
///
/// A phase is a unit of work that takes an [Input] and produces an [Output].
/// Implementations should put all logic in [execute].
abstract class KaiPhase<Input, Output> {
  Future<Output> execute(Input input);
}

