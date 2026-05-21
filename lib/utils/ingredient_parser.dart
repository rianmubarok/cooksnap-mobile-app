import 'dart:convert';

class IngredientParser {
  static List<String> parseGeminiResponse(String rawResponse) {
    try {
      String cleanedResponse = rawResponse.trim();

      // Remove markdown code blocks if present
      cleanedResponse = cleanedResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Remove all newlines and extra spaces
      cleanedResponse = cleanedResponse
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      // Try to find JSON array pattern
      final jsonArrayPattern = RegExp(r'\[.*?\]');
      final match = jsonArrayPattern.firstMatch(cleanedResponse);

      if (match != null) {
        cleanedResponse = match.group(0)!;
      } else {
        print('No JSON array found in response');
        return [];
      }

      // Clean up trailing commas before closing brackets
      cleanedResponse = cleanedResponse
          .replaceAll(RegExp(r',\s*]'), ']')
          .replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*,'), ',');
      
      // Fix incomplete JSON array (missing closing bracket)
      if (!cleanedResponse.endsWith(']')) {
        // Remove trailing comma if exists
        cleanedResponse = cleanedResponse.replaceAll(RegExp(r',\s*$'), '');
        cleanedResponse += ']';
      }

      print('Cleaned JSON: $cleanedResponse');

      final List<dynamic> parsedList = jsonDecode(cleanedResponse);
      final List<String> ingredients = parsedList
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final uniqueIngredients = ingredients.toSet().toList();

      return uniqueIngredients.take(10).toList();
    } catch (e) {
      print('Parser error: $e');
      print('Raw response: $rawResponse');
      return [];
    }
  }

  static List<String> removeDuplicates(List<String> ingredients) {
    return ingredients.toSet().toList();
  }

  static List<String> extractJsonArray(String text) {
    final jsonArrayPattern = RegExp(r'\[.*?\]', dotAll: true);
    final match = jsonArrayPattern.firstMatch(text);

    if (match != null) {
      try {
        final List<dynamic> parsedList = jsonDecode(match.group(0)!);
        return parsedList.map((item) => item.toString()).toList();
      } catch (e) {
        return [];
      }
    }

    return [];
  }
}
