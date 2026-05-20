import 'package:hive/hive.dart';

part 'seller_profile_model.g.dart';

@HiveType(typeId: 2)
class SellerProfileModel extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  String shopName;

  @HiveField(2)
  String address;

  @HiveField(3)
  String? profileImagePath;

  SellerProfileModel({
    required this.email,
    required this.shopName,
    required this.address,
    this.profileImagePath,
  });
}
