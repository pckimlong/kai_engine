import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/src.dart';

void main() {
  group('ContentBuilder', () {
    test('adds a single line', () {
      final builder = ContentBuilder();
      builder.addLine('First line');
      final content = builder.build();
      expect(content, equals(['First line']));
    });

    test('adds multiple lines', () {
      final builder = ContentBuilder();
      builder.addLines(['Line 1', 'Line 2', 'Line 3']);
      final content = builder.build();
      expect(content, equals(['Line 1', 'Line 2', 'Line 3']));
    });

    test('adds a line conditionally', () {
      final builder = ContentBuilder();
      builder.addLineIf(true, 'Conditional line added');
      builder.addLineIf(false, 'Conditional line not added');
      final content = builder.build();
      expect(content, equals(['Conditional line added']));
    });

    test('builds content with multiple operations', () {
      final builder = ContentBuilder();
      builder.addLine('First line');
      builder.addLineIf(true, 'Second line');
      builder.addLines(['Third line', 'Fourth line']);
      builder.addLineIf(false, 'This line should not appear');
      final content = builder.build();
      expect(
        content,
        equals(['First line', 'Second line', 'Third line', 'Fourth line']),
      );
    });
  });

  group('PromptBlock.build', () {
    test('creates section with dynamically built content', () {
      final section = PromptBlock.build((builder) {
        builder.addLine('First line');
        builder.addLine('Second line');
      });
      final output = section.output();
      expect(output, equals('First line\nSecond line'));
    });

    test('creates section with conditional content', () {
      final section = PromptBlock.build((builder) {
        builder.addLine('Always present');
        builder.addLineIf(true, 'Conditionally present');
        builder.addLineIf(false, 'Should not be present');
      });
      final output = section.output();
      expect(output, equals('Always present\nConditionally present'));
    });

    test('creates section with mixed content operations', () {
      final section = PromptBlock.build((builder) {
        builder.addLine('First line');
        builder.addLines(['Second line', 'Third line']);
        builder.addLineIf(true, 'Fourth line');
        builder.addLineIf(false, 'Should not be present');
      });
      final output = section.output();
      expect(
        output,
        equals('First line\nSecond line\nThird line\nFourth line'),
      );
    });
  });

  group('PromptBlock.xmlFrom', () {
    test('creates XML section with content from builder', () {
      final section = PromptBlock.xmlFrom(
        'notes',
        builder: () => 'This is a note',
      );
      final output = section.output();
      expect(output, equals('<notes>\n  This is a note\n</notes>'));
    });

    test('omits section when builder returns null', () {
      final section = PromptBlock.xmlFrom('notes', builder: () => null);
      final output = section.output();
      expect(output, equals(''));
      expect(section.shouldRender, isFalse);
    });

    test('omits section when builder returns empty string', () {
      final section = PromptBlock.xmlFrom('notes', builder: () => '');
      final output = section.output();
      expect(output, equals(''));
      expect(section.shouldRender, isFalse);
    });

    test('creates XML section with attributes and content from builder', () {
      final section = PromptBlock.xmlFrom(
        'user',
        attributes: {'id': '123', 'name': 'John'},
        builder: () => 'User information',
      );
      final output = section.output();
      expect(
        output,
        equals('<user id="123" name="John">\n  User information\n</user>'),
      );
    });

    test('works with complex content from builder', () {
      final section = PromptBlock.xmlFrom(
        'data',
        builder: () => 'Line 1\nLine 2\nLine 3',
      );
      final output = section.output();
      expect(output, equals('<data>\n  Line 1\nLine 2\nLine 3\n</data>'));
    });
  });
}
