import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_inspector/src/ui/playground/prompts.dart';

/// A wrapper for a CoreMessage that makes it editable.
class _EditableMessage {
  _EditableMessage(this.originalMessage)
      : controller = TextEditingController(text: originalMessage.content);

  final CoreMessage originalMessage;
  final TextEditingController controller;

  CoreMessage get currentMessage {
    final content = controller.text;
    switch (originalMessage.type) {
      case CoreMessageType.system:
        return CoreMessage.system(content);
      case CoreMessageType.user:
        return CoreMessage.user(content: content);
      case CoreMessageType.ai:
        return CoreMessage.ai(content: content);
      case CoreMessageType.function:
      case CoreMessageType.unknown:
        return originalMessage.copyWith(content: content);
    }
  }

  void dispose() {
    controller.dispose();
  }
}

/// Standalone screen for editing messages and generating responses
class EditGenerateScreen extends StatefulWidget {
  const EditGenerateScreen({
    super.key,
    required this.originalMessages,
    this.generatedMessages = const [],
    required this.generationService,
    this.appContext,
  });

  final List<CoreMessage> originalMessages;
  final List<CoreMessage> generatedMessages;
  final GenerationServiceBase generationService;
  final String? appContext;

  @override
  State<EditGenerateScreen> createState() => _EditGenerateScreenState();
}

class _EditGenerateScreenState extends State<EditGenerateScreen> {
  late final ScrollController _scrollController;
  final List<Object> _items = [];
  bool _isGenerating = false;
  bool _showScrollToBottomButton = false;

  // To keep track of the last generated items on this screen
  CoreMessage? _lastGeneratedResponse;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    // Populate the list with editable messages
    _items.addAll(widget.originalMessages.map((m) => _EditableMessage(m)));

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    for (final item in _items) {
      if (item is _EditableMessage) {
        item.dispose();
      }
    }
    super.dispose();
  }

  void _onScroll() {
    const threshold = 100.0;
    if (!_scrollController.hasClients) return;

    final atBottom =
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - threshold;

    if (atBottom && _showScrollToBottomButton) {
      setState(() => _showScrollToBottomButton = false);
    } else if (!atBottom && !_showScrollToBottomButton) {
      setState(() => _showScrollToBottomButton = true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Generate response using current message content
  Future<void> _generateResponse() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      // Clear previous generated response and error from the list
      if (_lastGeneratedResponse != null) {
        _items.remove(_lastGeneratedResponse);
        _lastGeneratedResponse = null;
      }
      if (_lastErrorMessage != null) {
        _items.remove(_lastErrorMessage);
        _lastErrorMessage = null;
      }
    });

    // Build messages from current state
    final messages = _items
        .map((item) {
          if (item is _EditableMessage) return item.currentMessage;
          if (item is CoreMessage) return item;
          return null;
        })
        .whereType<CoreMessage>()
        .toList();

    try {
      final response = await widget.generationService.invoke(IList(messages));

      if (mounted) {
        final newResponse = CoreMessage.ai(content: response);
        _lastGeneratedResponse = newResponse;
        setState(() {
          _items.add(newResponse);
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    } catch (e, stackTrace) {
      debugPrint('Generation error: $e\n$stackTrace');
      if (mounted) {
        final newError = e.toString();
        _lastErrorMessage = newError;
        setState(() {
          _items.add(newError);
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  List<CoreMessage> _getCurrentMessages() {
    return _items
        .map((item) {
          if (item is _EditableMessage) return item.currentMessage;
          if (item is CoreMessage) return item;
          return null;
        })
        .whereType<CoreMessage>()
        .toList();
  }

  /// Convert messages to XML format
  String _messagesToXml(List<CoreMessage> messages) {
    final result = StringBuffer();
    for (final msg in messages) {
      final tagName = msg.type.name;
      result.writeln('<${tagName}_message timestamp="${msg.timestamp.toIso8601String()}">');
      result.writeln(msg.content);
      result.writeln('</${tagName}_message>');
    }
    return result.toString();
  }

  void _copyConversation() {
    final conversationMessages = _getCurrentMessages();
    final xml = _messagesToXml(conversationMessages);
    Clipboard.setData(ClipboardData(text: xml));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyAnalysis() async {
    final instruction = await _showInstructionDialog(
      title: 'Analysis Instruction',
      initialValue: 'Analyze this conversation and response',
    );

    if (instruction == null || instruction.isEmpty || !mounted) return;

    final currentMessages = _getCurrentMessages();
    final generatedResponse =
        _lastGeneratedResponse != null ? [_lastGeneratedResponse!] : <CoreMessage>[];
    final conversationForAnalysis =
        currentMessages.where((m) => m != _lastGeneratedResponse).toList();

    final prompt = PlaygroundPrompts.analyzeConversation(
      conversationForAnalysis,
      generatedResponse,
      instruction,
      widget.appContext,
    );
    Clipboard.setData(ClipboardData(text: prompt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analysis prompt copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyCompare() async {
    final instruction = await _showInstructionDialog(
      title: 'Compare Instruction',
      initialValue: 'Compare these two conversation versions',
    );

    if (instruction == null || instruction.isEmpty || !mounted) return;

    final originalConversation = [...widget.originalMessages, ...widget.generatedMessages];
    final editedConversation = _getCurrentMessages();

    final prompt = PlaygroundPrompts.comparePrompt(
      originalConversation,
      [editedConversation],
      instruction,
      widget.appContext,
    );
    Clipboard.setData(ClipboardData(text: prompt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compare prompt copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<String?> _showInstructionDialog({
    required String title,
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter your instruction',
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _showScrollToBottomButton
          ? FloatingActionButton(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward),
            )
          : null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit & Generate', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          FilledButton.icon(
            onPressed: _isGenerating ? null : _generateResponse,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_isGenerating ? 'Generating...' : 'Generate'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 50),
                itemCount: _items.length + (_isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _items.length) {
                    return _buildLoader();
                  }

                  final item = _items[index];
                  if (item is _EditableMessage) {
                    return _buildEditableMessageCard(item);
                  }
                  if (item is CoreMessage) {
                    return _buildReadOnlyMessageCard(item);
                  }
                  if (item is String) {
                    return _buildErrorCard(item);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (_lastGeneratedResponse != null) _buildCopyButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableMessageCard(_EditableMessage editableMessage) {
    final message = editableMessage.originalMessage;
    final typeColor = _getMessageTypeColor(context, message.type);

    return _MessageCard(
      typeColor: typeColor,
      icon: _getMessageTypeIcon(message.type),
      title: _getMessageTypeName(message.type),
      child: TextField(
        controller: editableMessage.controller,
        maxLines: null,
        minLines: 3,
        style:
            Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, fontFamily: 'monospace'),
        decoration: InputDecoration(
          hintText: 'Enter message content...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildReadOnlyMessageCard(CoreMessage message) {
    final typeColor = _getMessageTypeColor(context, message.type);
    final isGenerated = message == _lastGeneratedResponse;

    return _MessageCard(
      typeColor: typeColor,
      icon: isGenerated ? Icons.auto_awesome : _getMessageTypeIcon(message.type),
      title: isGenerated ? 'Generated Response' : _getMessageTypeName(message.type),
      child: SelectableText(
        message.content,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generation Failed',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.red[800], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Generating response...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _copyConversation,
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              label: const Text('Copy Full Conversation'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyAnalysis,
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Copy Analysis'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyCompare,
                  icon: const Icon(Icons.compare_arrows_outlined, size: 18),
                  label: const Text('Copy Compare'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMessageTypeName(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.system:
        return 'System Prompt';
      case CoreMessageType.user:
        return 'User Message';
      case CoreMessageType.ai:
        return 'AI Message';
      case CoreMessageType.function:
        return 'Function Call';
      case CoreMessageType.unknown:
        return 'Unknown Message';
    }
  }

  IconData _getMessageTypeIcon(CoreMessageType type) {
    switch (type) {
      case CoreMessageType.system:
        return Icons.settings_system_daydream;
      case CoreMessageType.user:
        return Icons.person_outline;
      case CoreMessageType.ai:
        return Icons.smart_toy_outlined;
      case CoreMessageType.function:
        return Icons.functions;
      case CoreMessageType.unknown:
        return Icons.help_outline;
    }
  }

  Color _getMessageTypeColor(BuildContext context, CoreMessageType type) {
    final colors = Theme.of(context).colorScheme;
    switch (type) {
      case CoreMessageType.system:
        return colors.tertiary;
      case CoreMessageType.user:
        return colors.primary;
      case CoreMessageType.ai:
        return colors.secondary;
      case CoreMessageType.function:
        return colors.error;
      case CoreMessageType.unknown:
        return Colors.grey;
    }
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.typeColor,
    required this.icon,
    required this.title,
    required this.child,
  });

  final Color typeColor;
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: typeColor.withOpacity(0.2), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: typeColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: typeColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
