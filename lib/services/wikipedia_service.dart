import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  /// Fetches a brief summary of the ingredient from Indonesian Wikipedia.
  static Future<({String summary, String? imageUrl})?> getSummary(String query) async {
    try {
      // 1. Cari menggunakan Search API Wikipedia agar lebih luwes terhadap ejaan/huruf besar-kecil
      final searchUrl = Uri.parse(
          'https://id.wikipedia.org/w/api.php?action=query&list=search&srsearch=${Uri.encodeComponent(query)}&utf8=&format=json');
      
      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode != 200) return null;

      final searchData = json.decode(searchResponse.body);
      final searchResults = searchData['query']?['search'] as List?;
      
      if (searchResults == null || searchResults.isEmpty) return null;

      // 2. Pilih hasil yang paling relevan dengan konteks makanan
      String? bestTitle;
      int bestScore = -999;

      for (var i = 0; i < searchResults.length; i++) {
        if (i >= 5) break; // Cukup cek 5 teratas
        
        final result = searchResults[i];
        final title = (result['title'] as String).toLowerCase();
        final snippet = (result['snippet'] as String).toLowerCase();

        int score = 0;
        
        // Exact match
        if (title == query.toLowerCase()) score += 10;

        // Keyword makanan
        final foodKeywords = [
          'makanan', 'minuman', 'bumbu', 'sayuran', 'sayur', 'buah', 
          'tanaman', 'masakan', 'daging', 'kuliner', 'bahan', 'dapur', 'rempah'
        ];
        for (final kw in foodKeywords) {
          if (title.contains(kw)) score += 5;
          if (snippet.contains(kw)) score += 2;
        }

        // Penalti untuk konteks non-makanan
        final nonFood = ['film', 'album', 'lagu', 'kecamatan', 'desa', 'kota', 'grup', 'band', 'tokoh'];
        for (final kw in nonFood) {
          if (title.contains(kw) || snippet.contains(kw)) score -= 10;
        }

        // Hasil pencarian teratas memiliki prioritas bawaan
        score += (5 - i);

        if (score > bestScore) {
          bestScore = score;
          bestTitle = result['title'] as String;
        }
      }

      if (bestTitle == null) return null;

      // 3. Ambil ringkasan dari judul terbaik
      final summaryUrl = Uri.parse(
          'https://id.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(bestTitle)}');
      
      final summaryResponse = await http.get(summaryUrl);
      
      if (summaryResponse.statusCode == 200) {
        final data = json.decode(summaryResponse.body);
        final summary = data['extract'] as String?;
        if (summary == null) return null;
        
        final thumbnail = data['thumbnail'] as Map<String, dynamic>?;
        final imageUrl = thumbnail?['source'] as String?;

        return (summary: summary, imageUrl: imageUrl);
      }
    } catch (e) {
      // Abaikan error jaringan
    }
    return null;
  }
}
