# Prompt Block

[![Pub Version](https://img.shields.io/pub/v/prompt_block)](https://pub.dev/packages/prompt_block)
[![GitHub](https://img.shields.io/github/license/pckimlong/kai_engine)](https://github.com/pckimlong/kai_engine/blob/main/packages/prompt_block/LICENSE)

A powerful Dart package for creating and managing structured prompt blocks in AI applications.

## Overview

The Prompt Block package provides a flexible framework for creating, managing, and organizing prompt blocks used in AI applications. It offers a modular approach to prompt engineering with support for templates, variables, and dynamic content generation. With fluent APIs and multiple formatting options, you can easily build complex, structured prompts for AI models.

## Features

- **Modular Prompt Blocks**: Create reusable prompt components that can be combined and nested
- **Multiple Formatting Options**: Support for titles, XML-style tags, bullet lists, and code blocks
- **Template Engine**: Built-in flexible template engine for dynamic content generation
- **Variable Interpolation**: Support for variable substitution in prompts
- **Conditional Logic**: Conditional blocks based on variable values
- **Looping Constructs**: Iterate over collections to generate dynamic content
- **Dynamic Content Building**: Generate content dynamically using `ContentBuilder`
- **Collection Processing**: Process collections with `addEach` method
- **Conditional Rendering**: Control rendering with `when()` and `includeIf()`
- **Automatic Empty Handling**: Automatically hide empty sections with `omitWhenEmpty()`
- **Compact Formatting**: Render XML sections on a single line with `compact()`
- **Extensible Design**: Easily extend with custom functions and processors
- **Type Safety**: Strong typing throughout the system for better developer experience
- **Comprehensive Testability**: Designed for easy unit and integration testing

## Getting Started

### Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  prompt_block:
    git:
      url: https://github.com/pckimlong/kai_engine.git
      ref: main
      path: packages/prompt_block
```

Then run:

```bash
flutter pub get
```

### Basic Usage

Import the package in your Dart code:

```dart
import 'package:prompt_block/prompt_block.dart';
```

## Usage Examples

### Basic Prompt Block

Create simple prompt blocks with titles and body content:

```dart
final prompt = PromptBlock(
  title: '# User Profile',
  body: [
    'Name: John Doe',
    'Age: 30',
    'Occupation: Software Engineer'
  ]
);

print(prompt.output());
```

Output:
```
# User Profile
Name: John Doe
Age: 30
Occupation: Software Engineer
```

### XML-Style Tags

Create structured content using XML-style tags:

```dart
final prompt = PromptBlock.xml(
  'user_context',
  attributes: {'id': '123', 'role': 'admin'},
  children: [
    PromptBlock.xmlText('name', 'John Doe'),
    PromptBlock.xmlText('email', 'john@example.com')
  ]
);

print(prompt.output());
```

Output:
```xml
<user_context id="123" role="admin">
  <name>
    John Doe
  </name>

  <email>
    john@example.com
  </email>
</user_context>
```

### Bullet Lists

Create formatted lists with different bullet styles:

```dart
final prompt = PromptBlock(
  title: '## Key Points',
  children: [
    PromptBlock.bulletList([
      'First important point',
      'Second important point',
      'Third important point'
    ], type: BulletType.hyphen)
  ]
);

print(prompt.output());
```

Output:
```
## Key Points

- First important point
- Second important point
- Third important point
```

### Code Blocks

Include code snippets in your prompts:

```dart
final code = '''
void main() {
 print("Hello, World!");
  runApp(MyApp());
}''';

final prompt = PromptBlock(
  title: '## Example Code',
  children: [
    PromptBlock.codeBlock(code, language: 'dart')
  ]
);

print(prompt.output());
```

Output:
```
## Example Code

```dart
void main() {
  print("Hello, World!");
  runApp(MyApp());
}
```
```

### Dynamic Content Building

Generate content dynamically using `ContentBuilder`:

```dart
final prompt = PromptBlock.build((builder) {
  builder.addLine('User ID: user-12345');
  builder.addLineIf(true, 'Debug Mode: Enabled');
  builder.addLine('Timestamp: ${DateTime.now()}');
  builder.addLines(['Line 1', 'Line 2', 'Line 3']);
});

print(prompt.output());
```

### Conditional Rendering

Control which sections are included in the final prompt:

```dart
bool isDebugMode = false;
List<String> errors = ['Connection timed out', 'Authentication failed'];

final prompt = PromptBlock(title: '# System Prompt')
  .add(PromptBlock.xmlText('user_id', 'user-12345').compact())
  .add(
    PromptBlock.xml('errors')
      .addEach(errors, (error) => PromptBlock.xmlText('error', error).compact())
      .omitWhenEmpty()
  )
  .add(
    PromptBlock.xml('debug_info')
      .includeIf(isDebugMode)
      .add(PromptBlock.codeBlock('Session ID: abc-xyz\nTimestamp: 2024-01-01 12:00:00'))
  )
  .add(PromptBlock(title: '## Task', body: ['Analyze the user request.']));

print(prompt.output());
```

### Complex Nested Structure

Build complex, nested prompt structures:

```dart
final prompt = PromptBlock(title: '# Final Prompt For AI')
  .add(
    PromptBlock.xml('user_context', attributes: {'name': 'Kim'})
      .add(
        PromptBlock(title: '## User Profile').add(
          PromptBlock.bulletList([
            'Currently pursuing a Master\'s degree',
            'Expected graduation: September 2025',
            'Interests: AI, Dart, Flutter',
          ]),
        ),
      )
      .add(
        PromptBlock.xml('conversation_history', attributes: {'turns': '2'}).addAll([
          PromptBlock.xml(
            'memory',
            attributes: {'author': 'assistant'},
          ).add(PromptBlock(body: ['Hey Kim! Good morning.'])),
          PromptBlock.xml(
            'memory',
            attributes: {'author': 'user'},
          ).add(PromptBlock(body: ['Good morning to you too!'])),
        ]),
      ),
  )
  .add(
    PromptBlock(title: '## Task').add(
      PromptBlock(
        body: ['Summarize the user\'s current status based on the context provided.'],
      ),
    ),
  );

print(prompt.output());
```

## API Documentation

### Main Classes

#### `PromptBlock`

The core class for creating structured prompt sections.

**Constructors:**

- `PromptBlock({String? title, List<String> body, BulletType bodyBullet, List<PromptBlock> children})` - Basic constructor
- `PromptBlock.xml(String tag, {Map<String, String> attributes, List<PromptBlock> children})` - Creates XML-style tagged sections
- `PromptBlock.xmlText(String tag, String text, {Map<String, String> attributes})` - Creates XML sections with text content
- `PromptBlock.bulletList(List<String> items, {BulletType type})` - Creates bullet list sections
- `PromptBlock.codeBlock(String code, {String? language})` - Creates code block sections
- `PromptBlock.build(void Function(ContentBuilder) builder)` - Creates sections with dynamically built content
- `PromptBlock.xmlFrom(String tag, {Map<String, String> attributes, String? Function()? builder})` - Creates XML sections with content from a builder function

**Methods:**

- `add(PromptBlock child)` - Adds a single child section
- `addAll(List<PromptBlock> children)` - Adds multiple child sections
- `addEach<T>(Iterable<T> items, PromptBlock Function(T item) builder)` - Adds sections for each item in a collection
- `when(dynamic condition)` - Conditionally renders the section
- `includeIf(dynamic condition)` - Conditionally includes the section
- `omitWhenEmpty()` - Automatically omits the section if it has no content
- `compact()` - Renders XML sections on a single line
- `addMapAsXml(Map<String, dynamic> data)` - Converts a map to nested XML structure
- `addMapAsCodeBlock(Map<String, dynamic> data)` - Converts a map to a JSON code block
- `copyWith({...})` - Creates a copy with updated values
- `output()` - Generates the final formatted prompt string

**Properties:**

- `children` - Unmodifiable view of the section's children
- `shouldRender` - Whether the section is configured to be rendered

#### `ContentBuilder`

Helper class for dynamically building multi-line content.

**Methods:**

- `addLine(String line)` - Adds a single line
- `addLines(List<String> lines)` - Adds multiple lines
- `addLineIf(bool condition, String line)` - Adds a line conditionally
- `build()` - Builds and returns the content as a list of strings

#### `BulletType`

Enum for defining bullet point styles:

- `BulletType.number` - Numbered list (1., 2., 3., ...)
- `BulletType.hyphen` - Hyphenated list (- item)
- `BulletType.none` - No bullets (plain text list)

## Test Organization

The package includes comprehensive tests organized into multiple files:

- `prompt_block_test.dart` - Core functionality tests
- `prompt_block_constructors_test.dart` - Constructor-specific tests
- `prompt_block_builders_test.dart` - Content builder tests
- `prompt_block_data_test.dart` - Data conversion tests
- `prompt_block_extension_test.dart` - Extension method tests
- `prompt_block_core_test.dart` - Core feature tests
- `prompt_block_integration_test.dart` - Integration tests

All tests follow standard Dart testing conventions and can be run with:

```bash
dart test
```

## Contributing

Contributions are welcome! Please read our [Contributing Guide](https://github.com/pckimlong/kai_engine/blob/main/CONTRIBUTING.md) for details on how to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Documentation

- [API Reference](https://pub.dev/documentation/prompt_block/latest/)
- [GitHub Repository](https://github.com/pckimlong/kai_engine/tree/main/packages/prompt_block)
- [Issue Tracker](https://github.com/pckimlong/kai_engine/issues)
