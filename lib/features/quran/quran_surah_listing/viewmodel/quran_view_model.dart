import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/database/hive/hive_manager.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/api/quran_service.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah_detail.dart';



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

        print('quranviewmodel printing');
        print(surahs);
        state = surahs;

        for (var surah in surahs) {
          await box.put(surah.number, surah);
        }
      } catch (e) {
        print('Error fetching surah list from API: $e');
      }
    } else {
      state = box.values.cast<Surah>().toList();
    }
  }




  Future<SurahDetail> fetchSurahDetail(int surahNumber) async {
    final detailBox = await HiveBoxManager.getSurahDetailBox();
    if (detailBox.containsKey(surahNumber)) {
      // Fetch from local Hive database
      return detailBox.get(surahNumber) as SurahDetail;
    } else {
      try {
        // Fetch from API if not in local database
        final surahDetail = await _quranService.fetchSurahDetail(surahNumber);

        // Store surah detail in Hive for offline use
        await detailBox.put(surahNumber, surahDetail);

        return surahDetail;
      } catch (e) {
        print('Error fetching surah detail from API: $e');
        rethrow; // or handle the error in a user-friendly way
      }
    }
  }

}
