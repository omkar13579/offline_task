import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/seller_profile_model.dart';
import '../models/product_model.dart';

class HiveService {
  static const String userBoxName = 'users';
  static const String profileBoxName = 'profiles';
  static const String productBoxName = 'products';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserRoleAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(SellerProfileModelAdapter());
    Hive.registerAdapter(ProductModelAdapter());

    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<SellerProfileModel>(profileBoxName);
    await Hive.openBox<ProductModel>(productBoxName);
  }

  static Box<UserModel> getUserBox() => Hive.box<UserModel>(userBoxName);
  static Box<SellerProfileModel> getProfileBox() => Hive.box<SellerProfileModel>(profileBoxName);
  static Box<ProductModel> getProductBox() => Hive.box<ProductModel>(productBoxName);

  // Auth helper
  static UserModel? login(String email, String password) {
    final box = getUserBox();
    try {
      return box.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  static bool userExists(String email) {
    final box = getUserBox();
    return box.values.any((user) => user.email == email);
  }

  static Future<void> registerAdmin(String email, String password) async {
    final box = getUserBox();
    await box.add(UserModel(
      email: email,
      password: password,
      role: UserRole.admin,
    ));
  }

  static Future<void> createSeller(String email, String password) async {
    final box = getUserBox();
    await box.add(UserModel(
      email: email,
      password: password,
      role: UserRole.seller,
    ));
  }
}
