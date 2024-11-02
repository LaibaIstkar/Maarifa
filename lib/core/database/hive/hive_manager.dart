import 'package:hive/hive.dart';

import 'package:maarifa/core/models/quran_model/surah.dart';
import 'package:maarifa/core/models/quran_model/favoriteayah.dart';
import 'package:maarifa/core/models/quran_model/surah_detail.dart';
import 'package:maarifa/core/models/favoritehadithmodel/favorite_hadith.dart';
import 'package:maarifa/core/models/book_model/book.dart';


class HiveBoxManager {
  static Box<Surah>? _surahBox;
  static Box<SurahDetail>? _surahDetails;
  static Box<FavoriteAyah>? _favoriteAyah;
  static Box<FavoriteHadith>? _favoriteHadith;
  static Box<Book>? _bookBox;



  static Future<Box<Surah>> getSurahBox() async {
    if (_surahBox == null || !_surahBox!.isOpen) {
      _surahBox = await Hive.openBox<Surah>('surahBox');
    }
    return _surahBox!;  }

  static Future<Box<Book>> getBookBox() async {
    if (_bookBox == null || !_bookBox!.isOpen) {
      _bookBox = await Hive.openBox<Book>('bookBox');
    }
    return _bookBox!;  }

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

  static Future<Box<FavoriteHadith>> getFavoriteHadithBox() async {
    if (_favoriteHadith == null || !_favoriteHadith!.isOpen) {
      _favoriteHadith = await Hive.openBox<FavoriteHadith>('favorites');
    }
    return _favoriteHadith!;
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

  static Future<void> closeHadithBox() async {
    if (_favoriteHadith != null && _favoriteHadith!.isOpen) {
      await _favoriteHadith!.close();
    }
  }

}

