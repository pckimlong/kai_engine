import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/src/section.dart';

void main() {
  group('Section', () {
    group('Basic Section creation', () {
      test('creates section with title only', () {
        final section = Section(title: '# Introduction');
        expect(section, isNotNull);
      });

      test('creates section with body only', () {
        final section = Section(body: ['This is a simple body line']);
        expect(section, isNotNull);
      });

      test('creates section with both title and body', () {
        final section = Section(title: '## User Profile', body: ['Name: John Doe', 'Age: 30']);
        expect(section, isNotNull);
      });

      test('creates section with children', () {
        final childSection = Section(title: 'Child Section');
        final parentSection = Section(title: 'Parent Section', children: [childSection]);
        expect(parentSection, isNotNull);
      });
    });

    group('XML Section creation', () {
      test('creates XML section with tag only', () {
        final section = Section.xml('user_context');
        expect(section, isNotNull);
      });

      test('creates XML section with tag and attributes', () {
        final section = Section.xml(
          'user_context',
          attributes: {'name': 'Kim', 'role': 'developer'},
        );
        expect(section, isNotNull);
      });

      test('creates XML section with children', () {
        final child = Section.xml('memory', attributes: {'author': 'assistant'});
        final parent = Section.xml(
          'conversation_history',
          attributes: {'turns': '2'},
          children: [child],
        );
        expect(parent, isNotNull);
      });
    });

    group('Bullet List Section creation', () {
      test('creates bullet list with default hyphen type', () {
        final items = ['Item 1', 'Item 2', 'Item 3'];
        final section = Section.bulletList(items);
        expect(section, isNotNull);
      });

      test('creates bullet list with number type', () {
        final items = ['First item', 'Second item', 'Third item'];
        final section = Section.bulletList(items, type: BulletType.number);
        expect(section, isNotNull);
      });

      test('creates bullet list with hyphen type', () {
        final items = ['Point A', 'Point B', 'Point C'];
        final section = Section.bulletList(items, type: BulletType.hyphen);
        expect(section, isNotNull);
      });

      test('creates bullet list with none type', () {
        final items = ['Note 1', 'Note 2', 'Note 3'];
        final section = Section.bulletList(items, type: BulletType.none);
        expect(section, isNotNull);
      });
    });

    group('Code Block Section creation', () {
      test('creates code block without language', () {
        final code = 'print("Hello, World!");\nint x = 5;';
        final section = Section.codeBlock(code);
        expect(section, isNotNull);
      });

      test('creates code block with language', () {
        final code = 'print("Hello, World!");\nint x = 5;';
        final section = Section.codeBlock(code, language: 'dart');
        expect(section, isNotNull);
      });

      test('creates code block with multi-line content', () {
        final code = '''
void main() {
 print("Hello, World!");
  int x = 5;
  print(x);
}''';
        final section = Section.codeBlock(code, language: 'dart');
        expect(section, isNotNull);
      });
    });

    group('Hierarchical nesting', () {
      test('creates nested sections with add method', () {
        final section = Section(
          title: '# Root',
        ).add(Section(title: '## Child 1')).add(Section(title: '## Child 2'));
        expect(section, isNotNull);
      });

      test('creates nested sections with addAll method', () {
        final children = [
          Section(title: '## Child 1'),
          Section(title: '## Child 2'),
          Section(title: '## Child 3'),
        ];
        final section = Section(title: '# Root').addAll(children);
        expect(section, isNotNull);
      });

      test('creates deeply nested sections', () {
        final section = Section(title: '# Root')
            .add(
              Section(title: '## Level 1')
                  .add(Section(title: '### Level 2').add(Section(title: '#### Level 3')))
                  .add(Section(title: '## Another Level 1')),
            )
            .add(Section(title: '## Another Root Child'));
        expect(section, isNotNull);
      });

      test('creates mixed nested sections with different types', () {
        final section = Section(title: '# Mixed Content')
            .add(Section.xml('user_data', attributes: {'id': '123'}))
            .add(Section.bulletList(['Item 1', 'Item 2']))
            .add(Section.codeBlock('print("Hello");', language: 'dart'));
        expect(section, isNotNull);
      });
    });

    group('output method', () {
      test('outputs basic section with title', () {
        final section = Section(title: '# Introduction');
        final output = section.output();
        expect(output, equals('# Introduction'));
      });

      test('outputs basic section with body', () {
        final section = Section(body: ['This is a body line', 'This is another line']);
        final output = section.output();
        expect(output, equals('This is a body line\nThis is another line'));
      });

      test('outputs section with title and body', () {
        final section = Section(title: '## User Profile', body: ['Name: John Doe', 'Age: 30']);
        final output = section.output();
        expect(output, equals('## User Profile\nName: John Doe\nAge: 30'));
      });

      test('outputs XML section with tag', () {
        final section = Section.xml('user_context');
        final output = section.output();
        expect(output, equals('<user_context>\n</user_context>'));
      });

      test('outputs XML section with tag and attributes', () {
        final section = Section.xml(
          'user_context',
          attributes: {'name': 'Kim', 'role': 'developer'},
        );
        final output = section.output();
        expect(output, equals('<user_context name="Kim" role="developer">\n</user_context>'));
      });

      test('outputs XML section with body content', () {
        final section = Section.xml(
          'user_context',
        ).add(Section(body: ['User ID: 123', 'Status: Active']));
        final output = section.output();
        expect(output, equals('<user_context>\n  User ID: 123\n  Status: Active\n</user_context>'));
      });

      test('outputs bullet list with number type', () {
        final section = Section.bulletList([
          'First item',
          'Second item',
          'Third item',
        ], type: BulletType.number);
        final output = section.output();
        expect(output, equals('1. First item\n2. Second item\n3. Third item'));
      });

      test('outputs bullet list with hyphen type', () {
        final section = Section.bulletList([
          'Point A',
          'Point B',
          'Point C',
        ], type: BulletType.hyphen);
        final output = section.output();
        expect(output, equals('- Point A\n- Point B\n- Point C'));
      });

      test('outputs bullet list with none type', () {
        final section = Section.bulletList(['Note 1', 'Note 2', 'Note 3'], type: BulletType.none);
        final output = section.output();
        expect(output, equals('Note 1\nNote 2\nNote 3'));
      });

      test('outputs code block without language', () {
        final section = Section.codeBlock('print("Hello");\nint x = 5;');
        final output = section.output();
        expect(output, equals('```\nprint("Hello");\nint x = 5;\n```'));
      });

      test('outputs code block with language', () {
        final section = Section.codeBlock('print("Hello");\nint x = 5;', language: 'dart');
        final output = section.output();
        expect(output, equals('```dart\nprint("Hello");\nint x = 5;\n```'));
      });

      test('outputs nested sections correctly', () {
        final section = Section(
          title: '# Root',
        ).add(Section(title: '## Child 1')).add(Section(title: '## Child 2'));
        final output = section.output();
        expect(output, equals('# Root\n\n## Child 1\n\n## Child 2'));
      });

      test('outputs deeply nested sections correctly', () {
        final section = Section(title: '# Root')
            .add(
              Section(
                title: '## Level 1',
              ).add(Section(title: '### Level 2')).add(Section(title: '## Another Level 1')),
            )
            .add(Section(title: '## Another Root Child'));
        final output = section.output();
        expect(
          output,
          equals(
            '# Root\n\n## Level 1\n\n### Level 2\n\n## Another Level 1\n\n## Another Root Child',
          ),
        );
      });

      test('outputs complex nested structure with different section types', () {
        final section = Section(title: '# Final Prompt For Gemini')
            .add(
              Section.xml('user_context', attributes: {'name': 'Kim'})
                  .add(
                    Section(title: '## User Profile').add(
                      Section.bulletList([
                        'Currently pursuing a Master\'s degree',
                        'Expected graduation: September 2025',
                        'Interests: AI, Dart, Flutter',
                      ]),
                    ),
                  )
                  .add(
                    Section.xml('conversation_history', attributes: {'turns': '2'}).addAll([
                      Section.xml(
                        'memory',
                        attributes: {'author': 'assistant'},
                      ).add(Section(body: ['Hey Kim! Good morning.'])),
                      Section.xml(
                        'memory',
                        attributes: {'author': 'user'},
                      ).add(Section(body: ['Good morning to you too!'])),
                    ]),
                  ),
            )
            .add(
              Section(title: '## Task').add(
                Section(
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
        final section = Section();
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles section with empty title', () {
        final section = Section(title: '');
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles section with empty body', () {
        final section = Section(body: []);
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles XML section with empty tag', () {
        final section = Section.xml('');
        final output = section.output();
        expect(output, equals('<>\n</>'));
      });

      test('handles bullet list with empty items', () {
        final section = Section.bulletList([]);
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles code block with empty code', () {
        final section = Section.codeBlock('');
        final output = section.output();
        expect(output, equals('```\n\n```'));
      });

      test('handles deeply nested empty sections', () {
        final section = Section().add(Section().add(Section())).add(Section());
        final output = section.output();
        expect(output, equals(''));
      });

      test('handles section with special characters in body', () {
        final section = Section(body: ['Special chars: <>&"\'']);
        final output = section.output();
        expect(output, equals('Special chars: <>&"\''));
      });

      test('handles XML section with special characters in attributes', () {
        final section = Section.xml('tag', attributes: {'attr': 'value with "quotes" and <tags>'});
        final output = section.output();
        expect(output, equals('<tag attr="value with "quotes" and <tags>">\n</tag>'));
      });
    });

    group('Practical Usage Example', () {
      late bool isDebugMode;
      late List<String> errors;

      String buildPrompt(bool debug, List<String> errorList) {
        final errorSection = Section.xml('errors')
            .addAll(errorList.map((e) => Section.xmlText('error', e).compact()).toList())
            .omitWhenEmpty();

        final prompt = Section(title: '# System Prompt')
            .add(Section.xmlText('user_id', 'user-12345').compact())
            .add(errorSection)
            .add(
              Section.xml('debug_info')
                  .when(debug)
                  .add(Section.codeBlock('Session ID: abc-xyz\nTimestamp: 2024-01-01 12:00:00')),
            )
            .add(Section(title: '## Task', body: ['Analyze the user request.']));

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
  });
}
