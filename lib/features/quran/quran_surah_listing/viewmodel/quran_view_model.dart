import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/database/hive/hive_manager.dart';
import 'package:maarifa/core/models/quran_model/surah.dart';
import 'package:maarifa/core/models/quran_model/surah_detail.dart';
import 'package:maarifa/features/quran/quran_surah_listing/api/quran_service.dart';



final quranViewModelProvider = StateNotifierProvider<QuranViewModel, List<Surah>>((ref) {
  return QuranViewModel();
});

class QuranViewModel extends StateNotifier<List<Surah>> {
  QuranViewModel() : super([]);

  final _quranService = QuranService();

  // LIST OF 114 SURAHS
  Future<void> fetchAndStoreSurah() async {
    final box = await HiveBoxManager.getSurahBox();

    if (box.isEmpty) {
      try {
        final surahs = await _quranService.fetchAllSurahs();

        state = surahs;

        for (var surah in surahs) {
          await box.put(surah.number, surah);
        }
      } catch (e) {
        Exception('Error fetching surah list from API: $e');
      }
    } else {
      state = box.values.cast<Surah>().toList();
    }
  }




  Future<SurahDetail> fetchSurahDetail(int surahNumber) async {
    final detailBox = await HiveBoxManager.getSurahDetailBox();
    if (detailBox.containsKey(surahNumber)) {
      return detailBox.get(surahNumber) as SurahDetail;
    } else {
      try {
        final surahDetail = await _quranService.fetchSurahDetail(surahNumber);

        await detailBox.put(surahNumber, surahDetail);

        return surahDetail;
      } catch (e) {
        Exception('Error fetching surah detail from API: $e');
        rethrow;
      }
    }
  }

}
