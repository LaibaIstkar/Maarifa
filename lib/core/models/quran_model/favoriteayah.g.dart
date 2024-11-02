// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favoriteayah.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteAyahAdapter extends TypeAdapter<FavoriteAyah> {
  @override
  final int typeId = 1;

  @override
  FavoriteAyah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteAyah(
      arabicText: fields[0] as String,
      englishText: fields[1] as String,
      surahName: fields[2] as String,
      revelationPlace: fields[3] as String,
      ayahNumber: fields[4] as int,
      ayahNumberInSurah: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteAyah obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.arabicText)
      ..writeByte(1)
      ..write(obj.englishText)
      ..writeByte(2)
      ..write(obj.surahName)
      ..writeByte(3)
      ..write(obj.revelationPlace)
      ..writeByte(4)
      ..write(obj.ayahNumber)
      ..writeByte(5)
      ..write(obj.ayahNumberInSurah);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAyahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
