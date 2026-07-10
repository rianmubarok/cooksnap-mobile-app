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
                    '''Kamu adalah asisten deteksi bahan makanan untuk aplikasi resep Indonesia "CookSnap".

TUGAS: Identifikasi bahan makanan MENTAH yang terlihat di foto ini.

ATURAN KETAT:
1. WAJIB gunakan nama dalam Bahasa Indonesia. DILARANG menggunakan bahasa Inggris.
   Contoh benar: "nanas", "wortel", "bawang merah", "daging sapi"
   Contoh SALAH: "pineapple", "carrot", "onion", "beef"
2. Hanya deteksi bahan mentah: sayuran, buah, daging, ikan, telur, bumbu, rempah, biji-bijian.
3. JANGAN deteksi: makanan jadi/olahan, peralatan dapur, wadah, meja, barang non-makanan.
4. Gunakan nama UMUM dan SINGKAT (maks 2-3 kata per bahan).
5. Maksimal 15 bahan saja. Prioritaskan yang paling jelas terlihat.
6. Jika tidak ada bahan makanan mentah, kembalikan array kosong [].

Format output: JSON array of strings. Contoh: ["wortel", "bawang putih", "ayam"]'''
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

      final modelsToTry = [
        ApiConfig.geminiModel, // 'gemini-3.5-flash'
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-1.5-flash',
      ];

      http.Response? lastResponse;
      for (final modelName in modelsToTry) {
        final endpoint = ApiConfig.getGeminiEndpointForModel(modelName);
        debugPrint('Trying Gemini API model: $modelName -> $endpoint');

        try {
          var response = await http
              .post(
                Uri.parse(endpoint),
                headers: {
                  'Content-Type': 'application/json',
                },
                body: jsonEncode(requestBody),
              )
              .timeout(const Duration(seconds: 25));

          lastResponse = response;
          debugPrint('Model $modelName status: ${response.statusCode}');

          // Jika model sibuk (429) atau tidak ditemukan (404), langsung coba model berikutnya
          if (response.statusCode == 429 || response.statusCode == 404) {
            debugPrint(
                'Model $modelName returned status ${response.statusCode}, trying next fallback model...');
            continue;
          }

          break;
        } catch (e) {
          debugPrint(
              'Model $modelName connection/network error ($e), trying next fallback model...');
          continue;
        }
      }

      if (lastResponse == null) {
        return ScanResult.error(
            'Koneksi terputus saat mengirim foto ke AI. Periksa koneksi internet Anda dan coba lagi.');
      }

      final response = lastResponse;

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
        return ScanResult.error(
            'Server AI sedang sibuk (terlalu banyak permintaan). Silakan tunggu beberapa detik dan coba lagi.');
      } else if (response.statusCode == 404) {
        String errorMsg = 'Model AI tidak ditemukan (kode 404)';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['error']?['message'] != null) {
            errorMsg = 'Kesalahan 404: ${errorBody['error']['message']}';
          }
        } catch (_) {}
        return ScanResult.error(errorMsg);
      } else {
        return ScanResult.error(
            'Gagal mendeteksi bahan (kode ${response.statusCode})');
      }
    } on FormatException catch (e) {
      return ScanResult.error('Gagal memproses respons: ${e.message}');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('XMLHttpRequest') ||
          errorMessage.toLowerCase().contains('connection abort') ||
          errorMessage.toLowerCase().contains('timeout') ||
          errorMessage.toLowerCase().contains('socket')) {
        return ScanResult.error(
            'Koneksi terputus saat mengirim foto ke AI. Periksa koneksi internet Anda dan coba lagi.');
      }
      return ScanResult.error('Terjadi kesalahan saat menganalisis gambar.');
    }
  }
}
