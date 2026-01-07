// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetHiveModelAdapter extends TypeAdapter<PetHiveModel> {
  @override
  final int typeId = 0;

  @override
  PetHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      breed: fields[2] as String,
      birthDate: fields[3] as String,
      avatarUrl: fields[4] as String,
      bio: fields[5] as String,
      type: fields[6] as String,
      vaccinesJson: (fields[7] as List).cast<String>(),
      weightHistoryJson: (fields[8] as List).cast<String>(),
      gallery: (fields[9] as List).cast<String>(),
      createdAt: fields[10] as String?,
      updatedAt: fields[11] as String?,
      isDeleted: fields[12] as bool,
      userId: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PetHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.breed)
      ..writeByte(3)
      ..write(obj.birthDate)
      ..writeByte(4)
      ..write(obj.avatarUrl)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.vaccinesJson)
      ..writeByte(8)
      ..write(obj.weightHistoryJson)
      ..writeByte(9)
      ..write(obj.gallery)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isDeleted)
      ..writeByte(13)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
