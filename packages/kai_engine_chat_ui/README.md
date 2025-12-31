# Kai Engine Chat UI

[![Pub Version](https://img.shields.io/pub/v/kai_engine_chat_ui)](https://pub.dev/packages/kai_engine_chat_ui)
[![GitHub](https://img.shields.io/github/license/pckimlong/kai_engine)](https://github.com/pckimlong/kai_engine/blob/main/LICENSE)

Flutter chat UI widgets designed for [Kai Engine](https://pub.dev/packages/kai_engine). State-management agnostic - works with any state management solution.

## Features

- Ready-to-use chat view with message list and composer
- Real-time streaming text display
- Typing indicator during AI generation
- Customizable message bubbles and theming
- Message filtering support
- Responsive design (mobile/desktop bubble widths)
- Cancel generation support

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  kai_engine: ^0.1.1
  kai_engine_chat_ui: ^0.1.1
```

Or install via command line:

```bash
flutter pub add kai_engine kai_engine_chat_ui
```

## Usage

### Basic Usage

```dart
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_engine_chat_ui/kai_engine_chat_ui.dart';

class ChatScreen extends StatelessWidget {
  final ChatControllerBase controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoreMessage>>(
      stream: controller.messagesStream,
      builder: (context, messagesSnapshot) {
        return StreamBuilder<GenerationState<GenerationResult>>(
          stream: controller.generationStateStream,
          builder: (context, stateSnapshot) {
            return KaiChatView(
              messages: messagesSnapshot.data ?? [],
              generationState: stateSnapshot.data,
              onSend: (text) => controller.submit(text),
              onCancel: controller.cancel,
            );
          },
        );
      },
    );
  }
}
```

### Customization

#### Custom Message Builder

```dart
KaiChatView(
  messages: messages,
  generationState: generationState,
  onSend: onSend,
  messageBuilder: (context, message) {
    final isUser = message.type == CoreMessageType.user;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message.content),
    );
  },
)
```

#### Custom Transient (Streaming) Builder

```dart
KaiChatView(
  messages: messages,
  generationState: generationState,
  onSend: onSend,
  transientBuilder: (context, state) {
    return state.maybeWhen(
      streamingText: (text) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(text),
        ),
      ),
      loading: (_) => const CircularProgressIndicator(),
      orElse: () => const SizedBox.shrink(),
    );
  },
)
```

#### Message Filtering

```dart
KaiChatView(
  messages: messages,
  generationState: generationState,
  onSend: onSend,
  // Only show user and AI messages (hide system messages, tool calls, etc.)
  messageFilter: (message) {
    return message.type == CoreMessageType.user ||
           message.type == CoreMessageType.ai;
  },
)
```

#### Custom Composer

```dart
KaiChatView(
  messages: messages,
  generationState: generationState,
  onSend: onSend,
  composerBuilder: (context, defaultComposer) {
    // Use the default composer with custom wrapper
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: defaultComposer,
    );
  },
)
```

## Theming

Add `KaiChatTheme` to your app's theme:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      KaiChatTheme(
        maxBubbleWidthMobile: 320,
        maxBubbleWidthDesktop: 480,
        bubbleRadius: 16,
        bubblePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        listPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemSpacing: 12,
        userBubbleColor: Colors.blue,
        aiBubbleColor: Colors.grey[200],
        userTextColor: Colors.white,
        aiTextColor: Colors.black87,
      ),
    ],
  ),
  // ...
)
```

### Theme Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `maxBubbleWidthMobile` | `double` | `320` | Max bubble width on mobile |
| `maxBubbleWidthDesktop` | `double` | `480` | Max bubble width on desktop |
| `bubbleRadius` | `double` | `16` | Border radius of message bubbles |
| `bubblePadding` | `EdgeInsets` | `12h, 10v` | Padding inside bubbles |
| `listPadding` | `EdgeInsets` | `16h, 12v` | Padding around message list |
| `itemSpacing` | `double` | `12` | Spacing between messages |
| `userBubbleColor` | `Color?` | theme-based | User message bubble color |
| `aiBubbleColor` | `Color?` | theme-based | AI message bubble color |
| `userTextColor` | `Color?` | theme-based | User message text color |
| `aiTextColor` | `Color?` | theme-based | AI message text color |

## Widgets

### KaiChatView

The main chat widget combining message list and composer.

```dart
KaiChatView(
  messages: messages,              // Required: List<CoreMessage>
  onSend: (text) async {},         // Required: Send callback
  generationState: state,          // Optional: Current generation state
  onCancel: () {},                 // Optional: Cancel generation callback
  messageFilter: (msg) => true,    // Optional: Filter messages
  messageBuilder: (ctx, msg) => Widget,          // Optional: Custom message UI
  transientBuilder: (ctx, state) => Widget,      // Optional: Custom streaming UI
  onMessageTap: (msg) {},          // Optional: Message tap callback
  reverse: true,                   // Optional: Reverse list order (default: true)
  controller: ScrollController(),  // Optional: Custom scroll controller
  composerPadding: EdgeInsets,     // Optional: Composer padding
  listPadding: EdgeInsets,         // Optional: List padding
  composerBuilder: (ctx, composer) => Widget,    // Optional: Custom composer wrapper
)
```

### KaiComposer

Standalone text input with send/cancel buttons.

```dart
KaiComposer(
  onSend: (text) async {},         // Required: Send callback
  onCancel: () {},                 // Optional: Cancel callback
  isGenerating: false,             // Optional: Show cancel instead of send
  hintText: 'Type a message…',     // Optional: Input hint
  controller: TextEditingController(), // Optional: Custom controller
  autofocus: false,                // Optional: Auto-focus input
  maxLines: 6,                     // Optional: Max input lines
  onError: (e, s) {},              // Optional: Error callback
)
```

## Related Packages

- [kai_engine](https://pub.dev/packages/kai_engine) - Core AI chat engine
- [kai_engine_firebase_ai](https://pub.dev/packages/kai_engine_firebase_ai) - Firebase AI adapter
- [prompt_block](https://pub.dev/packages/prompt_block) - Structured prompt blocks

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
