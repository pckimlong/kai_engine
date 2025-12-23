# kai_engine_chat_ui

Riverpod-free Flutter chat UI widgets designed for `kai_engine`.

## Usage

```dart
KaiChatView(
  messages: messages,
  generationState: generationState,
  onSend: (text) => controller.submit(text),
  onCancel: controller.cancel,
)
```

## Customization

- Filter messages via `messageFilter` (defaults to `defaultKaiMessageFilter`).
- Override message UI via `messageBuilder`.
- Override the transient “generating” row via `transientBuilder`.

## Theming

Add `KaiChatTheme` to your app theme:

```dart
ThemeData(
  extensions: const [
    KaiChatTheme(),
  ],
)
```
