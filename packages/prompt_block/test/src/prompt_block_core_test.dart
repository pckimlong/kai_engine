import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/src.dart';

void main() {
  group('PromptBlock', () {
    group('Hierarchical nesting', () {
      test('creates nested sections with add method', () {
        final section = PromptBlock(title: '# Root')
            .add(PromptBlock(title: '## Child 1'))
            .add(PromptBlock(title: '## Child 2'));
        expect(section, isNotNull);
      });

      test('creates nested sections with addAll method', () {
        final children = [
          PromptBlock(title: '## Child 1'),
          PromptBlock(title: '## Child 2'),
          PromptBlock(title: '## Child 3'),
        ];
        final section = PromptBlock(title: '# Root').addAll(children);
        expect(section, isNotNull);
      });

      test('creates deeply nested sections', () {
        final section = PromptBlock(title: '# Root')
            .add(
              PromptBlock(title: '## Level 1')
                  .add(
                    PromptBlock(
                      title: '### Level 2',
                    ).add(PromptBlock(title: '#### Level 3')),
                  )
                  .add(PromptBlock(title: '## Another Level 1')),
            )
            .add(PromptBlock(title: '## Another Root Child'));
        expect(section, isNotNull);
      });

      test('creates mixed nested sections with different types', () {
        final section = PromptBlock(title: '# Mixed Content')
            .add(PromptBlock.xml('user_data', attributes: {'id': '123'}))
            .add(PromptBlock.bulletList(['Item 1', 'Item 2']))
            .add(PromptBlock.codeBlock('print("Hello");', language: 'dart'));
        expect(section, isNotNull);
      });
    });

    group('addEach method', () {
      test('adds sections for each item in a list', () {
        final errors = ['Timeout', 'Auth Failed'];
        final section = PromptBlock.xml(
          'errors',
        ).addEach(errors, (error) => PromptBlock.xmlText('error', error));

        expect(section, isNotNull);
        expect(section.children, hasLength(2));
        expect(section.children[0].output(), contains('Timeout'));
        expect(section.children[1].output(), contains('Auth Failed'));
      });

      test('adds sections for each item in an iterable', () {
        final numbers = Iterable<int>.generate(3); // 0, 1, 2
        final section = PromptBlock.xml('numbers').addEach(
          numbers,
          (number) => PromptBlock.xmlText('number', number.toString()),
        );

        expect(section, isNotNull);
        expect(section.children, hasLength(3));
        expect(section.children[0].output(), contains('0'));
        expect(section.children[1].output(), contains('1'));
        expect(section.children[2].output(), contains('2'));
      });

      test('works with complex objects', () {
        final users = [
          {'name': 'Alice', 'age': '30'},
          {'name': 'Bob', 'age': '25'},
        ];

        final section = PromptBlock.xml('users').addEach(
          users,
          (user) => PromptBlock.xml(
            'user',
            attributes: {'name': user['name']!},
          ).add(PromptBlock.xmlText('age', user['age']!)),
        );

        expect(section, isNotNull);
        expect(section.children, hasLength(2));
        final output = section.output();
        expect(output, contains('name="Alice"'));
        expect(output, contains('name="Bob"'));
        expect(output, contains('30'));
        expect(output, contains('25'));
      });

      test('returns parent section for chaining', () {
        final items = ['item1', 'item2'];
        final parent = PromptBlock.xml('parent');
        final result = parent.addEach(
          items,
          (item) => PromptBlock.xmlText('child', item),
        );

        expect(
          result,
          same(parent),
        ); // Should return the same instance for chaining
      });

      test('works with empty iterable', () {
        final emptyList = <String>[];
        final section = PromptBlock.xml(
          'container',
        ).addEach(emptyList, (item) => PromptBlock.xmlText('item', item));

        expect(section, isNotNull);
        expect(section.children, isEmpty);
      });
    });

    group('output method', () {
      test('outputs basic section with title', () {
        final section = PromptBlock(title: '# Introduction');
        final output = section.output();
        expect(output, equals('# Introduction'));
      });

      test('outputs basic section with body', () {
        final section = PromptBlock(
          body: ['This is a body line', 'This is another line'],
        );
        final output = section.output();
        expect(output, equals('This is a body line\nThis is another line'));
      });

      test('outputs section with title and body', () {
        final section = PromptBlock(
          title: '## User Profile',
          body: ['Name: John Doe', 'Age: 30'],
        );
        final output = section.output();
        expect(output, equals('## User Profile\nName: John Doe\nAge: 30'));
      });

      test('outputs XML section with tag', () {
        final section = PromptBlock.xml('user_context');
        final output = section.output();
        expect(output, equals('<user_context>\n</user_context>'));
      });

      test('outputs XML section with tag and attributes', () {
        final section = PromptBlock.xml(
          'user_context',
          attributes: {'name': 'Kim', 'role': 'developer'},
        );
        final output = section.output();
        expect(
          output,
          equals('<user_context name="Kim" role="developer">\n</user_context>'),
        );
      });

      test('outputs XML section with body content', () {
        final section = PromptBlock.xml(
          'user_context',
        ).add(PromptBlock(body: ['User ID: 123', 'Status: Active']));
        final output = section.output();
        expect(
          output,
          equals(
            '<user_context>\n  User ID: 123\n  Status: Active\n</user_context>',
          ),
        );
      });

      test('outputs bullet list with number type', () {
        final section = PromptBlock.bulletList([
          'First item',
          'Second item',
          'Third item',
        ], type: BulletType.number);
        final output = section.output();
        expect(output, equals('1. First item\n2. Second item\n3. Third item'));
      });

      test('outputs bullet list with hyphen type', () {
        final section = PromptBlock.bulletList([
          'Point A',
          'Point B',
          'Point C',
        ], type: BulletType.hyphen);
        final output = section.output();
        expect(output, equals('- Point A\n- Point B\n- Point C'));
      });

      test('outputs bullet list with none type', () {
        final section = PromptBlock.bulletList([
          'Note 1',
          'Note 2',
          'Note 3',
        ], type: BulletType.none);
        final output = section.output();
        expect(output, equals('Note 1\nNote 2\nNote 3'));
      });

      test('outputs code block without language', () {
        final section = PromptBlock.codeBlock('print("Hello");\nint x = 5;');
        final output = section.output();
        expect(output, equals('```\nprint("Hello");\nint x = 5;\n```'));
      });

      test('outputs code block with language', () {
        final section = PromptBlock.codeBlock(
          'print("Hello");\nint x = 5;',
          language: 'dart',
        );
        final output = section.output();
        expect(output, equals('```dart\nprint("Hello");\nint x = 5;\n```'));
      });

      test('outputs nested sections correctly', () {
        final section = PromptBlock(title: '# Root')
            .add(PromptBlock(title: '## Child 1'))
            .add(PromptBlock(title: '## Child 2'));
        final output = section.output();
        expect(output, equals('# Root\n## Child 1\n\n## Child 2'));
      });

      test('outputs deeply nested sections correctly', () {
        final section = PromptBlock(title: '# Root')
            .add(
              PromptBlock(title: '## Level 1')
                  .add(PromptBlock(title: '### Level 2'))
                  .add(PromptBlock(title: '## Another Level 1')),
            )
            .add(PromptBlock(title: '## Another Root Child'));
        final output = section.output();
        expect(
          output,
          equals(
            '# Root\n## Level 1\n### Level 2\n\n## Another Level 1\n\n## Another Root Child',
          ),
        );
      });

      test('outputs complex nested structure with different section types', () {
        final section = PromptBlock(title: '# Final Prompt For Gemini')
            .add(
              PromptBlock.xml('user_context', attributes: {'name': 'Kim'})
                  .add(
                    PromptBlock(title: '## User Profile').add(
                      PromptBlock.bulletList([
                        'Currently pursuing a Master\'s degree',
                        'Expected graduation: September 2025',
                        'Interests: AI, Dart, Flutter',
                      ]),
                    ),
                  )
                  .add(
                    PromptBlock.xml(
                      'conversation_history',
                      attributes: {'turns': '2'},
                    ).addAll([
                      PromptBlock.xml(
                        'memory',
                        attributes: {'author': 'assistant'},
                      ).add(PromptBlock(body: ['Hey Kim! Good morning.'])),
                      PromptBlock.xml(
                        'memory',
                        attributes: {'author': 'user'},
                      ).add(PromptBlock(body: ['Good morning to you too!'])),
                    ]),
                  ),
            )
            .add(
              PromptBlock(title: '## Task').add(
                PromptBlock(
                  body: [
                    'Summarize the user\'s current status based on the context provided.',
                  ],
                ),
              ),
            );
        final output = section.output();
        expect(
          output,
          equals(
            '# Final Prompt For Gemini\n<user_context name="Kim">\n  ## User Profile\n  - Currently pursuing a Master\'s degree\n  - Expected graduation: September 2025\n  - Interests: AI, Dart, Flutter\n\n  <conversation_history turns="2">\n    <memory author="assistant">\n      Hey Kim! Good morning.\n    </memory>\n    <memory author="user">\n      Good morning to you too!\n    </memory>\n  </conversation_history>\n</user_context>\n\n## Task\nSummarize the user\'s current status based on the context provided.',
          ),
        );
      });
    });

    group('includeIf method', () {
      test('includes section when condition is true', () {
        final section = PromptBlock.xml(
          'debug',
        ).includeIf(true).add(PromptBlock(body: ['Debug information']));

        final output = section.output();
        expect(output, contains('<debug>'));
        expect(output, contains('Debug information'));
      });

      test('omits section when condition is false', () {
        final section = PromptBlock.xml(
          'debug',
        ).includeIf(false).add(PromptBlock(body: ['Debug information']));

        final output = section.output();
        expect(output, equals(''));
      });

      test('includes section when condition function returns true', () {
        bool isDebugMode = true;
        final section = PromptBlock.xml('debug')
            .includeIf(() => isDebugMode)
            .add(PromptBlock(body: ['Debug information']));

        final output = section.output();
        expect(output, contains('<debug>'));
        expect(output, contains('Debug information'));
      });

      test('omits section when condition function returns false', () {
        bool isDebugMode = false;
        final section = PromptBlock.xml('debug')
            .includeIf(() => isDebugMode)
            .add(PromptBlock(body: ['Debug information']));

        final output = section.output();
        expect(output, equals(''));
      });

      test('works with omitWhenEmpty() in combination', () {
        final section = PromptBlock.xml(
          'errors',
        ).includeIf(true).omitWhenEmpty();

        final output = section.output();
        expect(output, equals('')); // Should be omitted because it's empty
      });

      test('returns PromptBlock for chaining', () {
        final section = PromptBlock.xml('test');
        final result = section.includeIf(true);
        expect(result, same(section));
      });
    });
  });
}
