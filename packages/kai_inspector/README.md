# Kai Inspector

A powerful debugging and inspection tool for the Kai Engine, providing real-time visibility into AI chat processing pipelines.

## Overview

Kai Inspector is a Flutter package that provides a comprehensive debugging UI for applications built with the [Kai Engine](https://github.com/pckimlong/kai_engine). It offers real-time insights into the execution of chat processing pipelines, helping developers understand, optimize, and debug their AI chat applications.

With Kai Inspector, you can:
- Visualize the complete execution timeline of chat messages
- Monitor performance metrics and token usage
- Identify bottlenecks and optimize processing phases
- Debug errors and warnings in real-time
- Analyze AI generation quality and efficiency

## Features

- **Real-time Timeline Visualization**: See each phase of message processing as it happens
- **Performance Metrics Dashboard**: Track response times, token usage, and throughput
- **Detailed Phase Analysis**: Drill down into specific processing phases and steps
- **Token Usage Analytics**: Monitor and optimize token consumption
- **Error and Warning Tracking**: Identify and resolve issues quickly
- **Export Capabilities**: Export session data for offline analysis
- **Modular Design**: Clean separation between core engine and inspection UI

## Architecture

Kai Inspector follows a clean, decoupled architecture that integrates seamlessly with the Kai Engine:

1. **Two-Package Structure**:
   - `kai_engine`: Contains all core chat processing logic (platform-agnostic)
   - `kai_inspector`: Provides Flutter-based debugging UI and tools

2. **Contract-Based Integration**:
   - `kai_engine` defines the inspection contract through data models and service interfaces
   - `kai_inspector` implements the UI and default in-memory storage
   - Loose coupling allows for custom implementations without modifying core engine

## Installation

Add `kai_inspector` to your `pubspec.yaml` as a dev dependency:

```yaml
dev_dependencies:
  kai_inspector:
    git:
      url: https://github.com/pckimlong/kai_engine.git
      ref: main
      path: packages/kai_inspector
```

## Usage

1. Create an inspector instance in your app:
```dart
import 'package:kai_inspector/kai_inspector.dart';

final inspector = DefaultKaiInspector();
```

2. Inject the inspector into your Kai Engine controller:
```dart
final chatController = ChatController(
  // ... other services
  inspector: inspector, // Injecting the service
);
```

3. Use the inspector UI in your debug screen:
```dart
// In your debug UI
KaiInspectorScreen(inspector: inspector);
```

Note: When `inspector` is `null`, the inspection feature is completely disabled with zero performance overhead.

## UI Components

### Session Dashboard
Get a high-level overview of your debugging session with key metrics and quality insights.

### Timeline Analysis
Visualize the complete execution flow of individual messages with detailed phase breakdowns.

### Token Analytics
Analyze token usage patterns, efficiency metrics, and cost analysis.

### Advanced Logging
Filter, search, and export detailed logs from all processing phases.

## Development

This package is designed to be used in development environments only. The inspector has no impact on production performance when not injected.

## License

MIT License - see [LICENSE](LICENSE) file for details.