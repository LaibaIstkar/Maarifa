// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_hadith.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteHadithAdapter extends TypeAdapter<FavoriteHadith> {
  @override
  final int typeId = 4;

  @override
  FavoriteHadith read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteHadith(
      hadithNumber: fields[0] as String,
      body: fields[1] as String,
      chapterTitle: fields[2] as String,
      grade: fields[3] as String,
      collectionName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteHadith obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.hadithNumber)
      ..writeByte(1)
      ..write(obj.body)
      ..writeByte(2)
      ..write(obj.chapterTitle)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.collectionName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteHadithAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
