import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 3)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sellerEmail;

  @HiveField(2)
  String title;

  @HiveField(3)
  double price;

  @HiveField(4)
  int stock;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.sellerEmail,
    required this.title,
    required this.price,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });
}
