import 'dart:collection';
import 'dart:convert';

import 'content_builder.dart';

/// An enum to define the style of bullet points for a list.
enum BulletType { number, hyphen, none }

/// A class to build a structured section of an AI prompt.
///
/// Use the factory constructors like `PromptBlock.xml()` or `PromptBlock.bulletList()`
/// and chain methods like `.add()` and `.addAll()` to construct complex prompts.
///
/// ## Rendering Control
///
/// Sections can be conditionally rendered by setting the `shouldRender` flag:
/// - Use [PromptBlock.xml] to create sections with explicit rendering control
/// - Use [PromptBlock.xmlFrom] which automatically disables rendering when the builder returns null or empty
/// - Use [copyWith] with `shouldRender: false` to disable rendering of existing sections
/// - Check [shouldRender] to see if a section will be rendered
///
/// ## Fluent API Features
///
/// The PromptBlock class provides a powerful fluent API for building structured prompts:
///
/// - **Factory Constructors**: Create sections with different formats like XML tags, bullet lists, and code blocks
/// - **Dynamic Content Building**: Use `PromptBlock.build()` with a `ContentBuilder` for complex dynamic content
/// - **Conditional Rendering**: Control when sections are included with `when()` and `includeIf()`
/// - **Collection Processing**: Add multiple sections at once with `addEach()`
/// - **Automatic Empty Handling**: Use `omitWhenEmpty()` to automatically hide sections with no content
/// - **Compact Formatting**: Use `compact()` for single-line XML formatting
///
/// ## Example Usage
///
/// ```dart
/// void main() {
///   // Basic section with title and content
///   final userProfile = PromptBlock(title: '## User Profile')
///     .add(
///       PromptBlock.bulletList([
///         'Currently pursuing a Master\'s degree',
///         'Expected graduation: September 2025',
///         'Interests: AI, Dart, Flutter',
///       ])
///     );
///
///   // XML section with attributes and nested content
///   final conversationHistory = PromptBlock.xml('conversation_history', attributes: {'turns': '2'})
///     .addAll([
///       PromptBlock.xml('memory', attributes: {'author': 'assistant'})
///         ..add(PromptBlock(body: ['Hey Kim! Good morning.'])),
///       PromptBlock.xml('memory', attributes: {'author': 'user'})
///         ..add(PromptBlock(body: ['Good morning to you too!'])),
///     ]);
///
///   // Dynamic content building
///   final dynamicSection = PromptBlock.build((builder) {
///     builder.addLine('First line');
///     builder.addLineIf(someCondition, 'Conditional line');
///     builder.addLines(['Line 2', 'Line 3']);
///   });
///
///   // Conditional section with collection processing
///   final errors = ['Connection timed out', 'Authentication failed'];
///   final errorSection = PromptBlock.xml('errors')
///     .addEach(errors, (error) => PromptBlock.xmlText('error', error))
///     .omitWhenEmpty();
///
///   // XML section with dynamic content from a builder
///   final notesSection = PromptBlock.xmlFrom('notes', builder: () => getNotes());
///
///   // Conditional rendering
///   final debugSection = PromptBlock.xml('debug_info')
///     .includeIf(isDebugMode)
///     .add(PromptBlock.codeBlock('Session ID: abc-xyz\nTimestamp: ${DateTime.now()}'));
///
///   // Assemble the final prompt
///   final finalPrompt = PromptBlock(title: '# Final Prompt For AI')
///     .add(userProfile)
///     .add(conversationHistory)
///     .add(dynamicSection)
///     .add(errorSection)
///     .add(notesSection)
///     .add(debugSection)
///     .add(
///       PromptBlock(title: '## Task')
///         .add(PromptBlock(body: ['Analyze the user\'s current status based on the context provided.']))
///     )
///     .output();
///
///   print(finalPrompt);
/// }
/// ```
///
/// ## Practical Usage Example with New Features
///
/// ```dart
/// void main() {
///   bool isDebugMode = false;
///   List<String> errors = [];
///
///   String buildPrompt(bool debug, List<String> errorList) {
///     // Using addEach to process collections
///     final errorSection = PromptBlock.xml('errors')
///         .addEach(errorList, (error) => PromptBlock.xmlText('error', error).compact())
///         .omitWhenEmpty();
///
///     // Using PromptBlock.build for dynamic content
///     final userInfoSection = PromptBlock.build((builder) {
///       builder.addLine('User ID: user-12345');
///       builder.addLineIf(debug, 'Debug Mode: Enabled');
///       builder.addLine('Timestamp: ${DateTime.now()}');
///     });
///
///     // Using PromptBlock.xmlFrom for single-line XML content
///     final notesSection = PromptBlock.xmlFrom('notes', builder: () => 'System notes here');
///
///     // Using includeIf for conditional rendering
///     final debugSection = PromptBlock.xml('debug_info')
///         .includeIf(debug)
///         .add(PromptBlock.codeBlock('Session ID: abc-xyz\nTimestamp: 2024-01-01 12:00:00'));
///
///     final prompt = PromptBlock(title: '# System Prompt')
///         .add(userInfoSection)
///         .add(errorSection)
///         .add(notesSection)
///         .add(debugSection)
///         .add(PromptBlock(title: '## Task', body: ['Analyze the user request.']));
///
///     return prompt.output();
///   }
///
///   // --- First Run: Normal Mode ---
///   print('--- Prompt in Normal Mode ---');
///   final normalPrompt = buildPrompt(isDebugMode, errors);
///   print(normalPrompt);
///
///   // --- Second Run: Debug Mode with Errors ---
///   isDebugMode = true;
///   errors = ['Connection timed out', 'Authentication failed'];
///
///   print('\n\n--- Prompt in Debug Mode with Errors ---');
///   final debugPrompt = buildPrompt(isDebugMode, errors);
///   print(debugPrompt);
/// }
/// ```
///
/// A fluent builder for creating structured, hierarchical prompts for an AI.
///
/// This class allows you to declaratively build complex prompts using titles,
/// XML-style tags, lists, and code blocks. Use the factory constructors like
/// `PromptBlock.xml()` and chain methods like `.add()`, `.when()`, and `.omitWhenEmpty()`
/// to construct your final prompt.
class PromptBlock {
  final String? _title;
  final String? _xmlTag;
  final Map<String, String> _xmlAttributes;
  final List<String> _body;
  final BulletType _bodyBullet;
  final List<PromptBlock> _children;
  final bool _isCodeBlock;
  final String? _codeBlockLanguage;
  bool _shouldRender;
  bool _forceCompact;

  // --- Public Getters ---

  /// An unmodifiable view of the children of this section.
  List<PromptBlock> get children => UnmodifiableListView(_children);

  /// Returns whether this section is currently configured to be rendered.
  bool get shouldRender => _shouldRender;

  // --- Constructors ---

  PromptBlock({
    String? title,
    List<String> body = const [],
    BulletType bodyBullet = BulletType.none,
    List<PromptBlock> children = const [],
  }) : _title = title,
       _body = body,
       _bodyBullet = bodyBullet,
       _children = [...children],
       _xmlTag = null,
       _xmlAttributes = const {},
       _isCodeBlock = false,
       _codeBlockLanguage = null,
       _shouldRender = true, // Sections render by default
       _forceCompact = false;

  PromptBlock._internal({
    String? title,
    String? xmlTag,
    Map<String, String> xmlAttributes = const {},
    List<String> body = const [],
    BulletType bodyBullet = BulletType.none,
    List<PromptBlock> children = const [],
    bool isCodeBlock = false,
    String? codeBlockLanguage,
    bool shouldRender = true,
    bool forceCompact = false,
  }) : _title = title,
       _xmlTag = xmlTag,
       _xmlAttributes = xmlAttributes,
       _body = body,
       _bodyBullet = bodyBullet,
       _children = [...children],
       _isCodeBlock = isCodeBlock,
       _codeBlockLanguage = codeBlockLanguage,
       _shouldRender = shouldRender,
       _forceCompact = forceCompact;

  // --- Factory Constructors ---

  /// Creates a section wrapped in an XML-style tag.
  factory PromptBlock.xml(
    String tag, {
    Map<String, String> attributes = const {},
    List<PromptBlock> children = const [],
  }) {
    return PromptBlock._internal(xmlTag: tag, xmlAttributes: attributes, children: children);
  }

  /// A convenience factory to create an XML tag with a single text body.
  factory PromptBlock.xmlText(
    String tag,
    String text, {
    Map<String, String> attributes = const {},
  }) {
    return PromptBlock.xml(
      tag,
      attributes: attributes,
      children: [
        PromptBlock(body: [text]),
      ],
    );
  }

  /// Creates a section formatted as a bulleted or numbered list.
  factory PromptBlock.bulletList(List<String> items, {BulletType type = BulletType.hyphen}) {
    return PromptBlock._internal(body: items, bodyBullet: type);
  }

  /// Creates a section formatted as a code block.
  factory PromptBlock.codeBlock(String code, {String? language}) {
    return PromptBlock._internal(
      body: code.split('\n'),
      isCodeBlock: true,
      codeBlockLanguage: language,
    );
  }

  /// Creates a section whose multi-line body is generated dynamically using a ContentBuilder.
  ///
  /// The [builder] function receives a [ContentBuilder] instance that can be used to
  /// dynamically add lines to the section's body. This is particularly useful for complex
  /// content that requires conditional logic or iteration.
  ///
  /// Example:
  /// ```dart
  /// final section = PromptBlock.build((builder) {
  ///   builder.addLine('First line');
  ///   builder.addLineIf(someCondition, 'Conditional line');
  ///   builder.addLines(['Line 2', 'Line 3']);
  /// });
  /// ```
  ///
  /// See also:
  /// - [ContentBuilder] for the methods available in the builder function
  /// - [PromptBlock.xmlFrom] for creating XML sections with dynamic single-line content
  factory PromptBlock.build(void Function(ContentBuilder) builder) {
    final contentBuilder = ContentBuilder();
    builder(contentBuilder);
    return PromptBlock._internal(body: contentBuilder.build());
  }

  /// Creates an XML section where the single-line text body comes from a builder function.
  ///
  /// The section will be automatically omitted if the builder returns null or an empty string.
  /// This is particularly useful for XML sections that should only be included when they have
  /// meaningful content.
  ///
  /// Example:
  /// ```dart
  /// prompt.add(
  ///   PromptBlock.xmlFrom('notes', builder: () => getNotes())
  /// );
  /// ```
  ///
  /// See also:
  /// - [PromptBlock.build] for creating sections with multi-line dynamic content
  factory PromptBlock.xmlFrom(
    String tag, {
    Map<String, String> attributes = const {},
    String? Function()? builder,
  }) {
    final content = builder?.call();
    final shouldRender = content != null && content.isNotEmpty;

    return PromptBlock._internal(
      xmlTag: tag,
      xmlAttributes: attributes,
      body: shouldRender ? [content] : const [],
      shouldRender: shouldRender,
    );
  }

  // --- Chainable Methods ---

  /// Adds a single child section and returns the parent for chaining.
  PromptBlock add(PromptBlock child) {
    _children.add(child);
    return this;
  }

  /// Adds multiple child sections and returns the parent for chaining.
  PromptBlock addAll(List<PromptBlock> children) {
    _children.addAll(children);
    return this;
  }

  /// Iterates over a collection and adds a new Section for each item.
  ///
  /// This method allows for declarative creation of multiple child sections
  /// based on a collection of items. For each item in the [items] collection,
  /// the [builder] function is called to create a Section, which is then added
  /// as a child to this section.
  ///
  /// This is particularly useful for processing lists of data where each item
  /// should be represented as a separate section in the output.
  ///
  /// Example usage:
  /// ```dart
  /// List<String> errors = ['Timeout', 'Auth Failed'];
  ///
  /// PromptBlock.xml('errors')
  ///   .addEach(errors, (error) =>
  ///     PromptBlock.xmlText('error', error)
  ///   );
  /// ```
  ///
  /// See also:
  /// - [addAll] for adding multiple pre-built sections
  /// - [add] for adding a single section
  ///
  /// [items] The collection of items to iterate over.
  /// [builder] A function that takes an item and returns a Section.
  PromptBlock addEach<T>(Iterable<T> items, PromptBlock Function(T item) builder) {
    for (final item in items) {
      add(builder(item));
    }
    return this;
  }

  /// Conditionally renders the section based on a boolean or a function.
  ///
  /// The [condition] can be a `bool` or a `bool Function()`.
  /// All `when()` conditions on a section must be true for it to render.
  /// Example: `.when(isDebugMode)` or `.when(() => user.isAdmin)`
  PromptBlock when(dynamic condition) {
    if (!_shouldRender) return this; // Already disabled, do nothing

    bool conditionResult;
    if (condition is bool Function()) {
      conditionResult = condition();
    } else if (condition is bool) {
      conditionResult = condition;
    } else {
      throw ArgumentError('Condition must be a bool or a bool Function().');
    }

    _shouldRender = conditionResult;
    return this;
  }

  /// Conditionally includes the section in output based on a boolean or function.
  ///
  /// The [condition] can be a `bool` or a `bool Function()`.
  /// Only includes the section in output if the condition evaluates to true.
  /// This is an alternative to [when] with the same functionality but different semantics.
  ///
  /// Example: `.includeIf(isDebugMode)` or `.includeIf(() => user.isAdmin)`
  ///
  /// See also:
  /// - [when] for another way to conditionally render sections
  /// - [omitWhenEmpty] for automatically omitting empty sections
  PromptBlock includeIf(dynamic condition) {
    if (!_shouldRender) return this; // Already disabled, do nothing

    bool conditionResult;
    if (condition is bool Function()) {
      conditionResult = condition();
    } else if (condition is bool) {
      conditionResult = condition;
    } else {
      throw ArgumentError('Condition must be a bool or a bool Function().');
    }

    _shouldRender = conditionResult;
    return this;
  }

  /// A shortcut to automatically omit the section if it has no body and no visible children.
  ///
  /// This is perfect for container tags that should disappear when empty.
  /// Example: `PromptBlock.xml('errors').omitWhenEmpty()`
  PromptBlock omitWhenEmpty() {
    return when(_body.isNotEmpty || _children.any((child) => child.shouldRender));
  }

  /// Renders this XML section on a single compact line if it only contains a short body.
  ///
  /// This has no effect if the section contains children or is a code block.
  /// Example: `PromptBlock.xmlText('user', 'Kim').compact()` renders `<user>Kim</user>`
  PromptBlock compact() {
    _forceCompact = true;
    return this;
  }

  /// Recursively converts a map into a nested XML structure by adding child PromptBlock objects.
  ///
  /// This method takes a [Map<String, dynamic>] and creates XML elements for each key-value pair.
  /// For nested maps, it creates nested XML structures. For other values, it converts them to strings.
  ///
  /// Example:
  /// ```dart
  /// final userData = {'name': 'Kim', 'isPremium': true};
  /// final prompt = PromptBlock.xml('user_data').addMapAsXml(userData);
  /// /* Output:
  /// <user_data>
  ///   <name>Kim</name>
  ///   <isPremium>true</isPremium>
  /// </user_data>
  /// */
  /// ```
  PromptBlock addMapAsXml(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      if (entry.value is Map<String, dynamic>) {
        // For nested maps, recursively create XML structure
        final nestedBlock = PromptBlock.xml(entry.key)
          ..addMapAsXml(entry.value as Map<String, dynamic>);
        add(nestedBlock);
      } else {
        // For other values, create simple XML text elements
        add(PromptBlock.xmlText(entry.key, entry.value.toString()));
      }
    }
    return this;
  }

  /// Converts a map to a nicely formatted JSON string and adds it as a code block child.
  ///
  /// This method takes a [Map<String, dynamic>], converts it to a formatted JSON string,
  /// and adds it as a code block with "json" as the language.
  ///
  /// Example:
  /// ```dart
  /// final userData = {'name': 'Kim', 'isPremium': true};
  /// final prompt = PromptBlock(title: '## Raw User Data').addMapAsCodeBlock(userData);
  /// /* Output:
  /// ## Raw User Data
  ///
  /// ```json
  /// {
  ///   "name": "Kim",
  ///   "isPremium": true
  /// }
  /// ```
  /// */
  /// ```
  PromptBlock addMapAsCodeBlock(Map<String, dynamic> data) {
    // Convert map to formatted JSON string
    final jsonString = _formatJson(data);
    add(PromptBlock.codeBlock(jsonString, language: 'json'));
    return this;
  }

  /// Helper method to convert a Map to a formatted JSON string.
  String _formatJson(Map<String, dynamic> data) {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Creates a copy of this section with updated values.
  PromptBlock copyWith({
    String? title,
    String? xmlTag,
    Map<String, String>? xmlAttributes,
    List<String>? body,
    BulletType? bodyBullet,
    List<PromptBlock>? children,
    bool? isCodeBlock,
    String? codeBlockLanguage,
    bool? shouldRender,
    bool? forceCompact,
  }) {
    return PromptBlock._internal(
      title: title ?? _title,
      xmlTag: xmlTag ?? _xmlTag,
      xmlAttributes: xmlAttributes ?? _xmlAttributes,
      body: body ?? _body,
      bodyBullet: bodyBullet ?? _bodyBullet,
      children: children ?? _children,
      isCodeBlock: isCodeBlock ?? _isCodeBlock,
      codeBlockLanguage: codeBlockLanguage ?? _codeBlockLanguage,
      shouldRender: shouldRender ?? _shouldRender,
      forceCompact: forceCompact ?? _forceCompact,
    );
  }

  // --- Output Generation ---

  /// Generates the final, formatted prompt string.
  String output() {
    final buffer = StringBuffer();
    _build(buffer, 0);
    return buffer.toString().trim();
  }

  /// The private, recursive method that builds the prompt string.
  void _build(StringBuffer buffer, int indentLevel) {
    if (!_shouldRender) return;

    final indent = '  ' * indentLevel;
    final visibleChildren = _children.where((c) => c.shouldRender).toList();
    final hasContent = _body.isNotEmpty || visibleChildren.isNotEmpty;

    // For XML sections, we should render the opening and closing tags even if empty
    // unless it's specifically configured not to render
    if (_xmlTag != null && !hasContent && !_shouldRender) return;

    final bool useCompact =
        _forceCompact && visibleChildren.isEmpty && _body.isNotEmpty && !_isCodeBlock;

    if (useCompact) {
      final attributeString = _xmlAttributes.isNotEmpty
          ? ' ${_xmlAttributes.entries.map((e) => '${e.key}="${e.value}"').join(' ')}'
          : '';
      final bodyContent = _body.join(' ').trim();
      buffer.writeln('$indent<$_xmlTag$attributeString>$bodyContent</$_xmlTag>');
      return;
    }

    // 1. Write the opening of the section (Multi-line logic)
    if (_title != null) {
      buffer.writeln('$indent$_title');
    } else if (_xmlTag != null) {
      final attributeString = _xmlAttributes.isNotEmpty
          ? ' ${_xmlAttributes.entries.map((e) => '${e.key}="${e.value}"').join(' ')}'
          : '';
      buffer.writeln('$indent<$_xmlTag$attributeString>');
    }

    // 2. Write the body content
    if (_body.isNotEmpty) {
      final bodyIndent = indent + (_xmlTag != null ? '  ' : '');
      if (_isCodeBlock) {
        buffer.writeln('$bodyIndent```${_codeBlockLanguage ?? ''}');
        for (final line in _body) {
          buffer.writeln('$bodyIndent$line');
        }
        buffer.writeln('$bodyIndent```');
      } else {
        _formatBody(buffer, bodyIndent);
      }
    }

    // 3. Recursively build all visible children
    if (visibleChildren.isNotEmpty) {
      if (_title != null || _body.isNotEmpty) buffer.writeln(); // Spacing

      for (var i = 0; i < visibleChildren.length; i++) {
        final child = visibleChildren[i];
        final childIndent = _xmlTag != null ? indentLevel + 1 : indentLevel;
        child._build(buffer, childIndent);

        if (i < visibleChildren.length - 1) {
          buffer.writeln(); // Spacing between children
        }
      }
    }

    // 4. Write the closing XML tag
    if (_xmlTag != null) {
      buffer.writeln('$indent</$_xmlTag>');
    }
  }

  void _formatBody(StringBuffer buffer, String indent) {
    for (int i = 0; i < _body.length; i++) {
      final line = _body[i].trim();
      switch (_bodyBullet) {
        case BulletType.number:
          buffer.writeln('$indent${i + 1}. $line');
          break;
        case BulletType.hyphen:
          buffer.writeln('$indent- $line');
          break;
        case BulletType.none:
          buffer.writeln('$indent$line');
          break;
      }
    }
  }
}
