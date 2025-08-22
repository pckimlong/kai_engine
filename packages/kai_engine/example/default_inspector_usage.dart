import 'package:kai_engine/kai_engine.dart';

/// Example showing how to use the DefaultKaiInspector for comprehensive debugging
void main() async {
  // 1. Create the DefaultKaiInspector
  final inspector = DefaultKaiInspector();

  // 2. Set up your ChatController with the inspector
  // Note: This is just example code - you'll need to provide actual implementations
  // final chatController = YourChatController(
  //   conversationManager: yourConversationManager,
  //   generationService: yourGenerationService, 
  //   queryEngine: yourQueryEngine,
  //   postResponseEngine: yourPostResponseEngine,
  //   inspector: inspector,
  // );

  // 3. Listen to session updates for real-time debugging
  final sessionId = 'my-session-123';
  inspector.getSessionStream(sessionId).listen((session) {
    print('Session updated:');
    print('- Total messages: ${session.messageCount}');
    print('- Total tokens: ${session.totalTokenUsage}');
    print('- Total cost: \$${session.totalCost.toStringAsFixed(4)}');
    print('- Status: ${session.status}');

    // Print details about each timeline
    for (final timeline in session.timelines) {
      print('\nTimeline ${timeline.id}:');
      print('- User message: "${timeline.userMessage}"');
      print('- Phases: ${timeline.phases.length}');
      print('- Status: ${timeline.status}');
      
      for (final phase in timeline.phases) {
        print('  Phase: ${phase.name}');
        print('  - Duration: ${phase.duration?.inMilliseconds ?? 0}ms');
        print('  - Steps: ${phase.steps.length}');
        print('  - Logs: ${phase.logs.length}');
        print('  - Status: ${phase.status}');
      }
    }
  });

  // 4. Use the chat controller normally (commented out for example)
  // try {
  //   await chatController.submit('Tell me a joke');
  // } catch (e) {
  //   print('Error: $e');
  // }

  // 5. Access debugging data directly
  final session = await inspector.getSession(sessionId);
  if (session != null) {
    print('\nFinal session data:');
    print('Duration: ${session.duration?.inSeconds ?? 0} seconds');
    
    // Export session data for analysis
    final sessionJson = session.toJson();
    print('Session JSON size: ${sessionJson.toString().length} chars');
  }

  // 6. Monitor inspector performance
  print('\nInspector stats: ${inspector.stats}');

  // 7. Clean up when done (important to prevent memory leaks)
  inspector.dispose();
}

/// Example ChatController implementation
base class YourChatController extends ChatControllerBase<CoreMessage> {
  YourChatController({
    required ConversationManager<CoreMessage> conversationManager,
    required GenerationServiceBase generationService,
    required QueryEngineBase queryEngine,
    required PostResponseEngineBase postResponseEngine,
    KaiInspector? inspector,
  }) : super(
          conversationManager: conversationManager,
          generationService: generationService,
          queryEngine: queryEngine,
          postResponseEngine: postResponseEngine,
          inspector: inspector,
        );

  @override
  ContextEngine build() {
    // Return your context engine implementation
    throw UnimplementedError('Implement your context engine');
  }
}

/// Example usage with debug UI
void debugUIExample() async {
  final inspector = DefaultKaiInspector();
  final sessionId = 'debug-session';

  // Start a session for debugging
  await inspector.startSession(sessionId);

  // Your debug UI can use the inspector to display real-time data
  // For Flutter apps, you could use:
  /*
  Widget buildDebugScreen() {
    return StreamBuilder<TimelineSession>(
      stream: inspector.getSessionStream(sessionId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        
        final session = snapshot.data!;
        return InspectorDebugScreen(
          session: session,
          inspector: inspector,
        );
      },
    );
  }
  */

  // For console debugging:
  inspector.getSessionStream(sessionId).listen((session) {
    print('=== Real-time Session Update ===');
    for (final timeline in session.timelines) {
      for (final phase in timeline.phases) {
        for (final log in phase.logs) {
          print('[${log.severity.name.toUpperCase()}] ${log.message}');
          if (log.metadata.isNotEmpty) {
            print('  Metadata: ${log.metadata}');
          }
        }
      }
    }
  });
}