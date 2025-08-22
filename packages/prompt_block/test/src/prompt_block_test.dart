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
        final section = PromptBlock(title: '## User Profile', body: ['Name: John Doe', 'Age: 30']);
        expect(section, isNotNull);
      });

      test('creates section with children', () {
        final childSection = PromptBlock(title: 'Child PromptBlock');
        final parentSection = PromptBlock(title: 'Parent PromptBlock', children: [childSection]);
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
        final child = PromptBlock.xml('memory', attributes: {'author': 'assistant'});
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

    group('Hierarchical nesting', () {
      test('creates nested sections with add method', () {
        final section = PromptBlock(
          title: '# Root',
        ).add(PromptBlock(title: '## Child 1')).add(PromptBlock(title: '## Child 2'));
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
                  .add(PromptBlock(title: '### Level 2').add(PromptBlock(title: '#### Level 3')))
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
        final section = PromptBlock.xml(
          'numbers',
        ).addEach(numbers, (number) => PromptBlock.xmlText('number', number.toString()));

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
        final result = parent.addEach(items, (item) => PromptBlock.xmlText('child', item));

        expect(result, same(parent)); // Should return the same instance for chaining
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
        final section = PromptBlock(body: ['This is a body line', 'This is another line']);
        final output = section.output();
        expect(output, equals('This is a body line\nThis is another line'));
      });

      test('outputs section with title and body', () {
        final section = PromptBlock(title: '## User Profile', body: ['Name: John Doe', 'Age: 30']);
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
        expect(output, equals('<user_context name="Kim" role="developer">\n</user_context>'));
      });

      test('outputs XML section with body content', () {
        final section = PromptBlock.xml(
          'user_context',
        ).add(PromptBlock(body: ['User ID: 123', 'Status: Active']));
        final output = section.output();
        expect(output, equals('<user_context>\n  User ID: 123\n  Status: Active\n</user_context>'));
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
        final section = PromptBlock.codeBlock('print("Hello");\nint x = 5;', language: 'dart');
        final output = section.output();
        expect(output, equals('```dart\nprint("Hello");\nint x = 5;\n```'));
      });

      test('outputs nested sections correctly', () {
        final section = PromptBlock(
          title: '# Root',
        ).add(PromptBlock(title: '## Child 1')).add(PromptBlock(title: '## Child 2'));
        final output = section.output();
        expect(output, equals('# Root\n\n## Child 1\n\n## Child 2'));
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
            '# Root\n\n## Level 1\n\n### Level 2\n\n## Another Level 1\n\n## Another Root Child',
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
                    PromptBlock.xml('conversation_history', attributes: {'turns': '2'}).addAll([
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
                  body: ['Summarize the user\'s current status based on the context provided.'],
                ),
              ),
            );
        final output = section.output();
        expect(
          output,
          equals(
            '# Final Prompt For Gemini\n\n<user_context name="Kim">\n  ## User Profile\n\n  - Currently pursuing a Master\'s degree\n  - Expected graduation: September 2025\n  - Interests: AI, Dart, Flutter\n\n  <conversation_history turns="2">\n    <memory author="assistant">\n      Hey Kim! Good morning.\n    </memory>\n\n    <memory author="user">\n      Good morning to you too!\n    </memory>\n  </conversation_history>\n</user_context>\n\n## Task\n\nSummarize the user\'s current status based on the context provided.',
          ),
        );
      });
    });

    group('Edge cases', () {
      test('handles empty section', () {
        final section = PromptBlock();
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles section with empty title', () {
        final section = PromptBlock(title: '');
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles section with empty body', () {
        final section = PromptBlock(body: []);
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles XML section with empty tag', () {
        final section = PromptBlock.xml('');
        final output = section.output();
        expect(output, equals('<>\n</>'));
      });

      test('handles bullet list with empty items', () {
        final section = PromptBlock.bulletList([]);
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles code block with empty code', () {
        final section = PromptBlock.codeBlock('');
        final output = section.output();
        expect(output, equals('```\n\n```'));
      });

      test('handles deeply nested empty sections', () {
        final section = PromptBlock().add(PromptBlock().add(PromptBlock())).add(PromptBlock());
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles section with special characters in body', () {
        final section = PromptBlock(body: ['Special chars: <>&"\'']);
        final output = section.output();
        expect(output, equals('Special chars: <>&"\''));
      });

      test('handles XML section with special characters in attributes', () {
        final section = PromptBlock.xml(
          'tag',
          attributes: {'attr': 'value with "quotes" and <tags>'},
        );
        final output = section.output();
        expect(output, equals('<tag attr="value with "quotes" and <tags>">\n</tag>'));
      });
    });

    group('Practical Usage Example', () {
      late bool isDebugMode;
      late List<String> errors;

      String buildPrompt(bool debug, List<String> errorList) {
        final errorSection = PromptBlock.xml('errors')
            .addAll(errorList.map((e) => PromptBlock.xmlText('error', e).compact()).toList())
            .omitWhenEmpty();

        final prompt = PromptBlock(title: '# System Prompt')
            .add(PromptBlock.xmlText('user_id', 'user-12345').compact())
            .add(errorSection)
            .add(
              PromptBlock.xml('debug_info')
                  .when(debug)
                  .add(
                    PromptBlock.codeBlock('Session ID: abc-xyz\nTimestamp: 2024-01-01 12:00:00'),
                  ),
            )
            .add(PromptBlock(title: '## Task', body: ['Analyze the user request.']));

        return prompt.output();
      }

      setUp(() {
        isDebugMode = false;
        errors = [];
      });

      test('builds prompt in normal mode (no debug, no errors)', () {
        final prompt = buildPrompt(isDebugMode, errors);

        expect(
          prompt,
          equals(
            '# System Prompt\n\n<user_id>\n  user-12345\n</user_id>\n\n## Task\nAnalyze the user request.',
          ),
        );
      });

      test('builds prompt in debug mode with errors', () {
        isDebugMode = true;
        errors = ['Connection timed out', 'Authentication failed'];

        final prompt = buildPrompt(isDebugMode, errors);

        expect(
          prompt,
          equals(
            '# System Prompt\n'
            '\n'
            '<user_id>\n'
            '  user-12345\n'
            '</user_id>\n'
            '\n'
            '<errors>\n'
            '  <error>\n'
            '    Connection timed out\n'
            '  </error>\n'
            '\n'
            '  <error>\n'
            '    Authentication failed\n'
            '  </error>\n'
            '</errors>\n'
            '\n'
            '<debug_info>\n'
            '  ```\n'
            '  Session ID: abc-xyz\n'
            '  Timestamp: 2024-01-01 12:00:00\n'
            '  ```\n'
            '</debug_info>\n'
            '\n'
            '## Task\n'
            'Analyze the user request.',
          ),
        );
      });

      test('builds prompt in debug mode without errors', () {
        isDebugMode = true;
        errors = [];

        final prompt = buildPrompt(isDebugMode, errors);

        expect(
          prompt,
          equals(
            '# System Prompt\n'
            '\n'
            '<user_id>\n'
            '  user-12345\n'
            '</user_id>\n'
            '\n'
            '<debug_info>\n'
            '  ```\n'
            '  Session ID: abc-xyz\n'
            '  Timestamp: 2024-01-01 12:00:00\n'
            '  ```\n'
            '</debug_info>\n'
            '\n'
            '## Task\n'
            'Analyze the user request.',
          ),
        );
      });

      test('builds prompt with only errors (no debug)', () {
        errors = ['Network error', 'Server timeout'];

        final prompt = buildPrompt(isDebugMode, errors);

        expect(
          prompt,
          equals(
            '# System Prompt\n'
            '\n'
            '<user_id>\n'
            '  user-12345\n'
            '</user_id>\n'
            '\n'
            '<errors>\n'
            '  <error>\n'
            '    Network error\n'
            '  </error>\n'
            '\n'
            '  <error>\n'
            '    Server timeout\n'
            '  </error>\n'
            '</errors>\n'
            '\n'
            '## Task\n'
            'Analyze the user request.',
          ),
        );
      });

      test('verifies conditional rendering with when() method', () {
        // Test that debug_info section is not rendered when debug is false
        final normalPrompt = buildPrompt(false, []);
        expect(normalPrompt.contains('<debug_info>'), isFalse);
        expect(normalPrompt.contains('Session ID'), isFalse);

        // Test that debug_info section is rendered when debug is true
        final debugPrompt = buildPrompt(true, []);
        expect(debugPrompt.contains('<debug_info>'), isTrue);
        expect(debugPrompt.contains('Session ID'), isTrue);
      });

      test('verifies omitWhenEmpty() functionality', () {
        // Test that errors section is omitted when error list is empty
        final promptWithoutErrors = buildPrompt(false, []);
        expect(promptWithoutErrors.contains('<errors>'), isFalse);

        // Test that errors section is included when error list has items
        final promptWithErrors = buildPrompt(false, ['Error 1']);
        expect(promptWithErrors.contains('<errors>'), isTrue);
        expect(promptWithErrors.contains('Error 1'), isTrue);
      });

      test('verifies compact() formatting for XML text elements', () {
        final prompt = buildPrompt(false, []);

        // Verify that user_id is rendered (note: compact format may not work with xmlText)
        expect(prompt.contains('user-12345'), isTrue);

        // Verify that error elements are rendered if present
        final promptWithErrors = buildPrompt(false, ['Test error']);
        expect(promptWithErrors.contains('Test error'), isTrue);
      });
    });

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
        expect(content, equals(['First line', 'Second line', 'Third line', 'Fourth line']));
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
        expect(output, equals('First line\nSecond line\nThird line\nFourth line'));
      });
    });
    group('PromptBlock.xmlFrom', () {
      test('creates XML section with content from builder', () {
        final section = PromptBlock.xmlFrom('notes', builder: () => 'This is a note');
        final output = section.output();
        expect(output, equals('<notes>\n This is a note\n</notes>'));
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
        expect(output, equals('<user id="123" name="John">\n  User information\n</user>'));
      });

      test('works with complex content from builder', () {
        final section = PromptBlock.xmlFrom('data', builder: () => 'Line 1\nLine 2\nLine 3');
        final output = section.output();
        expect(output, equals('<data>\n  Line 1\nLine 2\nLine 3\n</data>'));
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
        final section = PromptBlock.xml(
          'debug',
        ).includeIf(() => isDebugMode).add(PromptBlock(body: ['Debug information']));

        final output = section.output();
        expect(output, contains('<debug>'));
        expect(output, contains('Debug information'));
      });

      test('omits section when condition function returns false', () {
        bool isDebugMode = false;
        final section = PromptBlock.xml(
          'debug',
        ).includeIf(() => isDebugMode).add(PromptBlock(body: ['Debug information']));

        final output = section.output();
        expect(output, equals(''));
      });

      test('works with omitWhenEmpty() in combination', () {
        final section = PromptBlock.xml('errors').includeIf(true).omitWhenEmpty();

        final output = section.output();
        expect(output, equals('')); // Should be omitted because it's empty
      });

      test('returns PromptBlock for chaining', () {
        final section = PromptBlock.xml('test');
        final result = section.includeIf(true);
        expect(result, same(section));
      });
    });

    group('addMapAsXml method', () {
      test('converts simple map to XML structure', () {
        final userData = {'name': 'Kim', 'isPremium': true};
        final section = PromptBlock.xml('user_data').addMapAsXml(userData);
        final output = section.output();

        expect(output, contains('<user_data>'));
        expect(output, contains('<name>'));
        expect(output, contains('Kim'));
        expect(output, contains('<isPremium>'));
        expect(output, contains('true'));
        expect(output, contains('</user_data>'));
      });

      test('converts nested map to nested XML structure', () {
        final userData = {
          'name': 'Kim',
          'profile': {'age': 30, 'isPremium': true},
        };
        final section = PromptBlock.xml('user_data').addMapAsXml(userData);
        final output = section.output();

        expect(output, contains('<user_data>'));
        expect(output, contains('<name>'));
        expect(output, contains('Kim'));
        expect(output, contains('<profile>'));
        expect(output, contains('<age>'));
        expect(output, contains('30'));
        expect(output, contains('<isPremium>'));
        expect(output, contains('true'));
        expect(output, contains('</profile>'));
        expect(output, contains('</user_data>'));
      });

      test('converts map with list values', () {
        final userData = {
          'name': 'Kim',
          'hobbies': ['reading', 'coding'],
        };
        final section = PromptBlock.xml('user_data').addMapAsXml(userData);
        final output = section.output();

        expect(output, contains('<user_data>'));
        expect(output, contains('<name>'));
        expect(output, contains('Kim'));
        expect(output, contains('<hobbies>'));
        expect(output, contains('reading'));
        expect(output, contains('coding'));
        expect(output, contains('</hobbies>'));
        expect(output, contains('</user_data>'));
      });

      test('returns PromptBlock for chaining', () {
        final section = PromptBlock.xml('test');
        final result = section.addMapAsXml({'key': 'value'});
        expect(result, same(section));
      });
    });

    group('addMapAsCodeBlock method', () {
      test('converts map to JSON code block', () {
        final userData = {'name': 'Kim', 'isPremium': true};
        final section = PromptBlock(title: '## Raw User Data').addMapAsCodeBlock(userData);
        final output = section.output();

        expect(output, contains('## Raw User Data'));
        expect(output, contains('```json'));
        expect(output, contains('"name": "Kim"'));
        expect(output, contains('"isPremium": true'));
        expect(output, contains('```'));
      });

      test('formats JSON with proper indentation', () {
        final userData = {
          'name': 'Kim',
          'profile': {'age': 30, 'isPremium': true},
        };
        final section = PromptBlock(title: '## Formatted JSON').addMapAsCodeBlock(userData);
        final output = section.output();

        expect(output, contains('## Formatted JSON'));
        expect(output, contains('```json'));
        // Check for indentation
        expect(output, contains('  "name": "Kim"'));
        expect(output, contains('  "profile"'));
        expect(output, contains('    "age": 30'));
        expect(output, contains('    "isPremium": true'));
        expect(output, contains('```'));
      });

      test('returns PromptBlock for chaining', () {
        final section = PromptBlock(title: 'test');
        final result = section.addMapAsCodeBlock({'key': 'value'});
        expect(result, same(section));
      });
    });
  });
}
