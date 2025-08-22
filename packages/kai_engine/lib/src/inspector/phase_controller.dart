/// Role: An internal, short-lived context carrier object.
///
/// Flow: This class is not intended for public use. The ChatController creates
/// an instance of this class before it runs a `KaiPhase`. It bundles together a
/// reference to the main `KaiInspector` service and the IDs for the current
/// session and timeline. It is then passed to an internal `run` method on the
/// `KaiPhase`, giving the phase's helper methods the context they need to
/// record data to the correct place.
class PhaseController {
  // In a full implementation, this would hold:
  // final KaiInspector inspector;
  // final String sessionId;
  // final String timelineId;
  // final String phaseName;
}
