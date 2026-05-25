import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Parses Gemini vision responses into a list of Indonesian ingredient names.
class IngredientParser {
  static const _maxIngredients = 10;

  static const _objectArrayKeys = [
    'ingredients',
    'bahan',
    'items',
    'detected_ingredients',
    'detectedIngredients',
    'data',
  ];

  static List<String> parseGeminiResponse(String rawResponse) {
    final cleaned = _stripMarkdown(rawResponse.trim());
    if (cleaned.isEmpty) return [];

    final fromDirect = _ingredientsFromDynamic(_tryJsonDecode(cleaned));
    if (fromDirect.isNotEmpty) {
      return _normalize(fromDirect);
    }

    final arrayJson = _extractBalancedJsonArray(cleaned);
    if (arrayJson != null) {
      final fromArray = _ingredientsFromDynamic(_tryJsonDecode(arrayJson));
      if (fromArray.isNotEmpty) {
        return _normalize(fromArray);
      }
    }

    final fromObject = _extractFromJsonObject(cleaned);
    if (fromObject.isNotEmpty) {
      return _normalize(fromObject);
    }

    final fromQuotes = _extractQuotedStrings(cleaned);
    if (fromQuotes.isNotEmpty) {
      debugPrint(
        'IngredientParser: recovered ${fromQuotes.length} items from quoted strings',
      );
      return _normalize(fromQuotes);
    }

    debugPrint('IngredientParser: could not parse response');
    return [];
  }

  static String _stripMarkdown(String text) {
    var result = text;
    if (result.startsWith('```')) {
      result = result.replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '');
      result = result.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return result.trim();
  }

  static dynamic _tryJsonDecode(String jsonStr) {
    try {
      return jsonDecode(jsonStr);
    } catch (_) {
      return null;
    }
  }

  static List<String> _ingredientsFromDynamic(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .map((item) => _itemToIngredient(item))
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (data is Map) {
      for (final key in _objectArrayKeys) {
        final value = data[key];
        if (value is List) {
          return value
              .map((item) => _itemToIngredient(item))
              .where((item) => item.isNotEmpty)
              .toList();
        }
      }
    }

    return [];
  }

  static String _itemToIngredient(dynamic item) {
    if (item is String) return item.trim();
    if (item is Map) {
      for (final key in ['name', 'nama', 'ingredient', 'label']) {
        final value = item[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return item.toString().trim();
  }

  /// Finds a JSON array using bracket depth (handles commas inside strings).
  static String? _extractBalancedJsonArray(String text) {
    final start = text.indexOf('[');
    if (start < 0) return null;

    final end = _findMatchingBracket(text, start);
    if (end != null) {
      return text.substring(start, end + 1);
    }

    return _repairIncompleteArray(text.substring(start));
  }

  static int? _findMatchingBracket(String text, int openIndex) {
    var depth = 0;
    var inString = false;
    var escaped = false;

    for (var i = openIndex; i < text.length; i++) {
      final char = text[i];

      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }

      if (char == '"') {
        inString = true;
        continue;
      }
      if (char == '[') depth++;
      if (char == ']') {
        depth--;
        if (depth == 0) return i;
      }
    }

    return null;
  }

  static String _repairIncompleteArray(String partial) {
    var repaired = partial.trim();
    repaired = repaired.replaceAll(RegExp(r',\s*$'), '');
    if (!repaired.endsWith(']')) repaired = '$repaired]';
    repaired = repaired.replaceAll(RegExp(r',\s*]'), ']');
    return repaired;
  }

  static List<String> _extractFromJsonObject(String text) {
    final start = text.indexOf('{');
    if (start < 0) return [];

    final end = _findMatchingObjectBrace(text, start);
    if (end == null) return [];

    final decoded = _tryJsonDecode(text.substring(start, end + 1));
    return _ingredientsFromDynamic(decoded);
  }

  static int? _findMatchingObjectBrace(String text, int openIndex) {
    var depth = 0;
    var inString = false;
    var escaped = false;

    for (var i = openIndex; i < text.length; i++) {
      final char = text[i];

      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }

      if (char == '"') {
        inString = true;
        continue;
      }
      if (char == '{') depth++;
      if (char == '}') {
        depth--;
        if (depth == 0) return i;
      }
    }

    return null;
  }

  /// Fallback when JSON is truncated: collect double-quoted strings after '['.
  static List<String> _extractQuotedStrings(String text) {
    final bracketIndex = text.indexOf('[');
    if (bracketIndex < 0) return [];

    final segment = text.substring(bracketIndex);
    final matches = RegExp(r'"((?:\\.|[^"\\])*)"').allMatches(segment);

    return matches
        .map((m) => m.group(1) ?? '')
        .map(_unescapeJsonString)
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  static String _unescapeJsonString(String value) {
    return value
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\')
        .replaceAll(r'\n', '\n')
        .trim();
  }

  static List<String> _normalize(List<String> ingredients) {
    final seen = <String>{};
    final result = <String>[];

    for (final raw in ingredients) {
      final name = raw.trim().toLowerCase();
      if (name.isEmpty || seen.contains(name)) continue;
      seen.add(name);
      result.add(name);
      if (result.length >= _maxIngredients) break;
    }

    return result;
  }
}
