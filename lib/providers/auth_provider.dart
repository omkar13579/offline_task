import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

final authProvider = ChangeNotifierProvider((ref) => AuthProvider());

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isSeller => _currentUser?.role == UserRole.seller;

  Future<String?> login(String email, String password) async {
    final user = HiveService.login(email, password);
    if (user == null) {
      return 'Invalid email or password';
    }
    if (!user.isActive) {
      return 'Your account has been deactivated';
    }
    _currentUser = user;
    notifyListeners();
    return null;
  }

  Future<String?> registerAdmin(String email, String password) async {
    if (HiveService.userExists(email)) {
      return 'Email already exists';
    }
    await HiveService.registerAdmin(email, password);
    return login(email, password);
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> completeSellerProfile() async {
    if (_currentUser != null && _currentUser!.role == UserRole.seller) {
      _currentUser!.isFirstLogin = false;
      await _currentUser!.save();
      notifyListeners();
    }
  }
}
