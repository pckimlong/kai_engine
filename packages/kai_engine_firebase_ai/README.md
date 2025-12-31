# Kai Engine Firebase AI

[![Pub Version](https://img.shields.io/pub/v/kai_engine_firebase_ai)](https://pub.dev/packages/kai_engine_firebase_ai)
[![GitHub](https://img.shields.io/github/license/pckimlong/kai_engine)](https://github.com/pckimlong/kai_engine/blob/main/LICENSE)

A Firebase AI adapter for the [Kai Engine](https://pub.dev/packages/kai_engine).

## Overview

This package provides Firebase AI (Gemini) integration for the Kai Engine, allowing you to easily use Firebase's generative AI services with the Kai Engine's pipeline architecture.

## Features

- Seamless integration with Firebase AI (Gemini models)
- Implements `GenerationServiceBase` interface from Kai Engine
- Streaming responses with real-time text updates
- Tool/function calling support with automatic execution loop
- Token counting support
- Configurable safety settings and generation parameters
- Built-in infinite loop detection for tool calls

## Getting Started

Add the dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  kai_engine: ^0.1.1
  kai_engine_firebase_ai: ^0.1.1
  firebase_core: ^3.0.0
  firebase_ai: ^3.2.0
```

Or install via command line:

```bash
dart pub add kai_engine kai_engine_firebase_ai firebase_core firebase_ai
```

## Setup

1. Set up Firebase in your project following the [Firebase setup guide](https://firebase.google.com/docs/flutter/setup).

2. Enable the Vertex AI for Firebase API in your Firebase project.

## Usage

### Basic Setup

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_firebase_ai/kai_engine_firebase_ai.dart';

// Initialize Firebase
await Firebase.initializeApp();

// Create the Firebase AI instance
final firebaseAi = FirebaseAI.googleAI();

// Create the generation service
final generationService = FirebaseAiGenerationService(
  firebaseAi: firebaseAi,
  config: GenerativeConfig(
    model: 'gemini-2.0-flash',
    generationConfig: GenerationConfig(
      temperature: 0.7,
      maxOutputTokens: 2048,
    ),
  ),
);

// Use with your chat controller
final chatController = MyChatController(
  conversationManager: conversationManager,
  generationService: generationService,
);
```

### With Tool/Function Calling

```dart
// Define a tool call model
class WeatherCall {
  final String location;
  WeatherCall({required this.location});

  factory WeatherCall.fromJson(Map<String, Object?> json) {
    return WeatherCall(location: json['location'] as String);
  }
}

// Define a tool schema
final class WeatherToolSchema extends FirebaseAiToolSchema<WeatherCall, String> {
  WeatherToolSchema()
    : super(
        parser: WeatherCall.fromJson,
        declaration: FunctionDeclaration(
          'get_weather',
          'Get the current weather for a location',
          parameters: {
            'location': Schema.string(description: 'City name'),
          },
        ),
      );

  @override
  Future<ToolResult<String>> execute(WeatherCall call) async {
    // Fetch weather data...
    final weather = 'Sunny, 25°C in ${call.location}';
    return ToolResult.success(weather, {'weather': weather});
  }
}

// Create service with tools
final generationService = FirebaseAiGenerationService(
  firebaseAi: firebaseAi,
  config: GenerativeConfig(
    model: 'gemini-2.0-flash',
    toolSchemas: [WeatherToolSchema()],
  ),
);
```

### Streaming Responses

```dart
// The service automatically handles streaming
controller.generationStateStream.listen((state) {
  state.when(
    initial: () {},
    loading: (_) => print('Starting...'),
    streamingText: (text) => print('Received: $text'),
    functionCalling: (name) => print('Calling function: $name'),
    complete: (result) => print('Complete!'),
    error: (e) => print('Error: $e'),
  );
});

await controller.submit('What is the weather in Tokyo?');
```

### Custom Message Adapter

```dart
// Use custom adapter if needed
final generationService = FirebaseAiGenerationService(
  firebaseAi: firebaseAi,
  config: config,
  messageAdapter: MyCustomContentAdapter(),
);
```

## Configuration Options

### GenerativeConfig

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | `String` | The Gemini model to use (e.g., 'gemini-2.0-flash') |
| `safetySettings` | `List<SafetySetting>?` | Safety settings for content filtering |
| `generationConfig` | `GenerationConfig?` | Generation parameters (temperature, tokens, etc.) |
| `toolSchemas` | `List<FirebaseAiToolSchema>?` | Tool definitions for function calling |
| `toolConfig` | `ToolingConfig?` | Tool execution configuration |
| `systemPrompt` | `String?` | Default system prompt (overridden by ContextEngine) |

## Related Packages

- [kai_engine](https://pub.dev/packages/kai_engine) - Core AI chat engine
- [kai_engine_chat_ui](https://pub.dev/packages/kai_engine_chat_ui) - Flutter chat UI widgets
- [prompt_block](https://pub.dev/packages/prompt_block) - Structured prompt blocks

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
