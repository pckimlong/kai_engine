import 'package:flutter_test/flutter_test.dart';

import '../../lib/src/src.dart';

void main() {
  group('PromptBlock Integration Tests', () {
    group('Edge Cases', () {
      test('handles deeply nested empty sections', () {
        final section = PromptBlock()
            .add(PromptBlock().add(PromptBlock().add(PromptBlock())))
            .add(PromptBlock());

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
        expect(
          output,
          equals('<tag attr="value with "quotes" and <tags>">\n</tag>'),
        );
      });

      test('handles XML section with empty tag', () {
        final section = PromptBlock.xml('');
        final output = section.output();
        expect(output, equals('<>\n</>'));
      });

      test('handles deeply nested sections with mixed types', () {
        final section = PromptBlock.xml('root')
            .add(
              PromptBlock.xml('level1')
                  .add(
                    PromptBlock.bulletList([
                      'Item 1',
                      'Item 2',
                    ], type: BulletType.number),
                  )
                  .add(
                    PromptBlock.codeBlock(
                      'print("Hello");',
                      language: 'dart',
                    ).omitWhenEmpty(),
                  ),
            )
            .add(
              PromptBlock(title: '## Title Section')
                  .add(PromptBlock.xmlText('text', 'Simple text'))
                  .add(PromptBlock.xml('empty').omitWhenEmpty()),
            );

        final output = section.output();
        expect(output, contains('<root>'));
        expect(output, contains('<level1>'));
        expect(output, contains('1. Item 1'));
        expect(output, contains('2. Item 2'));
        expect(output, contains('```dart'));
        expect(output, contains('print("Hello");'));
        expect(output, contains('## Title Section'));
        expect(output, contains('<text>'));
        expect(output, contains('Simple text'));
        expect(output, contains('</root>'));
      });

      test('handles multiple conditional sections with complex logic', () {
        bool debugMode = false;
        bool hasErrors = true;
        List<String> errors = ['Error 1', 'Error 2'];
        String? notes = 'Important notes';

        final section = PromptBlock(title: '# System Prompt')
            .add(PromptBlock.xmlText('user_id', 'user-123'))
            .add(
              PromptBlock.xml('debug_info')
                  .includeIf(debugMode)
                  .add(PromptBlock.codeBlock('Debug data here')),
            )
            .add(
              PromptBlock.xml('errors')
                  .includeIf(hasErrors)
                  .addEach(
                    errors,
                    (error) => PromptBlock.xmlText('error', error),
                  ),
            )
            .add(
              PromptBlock.xmlFrom(
                'notes',
                builder: () => notes,
              ).omitWhenEmpty(),
            )
            .add(
              PromptBlock(
                title: '## Task',
              ).add(PromptBlock(body: ['Process the request'])),
            );

        final output = section.output();
        expect(output, contains('# System Prompt'));
        expect(output, contains('<user_id>'));
        expect(output, contains('user-123'));
        // Should not contain debug info since debugMode is false
        expect(output, isNot(contains('<debug_info>')));
        // Should contain errors since hasErrors is true
        expect(output, contains('<errors>'));
        expect(output, contains('Error 1'));
        expect(output, contains('Error 2'));
        // Should contain notes since notes is not null/empty
        expect(output, contains('<notes>'));
        expect(output, contains('Important notes'));
        expect(output, contains('## Task'));
        expect(output, contains('Process the request'));
      });

      test('handles empty collections with addEach', () {
        final emptyList = <String>[];
        final section = PromptBlock.xml(
          'container',
        ).addEach(emptyList, (item) => PromptBlock.xmlText('item', item));

        final output = section.output();
        expect(output, equals('<container>\n</container>'));
      });

      test('handles null values in maps for addMapAsXml', () {
        final dataWithNull = {'name': 'Kim', 'age': null, 'isActive': true};

        final section = PromptBlock.xml('user').addMapAsXml(dataWithNull);
        final output = section.output();

        expect(output, contains('<user>'));
        expect(output, contains('<name>'));
        expect(output, contains('Kim'));
        expect(output, contains('<age>'));
        expect(output, contains('null'));
        expect(output, contains('<isActive>'));
        expect(output, contains('true'));
        expect(output, contains('</user>'));
      });

      test('handles complex nested maps with lists in addMapAsXml', () {
        final complexData = {
          'user': {
            'name': 'Kim',
            'preferences': {
              'themes': ['dark', 'light'],
              'notifications': true,
            },
            'scores': [95, 87, 92],
          },
        };

        final section = PromptBlock.xml('data').addMapAsXml(complexData);
        final output = section.output();

        expect(output, contains('<data>'));
        expect(output, contains('<user>'));
        expect(output, contains('<name>'));
        expect(output, contains('Kim'));
        expect(output, contains('<preferences>'));
        expect(output, contains('<themes>'));
        expect(output, contains('dark'));
        expect(output, contains('light'));
        expect(output, contains('<notifications>'));
        expect(output, contains('true'));
        expect(output, contains('<scores>'));
        expect(output, contains('95'));
        expect(output, contains('87'));
        expect(output, contains('92'));
      });

      test('handles conditional rendering with multiple when() calls', () {
        bool condition1 = true;
        bool condition2 = false;
        bool condition3 = true;

        final section = PromptBlock.xml('conditional')
            .when(condition1)
            .when(condition2)
            .when(condition3)
            .add(PromptBlock(body: ['Should not appear']));

        final output = section.output();
        expect(
          output,
          equals(''),
        ); // Should be empty because condition2 is false
      });

      test('handles omitWhenEmpty with nested conditional sections', () {
        final section = PromptBlock.xml('parent')
            .add(
              PromptBlock.xml(
                'conditional',
              ).includeIf(false).add(PromptBlock(body: ['Should not appear'])),
            )
            .add(
              PromptBlock.xml(
                'another',
              ).includeIf(true).add(PromptBlock(body: ['Should appear'])),
            )
            .omitWhenEmpty();

        final output = section.output();
        expect(output, contains('<parent>'));
        expect(output, isNot(contains('Should not appear')));
        expect(output, contains('Should appear'));
        expect(output, contains('</parent>'));
      });
    });

    group('Practical Usage Examples', () {
      test('complex prompt for AI assistant with user context', () {
        // Simulate user data
        final userContext = {
          'id': 'user-12345',
          'name': 'Kim',
          'profile': {
            'isPremium': true,
            'preferences': {'theme': 'dark', 'notifications': true},
          },
        };

        // Simulate conversation history
        final conversationHistory = [
          {
            'author': 'assistant',
            'content': 'Hey Kim! Good morning.',
            'timestamp': '2024-01-01T09:00:00Z',
          },
          {
            'author': 'user',
            'content': 'Good morning to you too!',
            'timestamp': '2024-01-01T09:0:30Z',
          },
        ];

        // Simulate errors
        final errors = ['Connection timed out', 'Rate limit exceeded'];

        // Build the prompt
        final prompt = PromptBlock(title: '# AI Assistant Prompt')
            .add(
              PromptBlock.xml('user_context')
                  .addMapAsXml(userContext)
                  .add(
                    PromptBlock(title: '## User Preferences').add(
                      PromptBlock.bulletList([
                        'Theme: Dark mode',
                        'Notifications: Enabled',
                        'Premium: Yes',
                      ]),
                    ),
                  ),
            )
            .add(
              PromptBlock.xml(
                'conversation_history',
                attributes: {'count': '${conversationHistory.length}'},
              ).addEach(
                conversationHistory,
                (message) => PromptBlock.xml(
                  'message',
                  attributes: {
                    'author': message['author'] as String,
                    'timestamp': message['timestamp'] as String,
                  },
                ).add(PromptBlock(body: [message['content'] as String])),
              ),
            )
            .add(
              PromptBlock.xml('system_errors')
                  .includeIf(errors.isNotEmpty)
                  .addEach(
                    errors,
                    (error) => PromptBlock.xmlText('error', error).compact(),
                  )
                  .omitWhenEmpty(),
            )
            .add(
              PromptBlock(title: '## Task').add(
                PromptBlock(
                  body: [
                    'Analyze the user\'s current status based on the context provided.',
                    'Respond in a friendly and helpful manner.',
                  ],
                ),
              ),
            )
            .add(
              PromptBlock(title: '## Response Format').add(
                PromptBlock.codeBlock(
                  '{\n  "response": "Your response here",\n  "suggested_actions": []\n}',
                  language: 'json',
                ),
              ),
            );

        final output = prompt.output();

        // Verify structure
        expect(output, contains('# AI Assistant Prompt'));
        expect(output, contains('<user_context>'));
        expect(output, contains('<id>'));
        expect(output, contains('user-12345'));
        expect(output, contains('<name>'));
        expect(output, contains('Kim'));
        expect(output, contains('## User Preferences'));
        expect(output, contains('- Theme: Dark mode'));
        expect(output, contains('- Notifications: Enabled'));
        expect(output, contains('- Premium: Yes'));
        expect(output, contains('<conversation_history'));
        expect(output, contains('count="2"'));
        expect(output, contains('<message'));
        expect(output, contains('author="assistant"'));
        expect(output, contains('author="user"'));
        expect(output, contains('Hey Kim! Good morning.'));
        expect(output, contains('Good morning to you too!'));
        expect(output, contains('<system_errors>'));
        expect(output, contains('Connection timed out'));
        expect(output, contains('Rate limit exceeded'));
        expect(output, contains('## Task'));
        expect(output, contains('Analyze the user\'s current status'));
        expect(output, contains('## Response Format'));
        expect(output, contains('```json'));
      });

      test('dynamic prompt building with conditional debug information', () {
        bool isDebugMode = true;
        List<String> warnings = ['Low memory', 'High CPU usage'];
        Map<String, dynamic> systemMetrics = {
          'cpu_usage': '78%',
          'memory_usage': '85%',
          'disk_space': '12GB free',
        };

        String buildPrompt() {
          return PromptBlock(title: '# System Analysis Prompt')
              .add(
                PromptBlock.xmlText(
                  'timestamp',
                  DateTime.now().toIso8601String(),
                ),
              )
              .add(
                PromptBlock.xml('debug_info')
                    .includeIf(isDebugMode)
                    .add(
                      PromptBlock(
                        title: '## System Metrics',
                      ).addMapAsCodeBlock(systemMetrics),
                    )
                    .add(
                      PromptBlock(title: '## Warnings').add(
                        PromptBlock.bulletList(
                          warnings,
                          type: BulletType.hyphen,
                        ),
                      ),
                    ),
              )
              .add(
                PromptBlock.build((builder) {
                  builder.addLine('Analyze the system status.');
                  builder.addLineIf(
                    isDebugMode,
                    'Include detailed technical information.',
                  );
                  builder.addLine('Provide recommendations for optimization.');
                }),
              )
              .output();
        }

        final output = buildPrompt();

        expect(output, contains('# System Analysis Prompt'));
        expect(output, contains('<timestamp>'));
        expect(output, contains('<debug_info>'));
        expect(output, contains('## System Metrics'));
        expect(output, contains('```json'));
        expect(output, contains('"cpu_usage": "78%"'));
        expect(output, contains('"memory_usage": "85%"'));
        expect(output, contains('"disk_space": "12GB free"'));
        expect(output, contains('## Warnings'));
        expect(output, contains('- Low memory'));
        expect(output, contains('- High CPU usage'));
        expect(output, contains('Analyze the system status.'));
        expect(output, contains('Include detailed technical information.'));
        expect(output, contains('Provide recommendations for optimization.'));
      });

      test('prompt with conditional sections based on user input', () {
        // Simulate user input flags
        bool includeTechnicalDetails = true;
        bool includeExamples = false;
        bool includeReferences = true;
        List<String> topics = ['Flutter', 'Dart', 'State Management'];

        final prompt = PromptBlock(title: '# Code Documentation Assistant')
            .add(
              PromptBlock(
                title: '## Requested Topics',
              ).add(PromptBlock.bulletList(topics, type: BulletType.number)),
            )
            .add(
              PromptBlock.xml('technical_details')
                  .includeIf(includeTechnicalDetails)
                  .add(
                    PromptBlock(
                      body: [
                        'Provide in-depth technical explanations.',
                        'Include code samples where appropriate.',
                      ],
                    ),
                  ),
            )
            .add(
              PromptBlock.xml('examples')
                  .includeIf(includeExamples)
                  .add(
                    PromptBlock(
                      body: [
                        'Include practical examples for each concept.',
                        'Show both good and bad practices.',
                      ],
                    ),
                  ),
            )
            .add(
              PromptBlock.xml('references')
                  .includeIf(includeReferences)
                  .add(
                    PromptBlock(
                      body: [
                        'Link to official documentation.',
                        'Reference relevant GitHub repositories.',
                      ],
                    ),
                  ),
            )
            .add(
              PromptBlock.build((builder) {
                builder.addLine('Generate comprehensive documentation.');
                builder.addLineIf(
                  includeTechnicalDetails,
                  'Focus on technical depth.',
                );
                builder.addLineIf(
                  includeExamples,
                  'Include practical examples.',
                );
                builder.addLineIf(
                  includeReferences,
                  'Provide authoritative references.',
                );
              }),
            );

        final output = prompt.output();

        expect(output, contains('# Code Documentation Assistant'));
        expect(output, contains('## Requested Topics'));
        expect(output, contains('1. Flutter'));
        expect(output, contains('2. Dart'));
        expect(output, contains('3. State Management'));
        expect(output, contains('<technical_details>'));
        expect(output, contains('Provide in-depth technical explanations.'));
        expect(output, isNot(contains('<examples>'))); // Should be omitted
        expect(output, contains('<references>'));
        expect(output, contains('Link to official documentation.'));
        expect(output, contains('Generate comprehensive documentation.'));
        expect(output, contains('Focus on technical depth.'));
        expect(output, contains('Provide authoritative references.'));
      });

      test('complex nested prompt with mixed content types', () {
        final userData = {
          'name': 'Alice',
          'skills': ['Dart', 'Flutter', 'Firebase'],
          'experience': {
            'years': 3,
            'specialties': ['UI/UX', 'Performance Optimization'],
          },
        };

        final projectRequirements = [
          'Implement real-time chat functionality',
          'Add push notifications',
          'Ensure offline support',
        ];

        final prompt = PromptBlock(title: '# Flutter App Development Brief')
            .add(
              PromptBlock.xml('project_overview').add(
                PromptBlock(title: '## Team Member')
                    .addMapAsXml(userData)
                    .add(
                      PromptBlock.xml('skills_list').addEach(
                        userData['skills'] as List<dynamic>,
                        (skill) =>
                            PromptBlock.xmlText('skill', skill.toString()),
                      ),
                    ),
              ),
            )
            .add(
              PromptBlock(title: '## Requirements').add(
                PromptBlock.bulletList(
                  projectRequirements,
                  type: BulletType.hyphen,
                ),
              ),
            )
            .add(
              PromptBlock.xml('implementation_guidelines')
                  .add(
                    PromptBlock.xmlFrom(
                      'architecture_note',
                      builder: () => 'Use clean architecture pattern',
                    ).compact(),
                  )
                  .add(
                    PromptBlock.xml('coding_standards').add(
                      PromptBlock(
                        body: [
                          'Follow Dart style guide',
                          'Use effective Dart patterns',
                          'Maintain consistent code formatting',
                        ],
                      ),
                    ),
                  ),
            )
            .add(
              PromptBlock(title: '## Deliverables').add(
                PromptBlock.build((builder) {
                  builder.addLine('1. Working prototype');
                  builder.addLine('2. Documentation');
                  builder.addLine('3. Test coverage > 80%');
                }),
              ),
            )
            .add(
              PromptBlock.codeBlock(
                'void main() {\n // Your implementation here\n}',
                language: 'dart',
              ),
            );

        final output = prompt.output();

        expect(output, contains('# Flutter App Development Brief'));
        expect(output, contains('<project_overview>'));
        expect(output, contains('<name>'));
        expect(output, contains('Alice'));
        expect(output, contains('<skills_list>'));
        expect(output, contains('<skill>'));
        expect(output, contains('Dart'));
        expect(output, contains('Flutter'));
        expect(output, contains('Firebase'));
        expect(output, contains('## Requirements'));
        expect(output, contains('- Implement real-time chat functionality'));
        expect(output, contains('- Add push notifications'));
        expect(output, contains('- Ensure offline support'));
        expect(output, contains('<implementation_guidelines>'));
        expect(output, contains('<architecture_note>'));
        expect(output, contains('Use clean architecture pattern'));
        expect(output, contains('<coding_standards>'));
        expect(output, contains('Follow Dart style guide'));
        expect(output, contains('## Deliverables'));
        expect(output, contains('1. Working prototype'));
        expect(output, contains('2. Documentation'));
        expect(output, contains('3. Test coverage > 80%'));
        expect(output, contains('```dart'));
        expect(output, contains('void main() {'));
      });
    });
  });
}
