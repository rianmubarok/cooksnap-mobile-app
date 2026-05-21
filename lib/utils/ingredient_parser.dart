import 'dart:convert';
import 'package:flutter/foundation.dart';

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
        debugPrint('IngredientParser: no JSON array in response');
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

      debugPrint('IngredientParser: parsed ${cleanedResponse.length} chars');

      final List<dynamic> parsedList = jsonDecode(cleanedResponse);
      final List<String> ingredients = parsedList
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final uniqueIngredients = ingredients.toSet().toList();

      return uniqueIngredients.take(10).toList();
    } catch (e) {
      debugPrint('IngredientParser error: $e');
      return [];
    }
  }
}
