import 'package:kai_engine/src/debug/debug_system.dart';

/// Example demonstrating how to use the post-response logging system.
///
/// This example shows different ways to track post-response processing steps
/// that occur after the main AI generation is complete.
class PostResponseExample {
  /// Example 1: Simple step tracking with manual completion
  Future<void> simpleExample(String messageId) async {
    final logger = PostResponseLogger(messageId);

    // Start a step
    final stepLogger = logger.startStep(
      'data_validation',
      description: 'Validating user input data',
    );

    try {
      stepLogger.info('Starting validation process');

      // Simulate some processing
      await Future.delayed(const Duration(milliseconds: 100));

      stepLogger.info('Basic validation completed');

      // Simulate more processing
      await Future.delayed(const Duration(milliseconds: 50));

      stepLogger.info('Advanced validation completed');

      // Complete the step
      stepLogger.complete(
        result: {'validationPassed': true, 'issues': []},
        status: 'success',
      );
    } catch (e) {
      stepLogger.error('Validation failed: $e');
      stepLogger.fail(Exception(e.toString()));
    }
  }

  /// Example 2: Using automatic execution with error handling
  Future<void> automaticExecutionExample(String messageId) async {
    final logger = PostResponseLogger(messageId);

    final stepLogger = logger.startStep(
      'user_preferences_update',
      description: 'Updating user preferences based on conversation',
    );

    // Use execute() for automatic completion/failure handling
    try {
      final result = await stepLogger.execute(() async {
        stepLogger.info('Loading current preferences');

        // Simulate loading preferences
        await Future.delayed(const Duration(milliseconds: 80));

        stepLogger.info('Analyzing conversation context');

        // Simulate analysis
        await Future.delayed(const Duration(milliseconds: 120));

        stepLogger.info('Updating preferences');

        // Simulate update
        await Future.delayed(const Duration(milliseconds: 60));

        return {
          'preferencesUpdated': true,
          'updatedFields': ['theme', 'language'],
          'timestamp': DateTime.now().toIso8601String(),
        };
      });

      print('Preferences updated: $result');
    } catch (e) {
      print('Failed to update preferences: $e');
    }
  }

  /// Example 3: Multiple parallel steps
  Future<void> parallelStepsExample(String messageId) async {
    final logger = PostResponseLogger(messageId);

    // Start multiple steps that run in parallel
    final futures = [
      _performCacheUpdate(logger),
      _performAnalytics(logger),
      _performNotifications(logger),
    ];

    // Wait for all to complete
    await Future.wait(futures);
  }

  Future<void> _performCacheUpdate(PostResponseLogger logger) async {
    final stepLogger = logger.startStep(
      'cache_update',
      description: 'Updating conversation cache',
    );

    await stepLogger.execute(() async {
      stepLogger.info('Invalidating old cache entries');
      await Future.delayed(const Duration(milliseconds: 50));

      stepLogger.info('Writing new cache data');
      await Future.delayed(const Duration(milliseconds: 80));

      return {'cacheUpdated': true, 'entriesUpdated': 5};
    });
  }

  Future<void> _performAnalytics(PostResponseLogger logger) async {
    final stepLogger = logger.startStep(
      'analytics_tracking',
      description: 'Recording conversation analytics',
    );

    await stepLogger.execute(() async {
      stepLogger.info('Calculating conversation metrics');
      await Future.delayed(const Duration(milliseconds: 30));

      stepLogger.info('Sending to analytics service');
      await Future.delayed(const Duration(milliseconds: 40));

      return {'analyticsRecorded': true, 'metricsCount': 8};
    });
  }

  Future<void> _performNotifications(PostResponseLogger logger) async {
    final stepLogger = logger.startStep(
      'push_notifications',
      description: 'Sending relevant notifications',
    );

    try {
      await stepLogger.execute(() async {
        stepLogger.info('Checking notification preferences');
        await Future.delayed(const Duration(milliseconds: 20));

        stepLogger.info('Preparing notification content');
        await Future.delayed(const Duration(milliseconds: 60));

        // Simulate a potential failure
        if (DateTime.now().millisecond % 3 == 0) {
          throw Exception('Notification service temporarily unavailable');
        }

        stepLogger.info('Sending notifications');
        await Future.delayed(const Duration(milliseconds: 40));

        return {'notificationsSent': true, 'recipientCount': 3};
      });
    } catch (e) {
      // Error is automatically logged and step is marked as failed
      print('Notifications failed, but that\'s okay: $e');
    }
  }

  /// Example 4: Sequential steps with complex logging
  Future<void> sequentialStepsExample(String messageId) async {
    final logger = PostResponseLogger(messageId);

    // Step 1: Data preparation
    final prepStep = logger.startStep(
      'data_preparation',
      description: 'Preparing data for post-processing',
      data: {'inputSize': 1024},
    );

    final preparedData = await prepStep.execute(() async {
      prepStep.info('Parsing input data');
      prepStep.debug('Input contains ${1024} characters');

      await Future.delayed(const Duration(milliseconds: 50));

      prepStep.info('Normalizing data format');
      prepStep.debug('Applied 3 normalization rules');

      await Future.delayed(const Duration(milliseconds: 30));

      prepStep.info('Data preparation completed');

      return {'normalizedData': 'processed_content', 'size': 890};
    });

    // Step 2: Processing
    final processStep = logger.startStep(
      'content_processing',
      description: 'Processing the prepared data',
      data: {'inputData': preparedData},
    );

    final processedData = await processStep.execute(() async {
      processStep.info('Starting content analysis');
      processStep.debug('Analyzing ${preparedData['size']} characters');

      await Future.delayed(const Duration(milliseconds: 100));

      processStep.info('Applying business rules');
      processStep.debug('Applied 7 business rules');

      await Future.delayed(const Duration(milliseconds: 80));

      processStep.warning('Some rules had low confidence scores');
      processStep.info('Processing completed');

      return {'processedContent': 'final_result', 'confidence': 0.85};
    });

    // Step 3: Finalization
    final finalStep = logger.startStep(
      'finalization',
      description: 'Finalizing and storing results',
      data: {'processedData': processedData},
    );

    await finalStep.execute(() async {
      finalStep.info('Validating final results');

      if ((processedData['confidence'] as double) < 0.9) {
        finalStep.warning('Confidence below threshold, flagging for review');
      }

      await Future.delayed(const Duration(milliseconds: 40));

      finalStep.info('Storing results to database');
      await Future.delayed(const Duration(milliseconds: 60));

      finalStep.info('Finalization completed successfully');

      return {'stored': true, 'finalConfidence': processedData['confidence']};
    });
  }

  /// Example 5: Error handling and recovery
  Future<void> errorHandlingExample(String messageId) async {
    final logger = PostResponseLogger(messageId);

    final stepLogger = logger.startStep(
      'risky_operation',
      description: 'Performing operation that might fail',
    );

    stepLogger.info('Starting risky operation');

    try {
      // Simulate some work that might fail
      await Future.delayed(const Duration(milliseconds: 50));

      stepLogger.info('Checkpoint 1 reached');

      // Simulate a failure
      if (DateTime.now().millisecond % 2 == 0) {
        throw Exception('Random failure occurred');
      }

      await Future.delayed(const Duration(milliseconds: 50));

      stepLogger.info('Operation completed successfully');
      stepLogger.complete(result: {'success': true});
    } catch (e) {
      stepLogger.error('Operation failed: $e');
      stepLogger.fail(
        Exception(e.toString()),
        errorDetails: 'Failed at checkpoint 1',
      );

      // Start recovery step
      final recoveryStep = logger.startStep(
        'error_recovery',
        description: 'Attempting to recover from failure',
      );

      try {
        await recoveryStep.execute(() async {
          recoveryStep.info('Analyzing failure');
          await Future.delayed(const Duration(milliseconds: 30));

          recoveryStep.info('Attempting recovery');
          await Future.delayed(const Duration(milliseconds: 40));

          recoveryStep.info('Recovery completed');

          return {'recovered': true, 'fallbackUsed': true};
        });
      } catch (recoveryError) {
        // Recovery also failed - this is logged automatically
        print('Recovery also failed: $recoveryError');
      }
    }
  }
}

/// Usage example in your actual implementation:
///
/// ```dart
/// class MyService with DebugTrackingMixin {
///   Future<void> processResponse(String messageId, ResponseData data) async {
///     // ... main AI processing complete ...
///
///     // Now do post-response processing with logging
///     await _performPostResponseProcessing(messageId, data);
///   }
///
///   Future<void> _performPostResponseProcessing(String messageId, ResponseData data) async {
///     final logger = PostResponseLogger(messageId);
///
///     // Your actual post-response logic here
///     final userUpdateStep = logger.startStep('user_data_update');
///
///     try {
///       userUpdateStep.info('Updating user conversation history');
///       await updateUserHistory(data);
///
///       userUpdateStep.info('Calculating user insights');
///       final insights = await calculateInsights(data);
///
///       userUpdateStep.complete(result: {'insights': insights});
///     } catch (e) {
///       userUpdateStep.error('Failed to update user data: $e');
///       userUpdateStep.fail(e);
///     }
///   }
/// }
/// ```
