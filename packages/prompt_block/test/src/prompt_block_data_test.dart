import 'package:test/test.dart';

import '../../lib/src/src.dart';

void main() {
  group('PromptBlock Data Methods', () {
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
        final section = PromptBlock(
          title: '## Raw User Data',
        ).addMapAsCodeBlock(userData);
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
        final section = PromptBlock(
          title: '## Formatted JSON',
        ).addMapAsCodeBlock(userData);
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
