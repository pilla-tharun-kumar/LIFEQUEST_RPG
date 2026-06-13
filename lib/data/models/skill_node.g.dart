// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillNodeAdapter extends TypeAdapter<SkillNode> {
  @override
  final int typeId = 4;

  @override
  SkillNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillNode(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      level: fields[3] as int,
      maxLevel: fields[4] as int,
      requiredCoins: fields[5] as int,
      isUnlocked: fields[6] as bool,
      description: fields[7] as String,
      childrenIds: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SkillNode obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.maxLevel)
      ..writeByte(5)
      ..write(obj.requiredCoins)
      ..writeByte(6)
      ..write(obj.isUnlocked)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.childrenIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
