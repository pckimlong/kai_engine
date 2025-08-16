/// A flexible, reusable template engine for Dart.
///
/// FlexTemplate provides a lightweight templating solution with support for:
/// - Variable interpolation: `{{name}}`
/// - Conditionals: `{{#if condition}}...{{#else}}...{{/if}}`
/// - Loops: `{{#each list as item}}...{{/each}}`
/// - Built-in functions: `{{upper(name)}}`, `{{date("yyyy-MM-dd")}}`
/// - Custom functions registration
/// - Custom delimiters
///
/// ## Basic Usage
///
/// ```dart
/// final template = FlexTemplate('Hello {{name}}!');
/// print(template.render({'name': 'World'})); // "Hello World!"
/// ```
///
/// ## Conditionals
///
/// ```dart
/// final template = FlexTemplate('''
/// Hello {{name}}!
/// {{#if isVip}}
/// Welcome to VIP section!
/// {{#else}}
/// Welcome to our service!
/// {{/if}}
/// ''');
///
/// print(template.render({
///   'name': 'John',
///   'isVip': true,
/// }));
/// ```
///
/// ## Loops
///
/// ```dart
/// final template = FlexTemplate('''
/// Users:
/// {{#each users as user}}
/// - {{user.name}} ({{user.email}})
/// {{/each}}
/// ''');
///
/// print(template.render({
///   'users': [
///     {'name': 'Alice', 'email': 'alice@example.com'},
///     {'name': 'Bob', 'email': 'bob@example.com'},
///   ]
/// }));
/// ```
///
/// ## Functions
///
/// ```dart
/// final template = FlexTemplate('''
/// Hello {{upper(name)}}!
/// Today is {{date("yyyy-MM-dd")}}
/// Your score: {{default(score, "No score yet")}}
/// ''');
/// ```
///
/// ## Custom Delimiters
///
/// ```dart
/// final template = FlexTemplate(
///   'Hello <% name %>!',
///   openDelimiter: '<%',
///   closeDelimiter: '%>',
/// );
/// ```
///
/// ## Template Builder
///
/// ```dart
/// final variables = TemplateBuilder()
///   .add('name', 'Alice')
///   .add('age', 25)
///   .addIf(true, 'isActive', true)
///   .build();
/// ```
///
/// ## Custom Functions
///
/// ```dart
/// final template = FlexTemplate('{{greet(name, time)}}');
/// template.registerFunction('greet', (args, vars) {
///   final name = args.isNotEmpty ? args[0] : 'there';
///   final time = args.length > 1 ? args[1] : 'day';
///   return 'Good $time, $name!';
/// });
/// ```
class FlexTemplate {
  static const String _defaultOpenDelimiter = '{{';
  static const String _defaultCloseDelimiter = '}}';

  final String template;
  final String openDelimiter;
  final String closeDelimiter;
  final Map<String, TemplateFunction> _functions = {};

  FlexTemplate(
    this.template, {
    this.openDelimiter = _defaultOpenDelimiter,
    this.closeDelimiter = _defaultCloseDelimiter,
  }) {
    _registerBuiltInFunctions();
  }

  /// Register a custom function for use in templates
  void registerFunction(String name, TemplateFunction function) {
    _functions[name] = function;
  }

  /// Render the template with variables
  String render(Map<String, dynamic> variables) {
    var result = template;

    // Process functions first (they might generate variables)
    result = _processFunctions(result, variables);

    // Process conditionals
    result = _processConditionals(result, variables);

    // Process loops
    result = _processLoops(result, variables);

    // Process simple variables
    result = _processVariables(result, variables);

    // Clean up
    return _cleanup(result);
  }

  String _processFunctions(String template, Map<String, dynamic> variables) {
    final functionRegex = RegExp(
      r'(' +
          RegExp.escape(openDelimiter) +
          r')\s*(\w+)\((.*?)\)\s*(' +
          RegExp.escape(closeDelimiter) +
          r')',
      dotAll: true,
    );

    return template.replaceAllMapped(functionRegex, (match) {
      final functionName = match.group(2)!;
      final argsString = match.group(3)!;

      if (!_functions.containsKey(functionName)) {
        return match.group(0)!; // Return unchanged if function not found
      }

      final args = _parseArguments(argsString, variables);
      return _functions[functionName]!(args, variables);
    });
  }

  String _processConditionals(String template, Map<String, dynamic> variables) {
    // Handle {{#if condition}}...{{#else}}...{{/if}}
    final ifElseRegex = RegExp(
      r'(' +
          RegExp.escape(openDelimiter) +
          r')#if\s+(.+?)(' +
          RegExp.escape(closeDelimiter) +
          r')(.*?)(' +
          RegExp.escape(openDelimiter) +
          r')#else(' +
          RegExp.escape(closeDelimiter) +
          r')(.*?)(' +
          RegExp.escape(openDelimiter) +
          r')/if(' +
          RegExp.escape(closeDelimiter) +
          r')',
      dotAll: true,
    );

    template = template.replaceAllMapped(ifElseRegex, (match) {
      final condition = match.group(2)!.trim();
      final ifContent = match.group(4)!;
      final elseContent = match.group(7)!;

      return _evaluateCondition(condition, variables) ? ifContent : elseContent;
    });

    // Handle {{#if condition}}...{{/if}}
    final ifRegex = RegExp(
      r'(' +
          RegExp.escape(openDelimiter) +
          r')#if\s+(.+?)(' +
          RegExp.escape(closeDelimiter) +
          r')(.*?)(' +
          RegExp.escape(openDelimiter) +
          r')/if(' +
          RegExp.escape(closeDelimiter) +
          r')',
      dotAll: true,
    );

    return template.replaceAllMapped(ifRegex, (match) {
      final condition = match.group(2)!.trim();
      final content = match.group(4)!;

      return _evaluateCondition(condition, variables) ? content : '';
    });
  }

  String _processLoops(String template, Map<String, dynamic> variables) {
    final loopRegex = RegExp(
      r'(' +
          RegExp.escape(openDelimiter) +
          r')#each\s+(\w+)(?:\s+as\s+(\w+))?(' +
          RegExp.escape(closeDelimiter) +
          r')(.*?)(' +
          RegExp.escape(openDelimiter) +
          r')/each(' +
          RegExp.escape(closeDelimiter) +
          r')',
      dotAll: true,
    );

    return template.replaceAllMapped(loopRegex, (match) {
      final arrayName = match.group(2)!;
      final itemName = match.group(3) ?? 'this';
      final content = match.group(5)!;

      final array = _getNestedValue(arrayName, variables);
      if (array is! List) return '';

      return array
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final item = entry.value;

            final loopVars = Map<String, dynamic>.from(variables);
            loopVars[itemName] = item;
            loopVars['@index'] = index;
            loopVars['@first'] = index == 0;
            loopVars['@last'] = index == array.length - 1;

            return FlexTemplate(
              content,
              openDelimiter: openDelimiter,
              closeDelimiter: closeDelimiter,
            ).render(loopVars);
          })
          .join('');
    });
  }

  String _processVariables(String template, Map<String, dynamic> variables) {
    final variableRegex = RegExp(
      r'(' +
          RegExp.escape(openDelimiter) +
          r')\s*([^#/][^}]*?)\s*(' +
          RegExp.escape(closeDelimiter) +
          r')',
    );

    return template.replaceAllMapped(variableRegex, (match) {
      final variablePath = match.group(2)!.trim();
      final value = _getNestedValue(variablePath, variables);
      return value?.toString() ?? '';
    });
  }

  dynamic _getNestedValue(String path, Map<String, dynamic> variables) {
    final parts = path.split('.');
    dynamic current = variables;

    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else if (current is List && int.tryParse(part) != null) {
        final index = int.parse(part);
        current = index < current.length ? current[index] : null;
      } else {
        return null;
      }
    }

    return current;
  }

  bool _evaluateCondition(String condition, Map<String, dynamic> variables) {
    // Handle simple conditions: variable, !variable, variable == value, etc.
    condition = condition.trim();

    if (condition.startsWith('!')) {
      final variable = condition.substring(1).trim();
      final value = _getNestedValue(variable, variables);
      return !_isTruthy(value);
    }

    if (condition.contains('==')) {
      final parts = condition.split('==').map((s) => s.trim()).toList();
      if (parts.length == 2) {
        final left = _getNestedValue(parts[0], variables);
        final right = _parseValue(parts[1], variables);
        return left == right;
      }
    }

    if (condition.contains('!=')) {
      final parts = condition.split('!=').map((s) => s.trim()).toList();
      if (parts.length == 2) {
        final left = _getNestedValue(parts[0], variables);
        final right = _parseValue(parts[1], variables);
        return left != right;
      }
    }

    // Simple truthiness check
    final value = _getNestedValue(condition, variables);
    return _isTruthy(value);
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.isNotEmpty;
    if (value is num) return value != 0;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  dynamic _parseValue(String value, Map<String, dynamic> variables) {
    value = value.trim();

    // String literal
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }

    // Number literal
    if (num.tryParse(value) != null) {
      return num.parse(value);
    }

    // Boolean literal
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (value == 'null') return null;

    // Variable reference
    return _getNestedValue(value, variables);
  }

  List<dynamic> _parseArguments(
    String argsString,
    Map<String, dynamic> variables,
  ) {
    if (argsString.trim().isEmpty) return [];

    final args = <dynamic>[];
    final parts = argsString.split(',');

    for (final part in parts) {
      args.add(_parseValue(part.trim(), variables));
    }

    return args;
  }

  void _registerBuiltInFunctions() {
    // String functions
    registerFunction(
      'upper',
      (args, vars) =>
          args.isNotEmpty ? args[0]?.toString().toUpperCase() ?? '' : '',
    );
    registerFunction(
      'lower',
      (args, vars) =>
          args.isNotEmpty ? args[0]?.toString().toLowerCase() ?? '' : '',
    );
    registerFunction(
      'length',
      (args, vars) =>
          args.isNotEmpty ? (args[0]?.toString().length ?? 0).toString() : '0',
    );

    // Date functions
    registerFunction('now', (args, vars) => DateTime.now().toIso8601String());
    registerFunction('date', (args, vars) {
      if (args.isEmpty) return DateTime.now().toString();
      final format = args[0]?.toString() ?? 'yyyy-MM-dd';
      // Simple format handling - you could use intl package for more sophisticated formatting
      final now = DateTime.now();
      return format
          .replaceAll('yyyy', now.year.toString())
          .replaceAll('MM', now.month.toString().padLeft(2, '0'))
          .replaceAll('dd', now.day.toString().padLeft(2, '0'));
    });

    // Math functions
    registerFunction('add', (args, vars) {
      if (args.length < 2) return '0';
      final a = args[0] is num ? args[0] : 0;
      final b = args[1] is num ? args[1] : 0;
      return a + b;
    });

    // Default value function
    registerFunction('default', (args, vars) {
      if (args.isNotEmpty && args[0] != null) {
        return args[0].toString();
      }
      return args.length > 1 ? args[1].toString() : '';
    });
  }

  String _cleanup(String result) {
    return result
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .join('\n')
        .trim();
  }
}

/// Function signature for template functions
typedef TemplateFunction =
    String Function(List<dynamic> args, Map<String, dynamic> variables);

/// Builder for easier template creation
class TemplateBuilder {
  final Map<String, dynamic> _variables = {};

  /// Adds a key-value pair to the template variables
  TemplateBuilder add(String key, dynamic value) {
    _variables[key] = value;
    return this;
  }

  /// Adds all key-value pairs from the provided map to the template variables
  TemplateBuilder addAll(Map<String, dynamic> variables) {
    _variables.addAll(variables);
    return this;
  }

  /// Adds a key-value pair to the template variables only if the condition is true
  TemplateBuilder addIf(bool condition, String key, dynamic value) {
    if (condition) _variables[key] = value;
    return this;
  }

  /// Builds and returns an unmodifiable map of the template variables
  Map<String, dynamic> build() => Map.unmodifiable(_variables);
}
