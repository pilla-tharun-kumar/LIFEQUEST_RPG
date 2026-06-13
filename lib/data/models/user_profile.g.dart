// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      username: fields[0] as String,
      level: fields[1] as int,
      xp: fields[2] as int,
      requiredXp: fields[3] as int,
      coins: fields[4] as int,
      title: fields[5] as String,
      avatarBase: fields[6] as String,
      equippedOutfit: fields[7] as String?,
      equippedAccessory: fields[8] as String?,
      equippedBackground: fields[9] as String?,
      streak: fields[10] as int,
      lastActiveDate: fields[11] as DateTime?,
      readingStreak: fields[12] as int,
      codingStreak: fields[13] as int,
      fitnessStreak: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.xp)
      ..writeByte(3)
      ..write(obj.requiredXp)
      ..writeByte(4)
      ..write(obj.coins)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.avatarBase)
      ..writeByte(7)
      ..write(obj.equippedOutfit)
      ..writeByte(8)
      ..write(obj.equippedAccessory)
      ..writeByte(9)
      ..write(obj.equippedBackground)
      ..writeByte(10)
      ..write(obj.streak)
      ..writeByte(11)
      ..write(obj.lastActiveDate)
      ..writeByte(12)
      ..write(obj.readingStreak)
      ..writeByte(13)
      ..write(obj.codingStreak)
      ..writeByte(14)
      ..write(obj.fitnessStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
