import 'dart:collection';

/// An enum to define the style of bullet points for a list.
enum BulletType { number, hyphen, none }

/// A class to build a structured section of an AI prompt.
///
/// Use the factory constructors like `Section.xml()` or `Section.bulletList()`
/// and chain methods like `.add()` and `.addAll()` to construct complex prompts.
/// /// Example usage:
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
class Section {
  final String? _title;
  final String? _xmlTag;
  final Map<String, String> _xmlAttributes;
  final List<String> _body;
  final BulletType _bodyBullet;
  final List<Section> _children;
  final bool _isCodeBlock;
  final String? _codeBlockLanguage;

  Section({
    String? title,
    List<String> body = const [],
    BulletType bodyBullet = BulletType.none,
    List<Section> children = const [],
  }) : _title = title,
       _body = body,
       _bodyBullet = bodyBullet,
       _children = UnmodifiableListView(children),
       _xmlTag = null,
       _xmlAttributes = const {},
       _isCodeBlock = false,
       _codeBlockLanguage = null;

  Section._internal({
    String? title,
    String? xmlTag,
    Map<String, String> xmlAttributes = const {},
    List<String> body = const [],
    BulletType bodyBullet = BulletType.none,
    List<Section> children = const [],
    bool isCodeBlock = false,
    String? codeBlockLanguage,
  }) : _title = title,
       _xmlTag = xmlTag,
       _xmlAttributes = xmlAttributes,
       _body = body,
       _bodyBullet = bodyBullet,
       _children = UnmodifiableListView(children),
       _isCodeBlock = isCodeBlock,
       _codeBlockLanguage = codeBlockLanguage;

  /// Creates a section wrapped in an XML-style tag.
  factory Section.xml(
    String tag, {
    Map<String, String> attributes = const {},
    List<Section> children = const [],
  }) {
    return Section._internal(xmlTag: tag, xmlAttributes: attributes, children: children);
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

  /// Adds a single child section and returns the parent.
  Section add(Section child) {
    _children.add(child);
    return this;
  }

  /// Adds multiple child sections and returns the parent.
  Section addAll(List<Section> children) {
    _children.addAll(children);
    return this;
  }

  /// Generates the final, formatted prompt string.
  String output() {
    final buffer = StringBuffer();
    _build(buffer, 0);
    return buffer.toString().trim();
  }

  /// The private, recursive method that builds the prompt string.
  void _build(StringBuffer buffer, int indentLevel) {
    final indent = '  ' * indentLevel;

    // 1. Write the opening of the section (Title or XML tag)
    if (_title != null) {
      buffer.writeln('$indent$_title');
    } else if (_xmlTag != null) {
      buffer.write('$indent<$_xmlTag');
      if (_xmlAttributes.isNotEmpty) {
        for (final attr in _xmlAttributes.entries) {
          buffer.write(' ${attr.key}="${attr.value}"');
        }
      }
      buffer.writeln('>');
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

    // 3. Recursively build all children
    if (_children.isNotEmpty) {
      // Add a newline for spacing if this section has its own content
      if (_title != null || _body.isNotEmpty) buffer.writeln();

      for (var i = 0; i < _children.length; i++) {
        final child = _children[i];
        final childIndent = _xmlTag != null ? indentLevel + 1 : indentLevel;
        child._build(buffer, childIndent);
        // Add spacing between children, but not after the last one
        if (i < _children.length - 1) {
          buffer.writeln();
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
