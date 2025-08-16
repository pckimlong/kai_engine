import 'package:flutter_test/flutter_test.dart';
import 'package:kai_engine/src/flex_template.dart';

void main() {
  group('FlexTemplate', () {
    group('Basic variable interpolation', () {
      test('should replace simple variables', () {
        final template = FlexTemplate('Hello {{name}}!');
        final result = template.render({'name': 'World'});
        expect(result, equals('Hello World!'));
      });

      test('should replace multiple variables', () {
        final template = FlexTemplate('{{greeting}} {{name}}!');
        final result = template.render({'greeting': 'Hello', 'name': 'World'});
        expect(result, equals('Hello World!'));
      });

      test('should handle nested variables', () {
        final template = FlexTemplate('Hello {{user.name}}!');
        final result = template.render({
          'user': {'name': 'Alice'},
        });
        expect(result, equals('Hello Alice!'));
      });

      test('should handle missing variables gracefully', () {
        final template = FlexTemplate('Hello {{name}}!');
        final result = template.render({});
        expect(result, equals('Hello !'));
      });
    });

    group('Conditionals', () {
      test('should render if block when condition is true', () {
        final template = FlexTemplate('{{#if isActive}}Active{{/if}}');
        final result = template.render({'isActive': true});
        expect(result, equals('Active'));
      });

      test('should not render if block when condition is false', () {
        final template = FlexTemplate('{{#if isActive}}Active{{/if}}');
        final result = template.render({'isActive': false});
        expect(result, equals(''));
      });

      test('should render else block when condition is false', () {
        final template = FlexTemplate(
          '{{#if isActive}}Active{{#else}}Inactive{{/if}}',
        );
        final result = template.render({'isActive': false});
        expect(result, equals('Inactive'));
      });

      test('should handle complex conditions with equality', () {
        final template = FlexTemplate(
          '{{#if status == "active"}}Active{{/if}}',
        );
        final result = template.render({'status': 'active'});
        expect(result, equals('Active'));
      });

      test('should handle negation conditions', () {
        final template = FlexTemplate('{{#if !isInactive}}Active{{/if}}');
        final result = template.render({'isInactive': false});
        expect(result, equals('Active'));
      });
    });

    group('Loops', () {
      test('should iterate over list items', () {
        final template = FlexTemplate(
          '{{#each users as user}}{{user.name}},{{/each}}',
        );
        final result = template.render({
          'users': [
            {'name': 'Alice'},
            {'name': 'Bob'},
          ],
        });
        expect(result, equals('Alice,Bob,'));
      });

      test('should provide index and helper variables in loops', () {
        final template = FlexTemplate(
          '{{#each users as user}}{{@index}}:{{@first}}:{{@last}},{{/each}}',
        );
        final result = template.render({
          'users': [
            {'name': 'Alice'},
            {'name': 'Bob'},
            {'name': 'Charlie'},
          ],
        });
        expect(result, equals('0:true:false,1:false:false,2:false:true,'));
      });
    });

    group('Built-in functions', () {
      test('should convert text to uppercase', () {
        final template = FlexTemplate('Hello {{upper(name)}}!');
        final result = template.render({'name': 'world'});
        expect(result, equals('Hello WORLD!'));
      });

      test('should convert text to lowercase', () {
        final template = FlexTemplate('Hello {{lower(name)}}!');
        final result = template.render({'name': 'WORLD'});
        expect(result, equals('Hello world!'));
      });

      test('should provide default values', () {
        final template = FlexTemplate('Score: {{default(score, "N/A")}}');
        final result1 = template.render({'score': null});
        expect(result1, equals('Score: N/A'));

        final result2 = template.render({'score': 100});
        expect(result2, equals('Score: 100'));
      });

      test('should calculate string length', () {
        final template = FlexTemplate('Name length: {{length(name)}}');
        final result = template.render({'name': 'Alice'});
        expect(result, equals('Name length: 5'));
      });
    });

    group('Custom functions', () {
      test('should register and use custom functions', () {
        final template = FlexTemplate('{{greet(name, time)}}');
        template.registerFunction('greet', (args, vars) {
          final name = args.isNotEmpty ? args[0] : 'there';
          final time = args.length > 1 ? args[1] : 'day';
          return 'Good $time, $name!';
        });
        final result = template.render({'name': 'Alice', 'time': 'morning'});
        expect(result, equals('Good morning, Alice!'));
      });
    });

    group('Custom delimiters', () {
      test('should work with custom delimiters', () {
        final template = FlexTemplate(
          'Hello <% name %>!',
          openDelimiter: '<%',
          closeDelimiter: '%>',
        );
        final result = template.render({'name': 'World'});
        expect(result, equals('Hello World!'));
      });
    });

    group('TemplateBuilder', () {
      test('should build template variables', () {
        final variables = TemplateBuilder()
            .add('name', 'Alice')
            .add('age', 25)
            .addIf(true, 'isActive', true)
            .addIf(false, 'isVip', true)
            .build();

        expect(variables['name'], equals('Alice'));
        expect(variables['age'], equals(25));
        expect(variables['isActive'], isTrue);
        expect(variables['isVip'], isNull);
      });

      test('should add all variables from map', () {
        final variables = TemplateBuilder().addAll({
          'name': 'Alice',
          'age': 25,
        }).build();

        expect(variables['name'], equals('Alice'));
        expect(variables['age'], equals(25));
      });
    });
  });
}
