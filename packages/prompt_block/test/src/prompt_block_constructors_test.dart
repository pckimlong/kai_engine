import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/src.dart';

void main() {
  group('PromptBlock', () {
    group('Basic PromptBlock creation', () {
      test('creates section with title only', () {
        final section = PromptBlock(title: '# Introduction');
        expect(section, isNotNull);
      });

      test('creates section with body only', () {
        final section = PromptBlock(body: ['This is a simple body line']);
        expect(section, isNotNull);
      });

      test('creates section with both title and body', () {
        final section = PromptBlock(
          title: '## User Profile',
          body: ['Name: John Doe', 'Age: 30'],
        );
        expect(section, isNotNull);
      });

      test('creates section with children', () {
        final childSection = PromptBlock(title: 'Child PromptBlock');
        final parentSection = PromptBlock(
          title: 'Parent PromptBlock',
          children: [childSection],
        );
        expect(parentSection, isNotNull);
      });
    });

    group('XML PromptBlock creation', () {
      test('creates XML section with tag only', () {
        final section = PromptBlock.xml('user_context');
        expect(section, isNotNull);
      });

      test('creates XML section with tag and attributes', () {
        final section = PromptBlock.xml(
          'user_context',
          attributes: {'name': 'Kim', 'role': 'developer'},
        );
        expect(section, isNotNull);
      });

      test('creates XML section with children', () {
        final child = PromptBlock.xml(
          'memory',
          attributes: {'author': 'assistant'},
        );
        final parent = PromptBlock.xml(
          'conversation_history',
          attributes: {'turns': '2'},
          children: [child],
        );
        expect(parent, isNotNull);
      });
    });

    group('Bullet List PromptBlock creation', () {
      test('creates bullet list with default hyphen type', () {
        final items = ['Item 1', 'Item 2', 'Item 3'];
        final section = PromptBlock.bulletList(items);
        expect(section, isNotNull);
      });

      test('creates bullet list with number type', () {
        final items = ['First item', 'Second item', 'Third item'];
        final section = PromptBlock.bulletList(items, type: BulletType.number);
        expect(section, isNotNull);
      });

      test('creates bullet list with hyphen type', () {
        final items = ['Point A', 'Point B', 'Point C'];
        final section = PromptBlock.bulletList(items, type: BulletType.hyphen);
        expect(section, isNotNull);
      });

      test('creates bullet list with none type', () {
        final items = ['Note 1', 'Note 2', 'Note 3'];
        final section = PromptBlock.bulletList(items, type: BulletType.none);
        expect(section, isNotNull);
      });
    });

    group('Code Block PromptBlock creation', () {
      test('creates code block without language', () {
        final code = 'print("Hello, World!");\nint x = 5;';
        final section = PromptBlock.codeBlock(code);
        expect(section, isNotNull);
      });

      test('creates code block with language', () {
        final code = 'print("Hello, World!");\nint x = 5;';
        final section = PromptBlock.codeBlock(code, language: 'dart');
        expect(section, isNotNull);
      });

      test('creates code block with multi-line content', () {
        final code = '''
void main() {
 print("Hello, World!");
  int x = 5;
 print(x);
}''';
        final section = PromptBlock.codeBlock(code, language: 'dart');
        expect(section, isNotNull);
      });
    });
  });
}
