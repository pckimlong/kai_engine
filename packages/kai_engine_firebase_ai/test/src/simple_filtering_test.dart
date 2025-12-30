import 'package:test/test.dart';

// Minimal mock classes to test the filtering logic without external dependencies
abstract base class BaseTool {
  final String name;
  BaseTool(this.name);
}

base class GenericTool extends BaseTool {
  GenericTool(super.name);
}

base class SpecialTool extends BaseTool {
  SpecialTool(super.name);
}

// Test the core filtering logic that mimics _effectiveTools
List<SpecialTool> filterSpecialTools(List<BaseTool> tools) {
  return tools.whereType<SpecialTool>().toList();
}

void main() {
  group('Tool Type Filtering - Regression Tests', () {
    test('whereType correctly filters mixed tool types', () {
      final specialTool = SpecialTool('special');
      final genericTool = GenericTool('generic');
      final tools = <BaseTool>[specialTool, genericTool];

      final filtered = filterSpecialTools(tools);

      expect(filtered.length, equals(1));
      expect(filtered.first, isA<SpecialTool>());
      expect(filtered.first.name, equals('special'));
    });

    test('unsafe cast fails as expected', () {
      final specialTool = SpecialTool('special');
      final genericTool = GenericTool('generic');
      final tools = <BaseTool>[specialTool, genericTool];

      // This demonstrates the original error - unsafe casting fails
      expect(() => tools as List<SpecialTool>, throwsA(isA<TypeError>()));
    });

    test('safe filtering with whereType works correctly', () {
      final specialTool = SpecialTool('special');
      final genericTool = GenericTool('generic');
      final tools = <BaseTool>[specialTool, genericTool];

      // This is the safe approach we implemented
      final filtered = tools.whereType<SpecialTool>().toList();

      expect(filtered.length, equals(1));
      expect(filtered.first, same(specialTool));
    });

    test('handles empty list', () {
      final tools = <BaseTool>[];
      final filtered = filterSpecialTools(tools);
      expect(filtered, isEmpty);
    });

    test('handles list with no matching types', () {
      final tool1 = GenericTool('generic1');
      final tool2 = GenericTool('generic2');
      final tools = <BaseTool>[tool1, tool2];

      final filtered = filterSpecialTools(tools);
      expect(filtered, isEmpty);
    });

    test('handles list with only matching types', () {
      final tool1 = SpecialTool('special1');
      final tool2 = SpecialTool('special2');
      final tools = <BaseTool>[tool1, tool2];

      final filtered = filterSpecialTools(tools);
      expect(filtered.length, equals(2));
      // Verify the specific instances are returned
      expect(filtered, contains(tool1));
      expect(filtered, contains(tool2));
    });
  });
}
