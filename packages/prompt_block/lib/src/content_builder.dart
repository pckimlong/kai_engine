/// A helper class for dynamically building multi-line content for a PromptBlock.
///
/// This class provides convenient methods for adding lines of text to a prompt block's body.
class ContentBuilder {
  final List<String> _lines = [];

  /// Adds a single line to the content.
  void addLine(String line) {
    _lines.add(line);
  }

  /// Adds multiple lines to the content.
  void addLines(List<String> lines) {
    _lines.addAll(lines);
  }

  /// Adds a line to the content only if the condition is true.
  void addLineIf(bool condition, String line) {
    if (condition) {
      _lines.add(line);
    }
  }

  /// Builds and returns the content as a list of strings.
  List<String> build() {
    return List.unmodifiable(_lines);
  }
}
