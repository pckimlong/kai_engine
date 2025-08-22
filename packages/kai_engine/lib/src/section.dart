import 'dart:collection';

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
/// - Use `Section.conditional()` to create sections with explicit rendering control
/// - Use `Section.xmlBuild()` which automatically disables rendering when the builder returns null or empty
/// - Use `copyWith(shouldRender: false)` to disable rendering of existing sections
/// - Check `section.shouldRender` to see if a section will be rendered
///
/// Example usage:
///
/// ```dart
/// void main() {
///   final userContext = Section.xml('user_context', att: {'name': 'Kim'})
///     .add(
///       Section(title: '## User Profile')
///         .add(
///           Section.bulletList([
///             'Currently pursuing a Master\'s degree',
///             'Expected graduation: September 2025',
///             'Interests: AI, Dart, Flutter',
///           ])
///         )
///     )
///     .add(
///       Section.xml('conversation_history', att: {'turns': '2'})
///         .addAll([
///           Section.xml('memory', att: {'author': 'assistant'})
///             ..add(Section(body: ['Hey Kim! Good morning.'])),
///           Section.xml('memory', att: {'author': 'user'})
///             ..add(Section(body: ['Good morning to you too!'])),
///         ])
///     );
///
///   final finalPrompt = Section(title: '# Final Prompt For Gemini')
///     .add(userContext) // Add the previously built section
///     .add(
///       Section(title: '## Task')
///         .add(Section(body: ['Summarize the user\'s current status based on the context provided.']))
///     )
///     .output();
///
///   print(finalPrompt);
/// }
///
/// ## Practical Usage Example
///
/// ```dart
/// void main() {
///   bool isDebugMode = false;
///   List<String> errors = [];
///
///   String buildPrompt(bool debug, List<String> errorList) {
///     final errorSection = Section.xml('errors')
///         .addAll(errorList.map((e) => Section.xmlText('error', e).compact()).toList())
///         .omitWhenEmpty();
///
///     final prompt = Section(title: '# System Prompt')
///         .add(Section.xmlText('user_id', 'user-12345').compact())
///         .add(errorSection)
///         .add(
///           Section.xml('debug_info')
///               .when(debug)
///               .add(Section.codeBlock('Session ID: abc-xyz\nTimestamp: ${DateTime.now()}'))
///         )
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
