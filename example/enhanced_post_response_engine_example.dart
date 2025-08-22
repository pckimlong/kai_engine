import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:kai_engine/kai_engine.dart';

/// Example implementation showing how to use the enhanced PostResponseEngine
/// with integrated debug logging capabilities.
class UserDataPostResponseEngine extends PostResponseEngineBase
    with PostResponseEngineDebugMixin {
  @override
  Future<void> processWithDebug({
    required QueryContext input,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
    required String messageId,
  }) async {
    // Create a logger for this engine instance
    final logger = createLogger(messageId);

    // Example 1: Simple step tracking
    await _updateUserPreferences(logger, input, result);

    // Example 2: Parallel processing
    await _performParallelTasks(logger, input, result, conversationManager);

    // Example 3: Sequential processing with dependencies
    await _performSequentialAnalysis(logger, result, conversationManager);
  }

  Future<void> _updateUserPreferences(
    PostResponseLogger logger,
    QueryContext input,
    GenerationResult result,
  ) async {
    final stepLogger = logger.startStep(
      'user_preferences_update',
      description: 'Analyzing conversation to update user preferences',
      data: {'messageCount': result.generatedMessages.length},
    );

    try {
      await stepLogger.execute(() async {
        stepLogger.info('Analyzing conversation patterns');

        // Simulate analyzing the conversation
        await Future.delayed(const Duration(milliseconds: 80));

        // Extract topics or themes from the conversation
        final topics = _extractTopics(result.generatedMessages);
        stepLogger.info('Extracted ${topics.length} topics from conversation');
        stepLogger.debug('Topics found: ${topics.join(", ")}');

        // Update user preferences based on topics
        stepLogger.info('Updating user preference weights');
        await _updatePreferenceWeights(topics);

        stepLogger.info('User preferences updated successfully');

        return {
          'updatedTopics': topics,
          'preferenceChanges': topics.length,
          'timestamp': DateTime.now().toIso8601String(),
        };
      });
    } catch (e) {
      // Error handling is automatic with execute()
      print('Failed to update user preferences: $e');
    }
  }

  Future<void> _performParallelTasks(
    PostResponseLogger logger,
    QueryContext input,
    GenerationResult result,
    ConversationManager conversationManager,
  ) async {
    // Run multiple tasks in parallel
    final futures = [
      _updateConversationCache(logger, conversationManager),
      _recordAnalytics(logger, input, result),
      _checkAndSendNotifications(logger, result),
    ];

    await Future.wait(futures);
  }

  Future<void> _updateConversationCache(
    PostResponseLogger logger,
    ConversationManager conversationManager,
  ) async {
    final stepLogger = logger.startStep(
      'conversation_cache_update',
      description: 'Updating conversation cache for faster retrieval',
    );

    await stepLogger.execute(() async {
      stepLogger.info('Retrieving current conversation state');
      final messages = await conversationManager.getMessages();

      stepLogger.info('Calculating cache keys');
      await Future.delayed(const Duration(milliseconds: 30));

      stepLogger.info('Updating cache entries');
      await Future.delayed(const Duration(milliseconds: 60));

      stepLogger.info('Cache update completed');

      return {
        'cacheEntriesUpdated': messages.length,
        'cacheSize': messages.length * 1024, // Simulated cache size
      };
    });
  }

  Future<void> _recordAnalytics(
    PostResponseLogger logger,
    QueryContext input,
    GenerationResult result,
  ) async {
    final stepLogger = logger.startStep(
      'analytics_recording',
      description: 'Recording conversation analytics and metrics',
    );

    await stepLogger.execute(() async {
      stepLogger.info('Calculating conversation metrics');

      // Calculate response quality metrics
      final responseLength = result.displayMessage.content.length;
      final responseTime = DateTime.now()
          .difference(
            DateTime.now().subtract(const Duration(milliseconds: 500)),
          )
          .inMilliseconds;

      stepLogger.debug('Response length: $responseLength characters');
      stepLogger.debug('Response time: ${responseTime}ms');

      stepLogger.info('Sending metrics to analytics service');
      await Future.delayed(const Duration(milliseconds: 40));

      stepLogger.info('Analytics recorded successfully');

      return {
        'metricsRecorded': 5,
        'responseLength': responseLength,
        'responseTime': responseTime,
      };
    });
  }

  Future<void> _checkAndSendNotifications(
    PostResponseLogger logger,
    GenerationResult result,
  ) async {
    final stepLogger = logger.startStep(
      'notification_processing',
      description: 'Checking and sending relevant notifications',
    );

    try {
      await stepLogger.execute(() async {
        stepLogger.info('Checking notification triggers');

        // Check if response contains important information
        final hasImportantInfo = _checkForImportantContent(
          result.displayMessage.content,
        );

        if (!hasImportantInfo) {
          stepLogger.info('No notification triggers found');
          return {'notificationsSent': 0, 'reason': 'no_triggers'};
        }

        stepLogger.info('Important content detected, preparing notifications');
        await Future.delayed(const Duration(milliseconds: 50));

        // Simulate potential notification service failure
        if (DateTime.now().millisecond % 4 == 0) {
          throw Exception('Notification service temporarily unavailable');
        }

        stepLogger.info('Sending notifications to relevant users');
        await Future.delayed(const Duration(milliseconds: 70));

        stepLogger.info('Notifications sent successfully');

        return {
          'notificationsSent': 3,
          'notificationType': 'important_content',
          'recipients': ['user1', 'user2', 'user3'],
        };
      });
    } catch (e) {
      // Notification failures are often non-critical
      stepLogger.warning('Notifications failed but continuing: $e');
    }
  }

  Future<void> _performSequentialAnalysis(
    PostResponseLogger logger,
    GenerationResult result,
    ConversationManager conversationManager,
  ) async {
    // Step 1: Extract entities and intents
    final extractionStep = logger.startStep(
      'entity_extraction',
      description: 'Extracting entities and intents from conversation',
    );

    final extractedData = await extractionStep.execute(() async {
      extractionStep.info('Analyzing message content');

      final entities = _extractEntities(result.displayMessage.content);
      final intents = _extractIntents(result.displayMessage.content);

      extractionStep.info(
        'Found ${entities.length} entities and ${intents.length} intents',
      );
      extractionStep.debug('Entities: ${entities.join(", ")}');
      extractionStep.debug('Intents: ${intents.join(", ")}');

      await Future.delayed(const Duration(milliseconds: 90));

      return {'entities': entities, 'intents': intents, 'confidence': 0.87};
    });

    // Step 2: Update knowledge graph (depends on step 1)
    final knowledgeStep = logger.startStep(
      'knowledge_graph_update',
      description: 'Updating knowledge graph with extracted information',
      data: {'entitiesFound': (extractedData['entities'] as List).length},
    );

    final knowledgeResult = await knowledgeStep.execute(() async {
      final entities = extractedData['entities'] as List<String>;
      // final intents = extractedData['intents'] as List<String>;

      knowledgeStep.info(
        'Processing ${entities.length} entities for knowledge graph',
      );

      if (entities.isEmpty) {
        knowledgeStep.warning(
          'No entities to process, skipping knowledge graph update',
        );
        return {'graphUpdated': false, 'reason': 'no_entities'};
      }

      knowledgeStep.info('Creating entity relationships');
      await Future.delayed(const Duration(milliseconds: 120));

      knowledgeStep.info('Updating entity confidence scores');
      await Future.delayed(const Duration(milliseconds: 80));

      knowledgeStep.info('Knowledge graph updated successfully');

      return {
        'graphUpdated': true,
        'entitiesProcessed': entities.length,
        'relationshipsCreated': entities.length * 2,
      };
    });

    // Step 3: Generate insights (depends on steps 1 & 2)
    final insightsStep = logger.startStep(
      'insight_generation',
      description: 'Generating insights from conversation analysis',
      data: {
        'extractedData': extractedData,
        'knowledgeResult': knowledgeResult,
      },
    );

    await insightsStep.execute(() async {
      insightsStep.info('Combining extraction and knowledge graph data');

      final graphUpdated = knowledgeResult['graphUpdated'] as bool;
      final confidence = extractedData['confidence'] as double;

      if (!graphUpdated || confidence < 0.8) {
        insightsStep.warning(
          'Low confidence or failed graph update, generating basic insights',
        );
      } else {
        insightsStep.info(
          'High confidence data available, generating advanced insights',
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));

      insightsStep.info('Insights generated and stored');

      return {
        'insightsGenerated': true,
        'insightCount': graphUpdated ? 8 : 3,
        'insightQuality': confidence > 0.8 ? 'high' : 'medium',
      };
    });
  }

  // Helper methods for simulation
  List<String> _extractTopics(IList<CoreMessage> messages) {
    // Simulate topic extraction
    return ['technology', 'productivity', 'communication'];
  }

  Future<void> _updatePreferenceWeights(List<String> topics) async {
    // Simulate preference weight updates
    await Future.delayed(const Duration(milliseconds: 50));
  }

  bool _checkForImportantContent(String text) {
    // Simulate checking for important content
    return text.contains('important') ||
        text.contains('urgent') ||
        text.length > 200;
  }

  List<String> _extractEntities(String text) {
    // Simulate entity extraction
    return ['OpenAI', 'Flutter', 'Dart', 'API'];
  }

  List<String> _extractIntents(String text) {
    // Simulate intent extraction
    return ['information_request', 'help_needed'];
  }
}

/// Example of a simpler post-response engine
class SimpleNotificationEngine extends PostResponseEngineBase
    with PostResponseEngineDebugMixin {
  @override
  Future<void> processWithDebug({
    required QueryContext input,
    required IList<CoreMessage> requestMessages,
    required GenerationResult result,
    required ConversationManager conversationManager,
    required String messageId,
  }) async {
    final logger = createLogger(messageId);

    final stepLogger = logger.startStep(
      'simple_notification',
      description: 'Sending simple notification about conversation completion',
    );

    stepLogger.info('Conversation completed, preparing notification');

    try {
      // Simple notification logic
      await Future.delayed(const Duration(milliseconds: 30));

      stepLogger.info('Notification sent successfully');
      stepLogger.complete(result: {'notificationSent': true});
    } catch (e) {
      stepLogger.error('Failed to send notification: $e');
      stepLogger.fail(Exception(e.toString()));
    }
  }
}

/// Usage in your application:
///
/// ```dart
/// final postResponseEngine = UserDataPostResponseEngine();
///
/// // The engine will automatically log all its steps to the debug timeline
/// await postResponseEngine.process(
///   input: queryContext,
///   requestMessages: messages,
///   result: generationResult,
///   conversationManager: manager,
/// );
///
/// // View the timeline in debug screen to see all the logged steps
/// ```
