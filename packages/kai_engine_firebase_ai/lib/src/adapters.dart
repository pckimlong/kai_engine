import 'dart:convert';

// ignore: implementation_imports
import 'package:firebase_ai/src/content.dart'; // Access parsePart function
import 'package:kai_engine/kai_engine.dart';

/// Adapter for Firebase AI content to Core Message
class FirebaseAiContentAdapter
    implements GenerativeMessageAdapterBase<Content> {
  const FirebaseAiContentAdapter();

  @override
  Content fromCoreMessage(CoreMessage message) {
    final role = switch (message.type) {
      CoreMessageType.user => 'user',
      CoreMessageType.ai => 'model',
      CoreMessageType.system => 'system',
      CoreMessageType.function => 'function',
      CoreMessageType.unknown => null,
    };

    // Check if we have stored original Content
    if (message.extensions.containsKey('_originalContent')) {
      final originalContentJson = message.extensions['_originalContent'];
      if (originalContentJson != null) {
        try {
          // Parse the entire Content object back from JSON
          final parsedContent = parseContent(originalContentJson);

          // Check if any parts were parsed as UnknownPart that shouldn't be
          final reconstructedParts = <Part>[];
          final originalJson = originalContentJson as Map<String, dynamic>;
          final originalParts =
              (originalJson['parts'] as List?)?.cast<Map<String, dynamic>>() ??
              [];

          for (int i = 0; i < parsedContent.parts.length; i++) {
            final parsedPart = parsedContent.parts[i];

            // If this was parsed as UnknownPart but we have original JSON, try to reconstruct manually
            // Also handle InlineDataPart with null willContinue field
            if ((parsedPart is UnknownPart ||
                    (parsedPart is InlineDataPart &&
                        parsedPart.willContinue == null)) &&
                i < originalParts.length) {
              final originalPartJson = originalParts[i];
              final reconstructedPart = _reconstructPartFromJson(
                originalPartJson,
              );
              reconstructedParts.add(reconstructedPart ?? parsedPart);
            } else {
              reconstructedParts.add(parsedPart);
            }
          }

          return Content(parsedContent.role, reconstructedParts);
        } catch (e) {
          // If parsing fails, fall through to fallback
        }
      }
    }

    // Fallback: create a simple Content from message content
    final parts = <Part>[];
    if (message.content.isNotEmpty) {
      parts.add(TextPart(message.content));
    }

    // If no parts, add an empty text part
    if (parts.isEmpty) {
      parts.add(TextPart(''));
    }

    return Content(role, parts);
  }

  @override
  CoreMessage toCoreMessage(Content content) {
    final parts = content.parts.toList();
    Map<String, dynamic> extensions = {};

    // Extract text from TextParts
    final textParts = parts.whereType<TextPart>();
    final combinedText = textParts.map((part) => part.text).join('\n').trim();

    // Store the entire Content object as JSON for perfect reconstruction
    extensions['_originalContent'] = content.toJson();

    final messageType = switch (content.role) {
      'user' => CoreMessageType.user,
      'model' => CoreMessageType.ai,
      'system' => CoreMessageType.system,
      'function' => CoreMessageType.function,
      _ => CoreMessageType.unknown,
    };

    return CoreMessage.create(
      type: messageType,
      content: combinedText,
      extensions: extensions,
    );
  }

  /// Helper method to manually reconstruct parts that Firebase AI's parseContent doesn't handle
  Part? _reconstructPartFromJson(Map<String, dynamic> partJson) {
    // Handle FunctionResponse
    if (partJson.containsKey('functionResponse')) {
      final fr = partJson['functionResponse'] as Map<String, dynamic>;
      final response = fr['response'];
      return FunctionResponse(
        fr['name'] as String,
        response is Map
            ? Map<String, Object?>.from(response)
            : <String, Object?>{},
        id: fr['id'] as String?,
      );
    }

    // Handle FunctionCall
    if (partJson.containsKey('functionCall')) {
      final fc = partJson['functionCall'] as Map<String, dynamic>;
      final args = fc['args'];
      return FunctionCall(
        fc['name'] as String,
        args is Map ? Map<String, Object?>.from(args) : <String, Object?>{},
        id: fc['id'] as String?,
      );
    }

    // Handle InlineDataPart
    if (partJson.containsKey('inlineData')) {
      final inlineData = partJson['inlineData'] as Map<String, dynamic>;
      final dataStr = inlineData['data'] as String;
      final bytes = base64Decode(dataStr);
      return InlineDataPart(
        inlineData['mimeType'] as String,
        bytes,
        willContinue: inlineData['willContinue'] as bool? ?? false,
      );
    }

    // Handle FileData
    if (partJson.containsKey('fileData')) {
      final fileData = partJson['fileData'] as Map<String, dynamic>;
      return FileData(
        fileData['mimeType'] as String,
        fileData['fileUri'] as String,
      );
    }

    // If we can't reconstruct it, return null
    return null;
  }
}
