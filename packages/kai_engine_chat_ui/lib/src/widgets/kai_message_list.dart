import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:kai_engine/kai_engine.dart';

import '../kai_chat_theme.dart';
import 'kai_message_bubble.dart';
import 'kai_streaming_text.dart';
import 'kai_typing_indicator.dart';

/// Builder that constructs a custom avatar widget.
///
/// This builder receives the [context] and [message] as parameters.
/// You can use this to create a custom avatar for messages.
///
/// Example - Create a simple avatar:
/// ```dart
/// KaiChatView(
///   avatarBuilder: (context, message) {
///     return CircleAvatar(
///       radius: 16,
///       backgroundColor: Colors.blue,
///       child: Icon(Icons.smart_toy, size: 18),
///     );
///   },
///   // ...
/// )
/// ```
typedef KaiAvatarBuilder = Widget Function(BuildContext context, CoreMessage message);

/// Builder that constructs a custom message widget.
///
/// This builder receives the [context] and [message] as parameters.
/// You can use this to create a completely custom message layout.
///
/// Example - Create a simple text message:
/// ```dart
/// KaiChatView(
///   messageBuilder: (context, message) {
///     return Text(message.content);
///   },
///   // ...
/// )
/// ```
typedef KaiMessageBuilder = Widget Function(BuildContext context, CoreMessage message);

/// Builder that provides a default child widget for customization.
///
/// This builder receives the [defaultChild] which is the pre-built [KaiMessageBubble].
/// You can wrap it with additional widgets (e.g., avatar, timestamp, status indicators)
/// or use it as a reference to build your own custom layout.
///
/// Example - Add an avatar next to messages:
/// ```dart
/// KaiChatView(
///   messageItemBuilder: (context, message, defaultChild) {
///     return Row(
///       children: [
///         CircleAvatar(
///           backgroundImage: NetworkImage(message.type == CoreMessageType.user
///               ? 'https://api.dicebear.com/7.x/avataaars/svg?seed=user'
///               : 'https://api.dicebear.com/7.x/bottts/svg?seed=ai'),
///         ),
///         SizedBox(width: 8),
///         Expanded(child: defaultChild),
///       ],
///     );
///   },
///   // ...
/// )
/// ```
///
/// Example - Add a status indicator:
/// ```dart
/// KaiChatView(
///   messageItemBuilder: (context, message, defaultChild) {
///     return Column(
///       crossAxisAlignment: CrossAxisAlignment.start,
///       children: [
///         defaultChild,
///         if (message.metadata['status'] != null)
///           Text(
///             message.metadata['status'],
///             style: TextStyle(fontSize: 12, color: Colors.grey),
///           ),
///       ],
///     );
///   },
///   // ...
/// )
/// ```
typedef KaiMessageItemBuilder =
    Widget Function(BuildContext context, CoreMessage message, Widget defaultChild);

/// Builder that constructs a custom transient state widget.
///
/// This builder receives the [context] and [state] as parameters.
/// You can use this to create a completely custom transient state layout.
///
/// Example - Create a simple loading indicator:
/// ```dart
/// KaiChatView(
///   transientBuilder: (context, state) {
///     return CircularProgressIndicator();
///   },
///   // ...
/// )
/// ```
typedef KaiTransientBuilder =
    Widget Function(BuildContext context, GenerationState<GenerationResult> state);

/// Builder that provides a default child widget for transient state customization.
///
/// Similar to [KaiMessageItemBuilder], this allows you to customize the transient
/// state (loading, streaming, function calling) while using the default bubble as a base.
///
/// Example - Add a loading animation:
/// ```dart
/// KaiChatView(
///   transientItemBuilder: (context, state, defaultChild) {
///     return Column(
///       children: [
///         defaultChild,
///         LinearProgressIndicator(),
///       ],
///     );
///   },
///   // ...
/// )
/// ```
typedef KaiTransientItemBuilder =
    Widget Function(BuildContext context, GenerationState<GenerationResult> state, Widget child);

/// Filter that determines whether a message should be displayed.
///
/// This filter receives the [message] as a parameter.
/// You can use this to filter out certain types of messages.
///
/// Example - Filter out background context messages:
/// ```dart
/// KaiChatView(
///   messageFilter: (message) => !message.isBackgroundContext,
///   // ...
/// )
/// ```
typedef KaiMessageFilter = bool Function(CoreMessage message);

/// Builder that constructs a custom function call widget.
///
/// This builder receives the [message] as a parameter.
/// If provided, function messages will be displayed in the chat.
/// If null, function messages are filtered out by default.
///
/// Example - Display function call with name and result:
/// ```dart
/// KaiChatView(
///   functionCallBuilder: (context, message) {
///     return Card(
///       child: ListTile(
///         leading: Icon(Icons.code),
///         title: Text('Function: ${message.extensions["name"]}'),
///         subtitle: Text(message.content),
///       ),
///     );
///   },
///   // ...
/// )
/// ```
typedef KaiFunctionCallBuilder = Widget Function(BuildContext context, CoreMessage message);

/// Builder that constructs a custom empty state widget.
///
/// This builder receives the [context] and [onSubmit] callback as parameters.
/// The [onSubmit] callback allows you to trigger message submission from the empty state.
/// If provided, this widget is shown when there are no messages in the chat.
/// If null, an empty list is shown.
///
/// Example - Show a welcome message with a quick action button:
/// ```dart
/// KaiChatView(
///   emptyStateBuilder: (context, onSubmit) {
///     return Center(
///       child: Column(
///         mainAxisAlignment: MainAxisAlignment.center,
///         children: [
///           Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
///           SizedBox(height: 16),
///           Text(
///             'Start a conversation!',
///             style: TextStyle(fontSize: 18, color: Colors.grey),
///           ),
///           SizedBox(height: 16),
///           ElevatedButton(
///             onPressed: () => onSubmit('Hello, I need help!'),
///             child: Text('Say Hello'),
///           ),
///         ],
///       ),
///     );
///   },
///   // ...
/// )
/// ```
typedef KaiEmptyStateBuilder =
    Widget Function(BuildContext context, void Function(String text) onSubmit);

bool defaultKaiMessageFilter(CoreMessage m) => m.isDisplayable && !m.isBackgroundContext;

class KaiMessageList extends StatelessWidget {
  const KaiMessageList({
    super.key,
    required this.messages,
    this.generationState,
    this.controller,
    this.reverse = true,
    this.messageFilter = defaultKaiMessageFilter,
    this.messageBuilder,
    this.messageItemBuilder,
    this.transientBuilder,
    this.transientItemBuilder,
    this.functionCallBuilder,
    this.emptyStateBuilder,
    this.onEmptyStateSubmit,
    this.onMessageTap,
    this.padding,
    this.physics,
    this.showTimeLabel = false,
    this.avatarBuilder,
  });

  final IList<CoreMessage> messages;
  final GenerationState<GenerationResult>? generationState;
  final ScrollController? controller;
  final bool reverse;
  final KaiMessageFilter messageFilter;
  final KaiMessageBuilder? messageBuilder;
  final KaiMessageItemBuilder? messageItemBuilder;
  final KaiTransientBuilder? transientBuilder;
  final KaiTransientItemBuilder? transientItemBuilder;
  final KaiFunctionCallBuilder? functionCallBuilder;
  final KaiEmptyStateBuilder? emptyStateBuilder;
  final void Function(String text)? onEmptyStateSubmit;
  final void Function(CoreMessage message)? onMessageTap;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool showTimeLabel;
  final KaiAvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = context.kaiChatTheme;
    final effectiveFilter = functionCallBuilder != null
        ? (CoreMessage m) =>
              (m.isDisplayable && !m.isBackgroundContext) ||
              (m.type == CoreMessageType.function && !m.isBackgroundContext)
        : messageFilter;
    final filtered = messages.where(effectiveFilter).toIList();
    final transient = generationState != null && generationState!.isGenerating;
    final totalCount = filtered.length + (transient ? 1 : 0);
    final transientIndex = reverse ? 0 : filtered.length;

    if (totalCount == 0 && emptyStateBuilder != null) {
      return emptyStateBuilder!(context, onEmptyStateSubmit ?? (_) {});
    }

    return ListView.builder(
      controller: controller,
      reverse: reverse,
      padding: padding ?? theme.listPadding,
      physics: physics ?? const BouncingScrollPhysics(),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final isTransientIndex = transient && index == transientIndex;
        if (isTransientIndex) {
          final state = generationState!;
          final defaultChild =
              transientBuilder?.call(context, state) ?? _defaultTransient(context, state);
          final built = transientItemBuilder?.call(context, state, defaultChild) ?? defaultChild;
          return Padding(
            padding: EdgeInsets.only(bottom: index == 0 ? 4 : theme.itemSpacing),
            child: built,
          );
        }

        final messageIndex = reverse
            ? (filtered.length - 1 - (index - (transient ? 1 : 0)))
            : index;
        final message = filtered[messageIndex];

        if (message.type == CoreMessageType.function && functionCallBuilder != null) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == 0 ? 4 : theme.itemSpacing),
            child: functionCallBuilder!(context, message),
          );
        }

        final defaultChild = KaiMessageBubble(
          message: message,
          isUserMessage: message.type == CoreMessageType.user,
          onTap: onMessageTap == null ? null : () => onMessageTap!(message),
          showTimeLabel: showTimeLabel,
          avatarBuilder: avatarBuilder,
        );

        final bubble =
            messageItemBuilder?.call(context, message, defaultChild) ??
            messageBuilder?.call(context, message) ??
            defaultChild;

        return Padding(
          padding: EdgeInsets.only(bottom: index == 0 ? 4 : theme.itemSpacing),
          child: bubble,
        );
      },
    );
  }

  Widget _defaultTransient(BuildContext context, GenerationState<GenerationResult> state) {
    return switch (state) {
      GenerationLoadingState() || GenerationFunctionCallingState() => KaiMessageBubble(
        message: CoreMessage.ai(content: ''),
        isUserMessage: false,
        contentBuilder: (_, __) =>
            const Padding(padding: EdgeInsets.symmetric(vertical: 2), child: KaiTypingIndicator()),
        avatarBuilder: avatarBuilder,
      ),
      GenerationStreamingTextState(text: final text) => KaiMessageBubble(
        message: CoreMessage.ai(content: text),
        isUserMessage: false,
        contentBuilder: (context, _) =>
            KaiStreamingText(text: text, style: Theme.of(context).textTheme.bodyMedium),
        avatarBuilder: avatarBuilder,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
