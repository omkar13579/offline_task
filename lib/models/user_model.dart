import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  seller,
}

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final UserRole role;

  @HiveField(3)
  bool isActive;

  @HiveField(4)
  bool isFirstLogin;

  UserModel({
    required this.email,
    required this.password,
    required this.role,
    this.isActive = true,
    this.isFirstLogin = true,
  });
}
