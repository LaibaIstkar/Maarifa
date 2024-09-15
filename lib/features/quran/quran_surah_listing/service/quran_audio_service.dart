import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranAudioService {
  Future<String> fetchAyahAudioUrl(int ayahNumber) async {
    final url = Uri.parse('http://api.alquran.cloud/v1/ayah/$ayahNumber/ar.alafasy');
    final response = await http.get(url);


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['audio']; // Fetch the audio URL
    } else {
      throw Exception('Failed to load Ayah audio');
    }
  }

  Future<List<String>> fetchSurahAudioUrls(int surahNumber) async {
    final url = Uri.parse('http://api.alquran.cloud/v1/surah/$surahNumber/ar.alafasy');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> audioUrls = [];
      if (data['data'] != null && data['data']['ayahs'] != null) {
        for (var ayah in data['data']['ayahs']) {
          if (ayah['audio'] != null) {
            audioUrls.add(ayah['audio']);
          }
        }
      }
      return audioUrls;
    } else {
      throw Exception('Failed to load Surah audio with status code: ${response.statusCode}');
    }
  }

}