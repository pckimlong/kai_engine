/// Role: The base class for all major, "inspectable" operations in the engine,
/// such as QueryEngineBase or GenerationServiceBase.
///
/// Flow: A core engine component (e.g., GenerationServiceBase) will extend this
/// class. This provides two benefits:
/// 1. It standardizes the operation under a single `execute(Input)` method.
/// 2. It seamlessly provides developer-facing helper methods (`withStep`, `addLog`)
///    that can be called with `this.` from inside the implementation. These helpers
///    get the context they need from the private `PhaseController`.
abstract class KaiPhase<Input, Output> {
  /// The developer-facing method to implement the phase's logic.
  // Future<Output> execute(Input input);
}
