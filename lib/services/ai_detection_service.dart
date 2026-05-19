import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
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
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              },
              {
                "text":
                    "Lihat gambar ini dan identifikasi semua bahan makanan yang terlihat. Berikan jawaban HANYA dalam format JSON array tanpa penjelasan apapun. Contoh: [\"telur\", \"tomat\", \"bawang merah\"]. Maksimal 10 bahan. Gunakan bahasa Indonesia."
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "maxOutputTokens": 512
        }
      };

      print('Calling Gemini API: ${ApiConfig.geminiVisionEndpoint}');
      print('Request body keys: ${requestBody.keys}');

      final response = await http.post(
        Uri.parse(ApiConfig.geminiVisionEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('candidates') &&
            responseData['candidates'].isNotEmpty) {
          final candidate = responseData['candidates'][0];

          if (candidate.containsKey('content') &&
              candidate['content'].containsKey('parts') &&
              candidate['content']['parts'].isNotEmpty) {
            final textResponse = candidate['content']['parts'][0]['text'];
            
            print('AI Response Text: $textResponse');

            final ingredients =
                IngredientParser.parseGeminiResponse(textResponse);

            if (ingredients.isEmpty) {
              return ScanResult.error(
                  'Tidak ada bahan makanan yang terdeteksi dalam gambar');
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
          return ScanResult.error('Error 400: $errorMessage');
        } catch (e) {
          return ScanResult.error(
              'Error 400: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        }
      } else if (response.statusCode == 403) {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['error']?['message'] ??
              'API key tidak valid atau tidak memiliki akses';
          return ScanResult.error('Error 403: $errorMessage');
        } catch (e) {
          return ScanResult.error('API key tidak valid atau tidak memiliki akses');
        }
      } else if (response.statusCode == 429) {
        return ScanResult.error('Terlalu banyak permintaan. Coba lagi nanti');
      } else {
        return ScanResult.error(
            'Gagal mendeteksi bahan: HTTP ${response.statusCode}');
      }
    } on FormatException catch (e) {
      return ScanResult.error('Gagal memproses respons: ${e.message}');
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('XMLHttpRequest')) {
        return ScanResult.error(
            'CORS Error: Gemini API tidak dapat dipanggil langsung dari browser. Gunakan aplikasi mobile atau buat backend proxy server.');
      }
      return ScanResult.error('Terjadi kesalahan: $errorMessage');
    }
  }
}
