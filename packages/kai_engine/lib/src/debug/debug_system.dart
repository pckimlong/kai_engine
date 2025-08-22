/// Debug system for tracking message processing and generation.
///
/// This library provides comprehensive debugging capabilities for tracking
/// the flow of messages through the Kai Engine, including timing information,
/// processing phases, and detailed metadata.
///
/// The main components are:
/// - [DebugTrackingMixin]: A mixin that can be added to classes to easily emit debug events
/// - [KaiDebugTracker]: The main tracker that collects and manages debug information
/// - [KaiDebug]: Utility class for accessing debug information
///
/// Events are emitted throughout the message processing pipeline and collected
/// by the tracker, which makes them available via a stream for real-time
/// debugging UIs.
export 'debug_data.dart';
export 'debug_events.dart';
export 'debug_tracker.dart';
export 'debug_mixin.dart';
export 'debug_utils.dart';
export 'post_response_logger.dart';
