// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../data/models/data_stall.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataStallAdapter extends TypeAdapter<DataStall> {
  @override
  final int typeId = 1;

  @override
  DataStall read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataStall(
      path: fields[0] as String?,
      isVideo: fields[1] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, DataStall obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.isVideo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataStallAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
