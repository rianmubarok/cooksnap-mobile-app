import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/api_config.dart';
import '../models/scan_result_model.dart';
import '../utils/ingredient_parser.dart';

class AiDetectionService {
  Future<ScanResult> detectIngredients(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image}
              },
              {
                "text":
                    '''Deteksi bahan makanan MENTAH di foto untuk aplikasi resep CookSnap.

Deteksi: sayuran, protein mentah, bumbu, buah masak, bahan pantry.
Jangan deteksi: masakan jadi, peralatan dapur, barang non-makanan.

Aturan:
- Nama bahan dalam bahasa Indonesia, singkat dan umum (contoh: "daging sapi", "bawang merah")
- Jika tidak ada bahan, kembalikan array kosong []'''
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "maxOutputTokens": 1024,
          "responseMimeType": "application/json",
          "responseSchema": {
            "type": "ARRAY",
            "items": {"type": "STRING"}
          }
        }
      };

      debugPrint('Calling Gemini API: ${ApiConfig.geminiVisionEndpoint}');

      final response = await http.post(
        Uri.parse(ApiConfig.geminiVisionEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Gemini response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('candidates') &&
            responseData['candidates'].isNotEmpty) {
          final candidate = responseData['candidates'][0];
          final finishReason = candidate['finishReason'] as String?;

          if (finishReason == 'MAX_TOKENS') {
            debugPrint('Gemini response truncated (MAX_TOKENS)');
          }

          if (candidate.containsKey('content') &&
              candidate['content'].containsKey('parts') &&
              candidate['content']['parts'].isNotEmpty) {
            final textResponse =
                candidate['content']['parts'][0]['text'] as String;

            debugPrint('AI raw response: $textResponse');

            final ingredients =
                IngredientParser.parseGeminiResponse(textResponse);

            if (ingredients.isEmpty) {
              final hint = finishReason == 'MAX_TOKENS'
                  ? ' Respons AI terpotong, coba foto lebih sederhana.'
                  : '';
              return ScanResult.error(
                'Tidak ada bahan makanan yang terdeteksi.$hint',
              );
            }

            return ScanResult.success(ingredients);
          }
        }

        return ScanResult.error('Format respons API tidak valid');
      } else if (response.statusCode == 400) {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['error']?['message'] ?? 'Permintaan tidak valid';
          return ScanResult.error('Kesalahan 400: $errorMessage');
        } catch (e) {
          return ScanResult.error(
              'Kesalahan 400: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        }
      } else if (response.statusCode == 403) {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['error']?['message'] ??
              'Kunci API tidak valid atau tidak memiliki akses';
          return ScanResult.error('Kesalahan 403: $errorMessage');
        } catch (e) {
          return ScanResult.error(
              'Kunci API tidak valid atau tidak memiliki akses');
        }
      } else if (response.statusCode == 429) {
        return ScanResult.error('Terlalu banyak permintaan. Coba lagi nanti');
      } else {
        return ScanResult.error(
            'Gagal mendeteksi bahan (kode ${response.statusCode})');
      }
    } on FormatException catch (e) {
      return ScanResult.error('Gagal memproses respons: ${e.message}');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('XMLHttpRequest')) {
        return ScanResult.error(
            'Tidak dapat terhubung ke layanan AI. Gunakan aplikasi seluler atau hubungi pengembang.');
      }
      return ScanResult.error('Terjadi kesalahan: $errorMessage');
    }
  }
}
