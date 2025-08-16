# Kai Engine Firebase AI Adapter

[![Pub Version](https://img.shields.io/pub/v/kai_engine_firebase_ai)](https://pub.dev/packages/kai_engine_firebase_ai)
[![GitHub](https://img.shields.io/github/license/pckimlong/kai_engine)](https://github.com/pckimlong/kai_engine/blob/main/LICENSE)

A Firebase AI adapter for the Kai Engine.

## Overview

This package provides a Firebase AI integration for the [Kai Engine](https://pub.dev/packages/kai_engine), allowing you to easily use Firebase's AI services with the Kai Engine's pipeline architecture.

## Features

- Seamless integration with Firebase AI services
- Implements the `GenerationServiceBase` interface from Kai Engine
- Supports streaming responses from Firebase AI
- Handles authentication and error management
- Type-safe API interactions

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  kai_engine_firebase_ai: ^1.0.0
```

## Usage

```dart
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_firebase_ai/kai_engine_firebase_ai.dart';

// Create the Firebase AI generation service
final generationService = FirebaseAIGenerationService(
  // Configure your Firebase AI settings
  model: 'gemini-pro',
  apiKey: 'your-api-key',
);

// Create your chat controller with the Firebase AI service
final chatController = MyChatController(
  conversationManager: conversationManager,
  generationService: generationService,
  queryEngine: queryEngine,
  postResponseEngine: postResponseEngine,
  messageAdapter: messageAdapter,
);
```

## Documentation

For complete documentation, see the [Kai Engine documentation](https://github.com/pckimlong/kai_engine).

## Contributing

Contributions are welcome! Please read our [Contributing Guide](../../CONTRIBUTING.md) for details on how to submit pull requests, report issues, or request features.

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.