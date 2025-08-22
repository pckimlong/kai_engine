import 'dart:collection';

import 'content_builder.dart';

/// An enum to define the style of bullet points for a list.
enum BulletType { number, hyphen, none }

/// A class to build a structured section of an AI prompt.
///
/// Use the factory constructors like `Section.xml()` or `Section.bulletList()`
/// and chain methods like `.add()` and `.addAll()` to construct complex prompts.
///
/// ## Rendering Control
///
/// Sections can be conditionally rendered by setting the `shouldRender` flag:
/// - Use [Section.xml] to create sections with explicit rendering control
/// - Use [Section.xmlFrom] which automatically disables rendering when the builder returns null or empty
/// - Use [copyWith] with `shouldRender: false` to disable rendering of existing sections
/// - Check [shouldRender] to see if a section will be rendered
///
/// ## Fluent API Features
///
/// The Section class provides a powerful fluent API for building structured prompts:
///
/// - **Factory Constructors**: Create sections with different formats like XML tags, bullet lists, and code blocks
/// - **Dynamic Content Building**: Use `Section.build()` with a `ContentBuilder` for complex dynamic content
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
///   final userProfile = Section(title: '## User Profile')
///     .add(
///       Section.bulletList([
///         'Currently pursuing a Master\'s degree',
///         'Expected graduation: September 2025',
///         'Interests: AI, Dart, Flutter',
///       ])
///     );
///
///   // XML section with attributes and nested content
///   final conversationHistory = Section.xml('conversation_history', attributes: {'turns': '2'})
///     .addAll([
///       Section.xml('memory', attributes: {'author': 'assistant'})
///         ..add(Section(body: ['Hey Kim! Good morning.'])),
///       Section.xml('memory', attributes: {'author': 'user'})
///         ..add(Section(body: ['Good morning to you too!'])),
///     ]);
///
///   // Dynamic content building
///   final dynamicSection = Section.build((builder) {
///     builder.addLine('First line');
///     builder.addLineIf(someCondition, 'Conditional line');
///     builder.addLines(['Line 2', 'Line 3']);
///   });
///
///   // Conditional section with collection processing
///   final errors = ['Connection timed out', 'Authentication failed'];
///   final errorSection = Section.xml('errors')
///     .addEach(errors, (error) => Section.xmlText('error', error))
///     .omitWhenEmpty();
///
///   // XML section with dynamic content from a builder
///   final notesSection = Section.xmlFrom('notes', builder: () => getNotes());
///
///   // Conditional rendering
///   final debugSection = Section.xml('debug_info')
///     .includeIf(isDebugMode)
///     .add(Section.codeBlock('Session ID: abc-xyz\nTimestamp: ${DateTime.now()}'));
///
///   // Assemble the final prompt
///   final finalPrompt = Section(title: '# Final Prompt For AI')
///     .add(userProfile)
///     .add(conversationHistory)
///     .add(dynamicSection)
///     .add(errorSection)
///     .add(notesSection)
///     .add(debugSection)
///     .add(
///       Section(title: '## Task')
///         .add(Section(body: ['Analyze the user\'s current status based on the context provided.']))
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
///     final errorSection = Section.xml('errors')
///         .addEach(errorList, (error) => Section.xmlText('error', error).compact())
///         .omitWhenEmpty();
///
///     // Using Section.build for dynamic content
///     final userInfoSection = Section.build((builder) {
///       builder.addLine('User ID: user-12345');
///       builder.addLineIf(debug, 'Debug Mode: Enabled');
///       builder.addLine('Timestamp: ${DateTime.now()}');
///     });
///
///     // Using Section.xmlFrom for single-line XML content
///     final notesSection = Section.xmlFrom('notes', builder: () => 'System notes here');
///
///     // Using includeIf for conditional rendering
///     final debugSection = Section.xml('debug_info')
///         .includeIf(debug)
///         .add(Section.codeBlock('Session ID: abc-xyz\nTimestamp: 2024-01-01 12:00:00'));
///
///     final prompt = Section(title: '# System Prompt')
///         .add(userInfoSection)
///         .add(errorSection)
///         .add(notesSection)
///         .add(debugSection)
///         .add(Section(title: '## Task', body: ['Analyze the user request.']));
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
/// `Section.xml()` and chain methods like `.add()`, `.when()`, and `.omitWhenEmpty()`
/// to construct your final prompt.
class Section {
  final String? _title;
  final String? _xmlTag;
  final Map<String, String> _xmlAttributes;
  final List<String> _body;
  final BulletType _bodyBullet;
  final List<Section> _children;
  final bool _isCodeBlock;
  final String? _codeBlockLanguage;
  bool _shouldRender;
  bool _forceCompact;

  // --- Public Getters ---

  /// An unmodifiable view of the children of this section.
  List<Section> get children => UnmodifiableListView(_children);

  /// Returns whether this section is currently configured to be rendered.
  bool get shouldRender => _shouldRender;

  // --- Constructors ---

  Section({
    String? title,
    List<String> body = const [],
    BulletType bodyBullet = BulletType.none,
    List<Section> children = const [],
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

  Section._internal({
    String? title,
    String? xmlTag,
    Map<String, String> xmlAttributes = const {},
    List<String> body = const [],
    BulletType bodyBullet = BulletType.none,
    List<Section> children = const [],
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
  factory Section.xml(
    String tag, {
    Map<String, String> attributes = const {},
    List<Section> children = const [],
  }) {
    return Section._internal(xmlTag: tag, xmlAttributes: attributes, children: children);
  }

  /// A convenience factory to create an XML tag with a single text body.
  factory Section.xmlText(String tag, String text, {Map<String, String> attributes = const {}}) {
    return Section.xml(
      tag,
      attributes: attributes,
      children: [
        Section(body: [text]),
      ],
    );
  }

  /// Creates a section formatted as a bulleted or numbered list.
  factory Section.bulletList(List<String> items, {BulletType type = BulletType.hyphen}) {
    return Section._internal(body: items, bodyBullet: type);
  }

  /// Creates a section formatted as a code block.
  factory Section.codeBlock(String code, {String? language}) {
    return Section._internal(
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
  /// final section = Section.build((builder) {
  ///   builder.addLine('First line');
  ///   builder.addLineIf(someCondition, 'Conditional line');
  ///   builder.addLines(['Line 2', 'Line 3']);
  /// });
  /// ```
  ///
  /// See also:
  /// - [ContentBuilder] for the methods available in the builder function
  /// - [Section.xmlFrom] for creating XML sections with dynamic single-line content
  factory Section.build(void Function(ContentBuilder) builder) {
    final contentBuilder = ContentBuilder();
    builder(contentBuilder);
    return Section._internal(body: contentBuilder.build());
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
  ///   Section.xmlFrom('notes', builder: () => getNotes())
  /// );
  /// ```
  ///
  /// See also:
  /// - [Section.build] for creating sections with multi-line dynamic content
  factory Section.xmlFrom(
    String tag, {
    Map<String, String> attributes = const {},
    String? Function()? builder,
  }) {
    final content = builder?.call();
    final shouldRender = content != null && content.isNotEmpty;

    return Section._internal(
      xmlTag: tag,
      xmlAttributes: attributes,
      body: shouldRender ? [content] : const [],
      shouldRender: shouldRender,
    );
  }

  // --- Chainable Methods ---

  /// Adds a single child section and returns the parent for chaining.
  Section add(Section child) {
    _children.add(child);
    return this;
  }

  /// Adds multiple child sections and returns the parent for chaining.
  Section addAll(List<Section> children) {
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
  /// Section.xml('errors')
  ///   .addEach(errors, (error) =>
  ///     Section.xmlText('error', error)
  ///   );
  /// ```
  ///
  /// See also:
  /// - [addAll] for adding multiple pre-built sections
  /// - [add] for adding a single section
  ///
  /// [items] The collection of items to iterate over.
  /// [builder] A function that takes an item and returns a Section.
  Section addEach<T>(Iterable<T> items, Section Function(T item) builder) {
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
  Section when(dynamic condition) {
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
  Section includeIf(dynamic condition) {
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
  /// Example: `Section.xml('errors').omitWhenEmpty()`
  Section omitWhenEmpty() {
    return when(_body.isNotEmpty || _children.any((child) => child.shouldRender));
  }

  /// Renders this XML section on a single compact line if it only contains a short body.
  ///
  /// This has no effect if the section contains children or is a code block.
  /// Example: `Section.xmlText('user', 'Kim').compact()` renders `<user>Kim</user>`
  Section compact() {
    _forceCompact = true;
    return this;
  }

  /// Creates a copy of this section with updated values.
  Section copyWith({
    String? title,
    String? xmlTag,
    Map<String, String>? xmlAttributes,
    List<String>? body,
    BulletType? bodyBullet,
    List<Section>? children,
    bool? isCodeBlock,
    String? codeBlockLanguage,
    bool? shouldRender,
    bool? forceCompact,
  }) {
    return Section._internal(
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
