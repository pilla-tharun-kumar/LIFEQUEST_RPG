// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 2;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      name: fields[0] as String,
      stage: fields[1] as String,
      happiness: fields[2] as int,
      hunger: fields[3] as int,
      xp: fields[4] as int,
      requiredXp: fields[5] as int,
      visualType: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.stage)
      ..writeByte(2)
      ..write(obj.happiness)
      ..writeByte(3)
      ..write(obj.hunger)
      ..writeByte(4)
      ..write(obj.xp)
      ..writeByte(5)
      ..write(obj.requiredXp)
      ..writeByte(6)
      ..write(obj.visualType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
