// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../data/models/stall_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StallDetailAdapter extends TypeAdapter<StallDetail> {
  @override
  final int typeId = 0;

  @override
  StallDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StallDetail(
      date: fields[1] as String?,
      title: fields[2] as String?,
      description: fields[3] as String?,
      imageUrl: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StallDetail obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.imageUrl)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StallDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
