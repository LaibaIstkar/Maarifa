import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maarifa/core/models/quran_model/surah.dart';
import 'package:maarifa/core/models/quran_model/surah_detail.dart';

class QuranService {
  final String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> fetchAllSurahs() async {
    final response = await http.get(Uri.parse('$_baseUrl/surah'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Surah.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }





  Future<SurahDetail> fetchSurahDetail(int surahNumber) async {
    final arabicResponse = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber'));
    final translationResponse = await http.get(Uri.parse('$_baseUrl/surah/$surahNumber/en.asad'));





    if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
      final arabicJson = jsonDecode(arabicResponse.body)['data'];
      final translationJson = jsonDecode(translationResponse.body)['data'];


      // Remove Basmala from the first Ayah of the Arabic text
      if (arabicJson['ayahs'].isNotEmpty && arabicJson['number'] != 1) {
        String firstAyahText = arabicJson['ayahs'][0]['text'];
        if (firstAyahText.startsWith('بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ')) {
          arabicJson['ayahs'][0]['text'] = firstAyahText.replaceFirst('بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ', '').trim();
        }
      }




      return SurahDetail.fromJson(arabicJson, translationJson);
    } else {
      throw Exception('Failed to load surah details');
    }
  }
}





