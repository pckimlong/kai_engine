# Kai Engine

[![GitHub](https://img.shields.io/github/license/pckimlong/kai_engine)](https://github.com/pckimlong/kai_engine/blob/main/LICENSE)
[![CI](https://github.com/pckimlong/kai_engine/actions/workflows/ci.yml/badge.svg)](https://github.com/pckimlong/kai_engine/actions/workflows/ci.yml)

A modular, extensible AI chat engine built with a pipeline-based architecture.

> **Battle-tested in production** - Powers [Resonate](https://resonate-app-link.com), a modern AI chat application.

## Packages

This repository is a monorepo containing the following packages:

| Package | Description |
|---------|-------------|
| [`kai_engine`](packages/kai_engine/) | The core AI chat engine with a pipeline-based architecture |
| [`kai_engine_firebase_ai`](packages/kai_engine_firebase_ai/) | Firebase AI adapter for the Kai Engine |
| [`kai_inspector`](packages/kai_inspector/) | A powerful debugging and inspection tool for the Kai Engine |

## Overview

The Kai Engine is a flexible framework for building AI-powered chat applications with a clean, modular architecture. It follows a pipeline-first pattern, allowing developers to easily customize and extend the processing pipeline with domain-specific logic.

The core framework provides essential abstractions for building conversational AI applications while remaining unopinionated about concrete implementations, allowing maximum flexibility.

## Features

- **Modular Pipeline Architecture**: Each processing step is a separate component that can be customized or replaced.
- **Extensible Design**: Unlimited extensibility through component composition.
- **Generic Type Support**: Full generic support for using your own message types with MessageAdapter.
- **Stream-Based Responses**: Real-time streaming responses for better user experience.
- **Optimistic UI Updates**: Immediate UI feedback with rollback on errors.
- **Flexible Context Building**: Advanced prompt engineering with parallel and sequential context building.
- **Tool Calling Support**: Native support for AI function/tool calling with type-safe schemas.
- **Template Engine**: Built-in flexible template engine for dynamic content generation.
- **Post-Response Processing**: Process AI responses after generation with custom pipelines.
- **Real-time Inspection**: Debug and monitor AI processing pipelines with Kai Inspector.
- **Type Safety**: Strong typing throughout the system for better developer experience.
- **Comprehensive Testability**: Designed for easy unit and integration testing.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  kai_engine:
    git:
      url: https://github.com/pckimlong/kai_engine.git
      ref: main
      path: packages/kai_engine
```

For Firebase AI integration:

```yaml
dependencies:
  kai_engine_firebase_ai:
    git:
      url: https://github.com/pckimlong/kai_engine.git
      ref: main
      path: packages/kai_engine_firebase_ai
```

For debugging and inspection capabilities (development only):

```yaml
dev_dependencies:
  kai_inspector:
    git:
      url: https://github.com/pckimlong/kai_engine.git
      ref: main
      path: packages/kai_inspector
```

## Documentation

See the individual package READMEs for detailed documentation:
- [kai_engine README](packages/kai_engine/README.md)
- [kai_engine_firebase_ai README](packages/kai_engine_firebase_ai/README.md)
- [kai_inspector README](packages/kai_inspector/README.md)

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report issues, or request features.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.