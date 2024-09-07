import 'package:hive/hive.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/favoriteayah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah_detail.dart';

class HiveBoxManager {
  static Box<Surah>? _surahBox;
  static Box<SurahDetail>? _surahDetails;
  static Box<FavoriteAyah>? _favoriteAyah;


  static Future<Box<Surah>> getSurahBox() async {
    if (_surahBox == null || !_surahBox!.isOpen) {
      _surahBox = await Hive.openBox<Surah>('surahBox');
    }
    return _surahBox!;  }

  static Future<Box<SurahDetail>> getSurahDetailBox() async {
    if (_surahDetails == null || !_surahDetails!.isOpen) {
      _surahDetails = await Hive.openBox<SurahDetail>('surahDetails');
    }
    return _surahDetails!;
  }

  static Future<Box<FavoriteAyah>> getFavoriteAyahBox() async {
    if (_favoriteAyah == null || !_favoriteAyah!.isOpen) {
      _favoriteAyah = await Hive.openBox<FavoriteAyah>('favoriteAyah');
    }
    return _favoriteAyah!;
  }

  //Method to close the box if needed
  static Future<void> closeSurahBox() async {
    if (_surahBox != null && _surahBox!.isOpen) {
      await _surahBox!.close();
    }
  }

  static Future<void> closeSurahDetailsBox() async {
    if (_surahDetails != null && _surahDetails!.isOpen) {
      await _surahDetails!.close();
    }
  }

}

