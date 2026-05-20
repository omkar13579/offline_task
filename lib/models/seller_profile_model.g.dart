// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellerProfileModelAdapter extends TypeAdapter<SellerProfileModel> {
  @override
  final int typeId = 2;

  @override
  SellerProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SellerProfileModel(
      email: fields[0] as String,
      shopName: fields[1] as String,
      address: fields[2] as String,
      profileImagePath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SellerProfileModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.shopName)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.profileImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
