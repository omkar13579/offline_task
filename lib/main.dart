import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/seller_dashboard.dart';
import 'screens/seller_profile_setup_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return MaterialApp(
      title: 'Admin Seller App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: _getHome(auth),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register_admin': (context) => const AdminRegisterScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/seller_dashboard': (context) => const SellerDashboard(),
        '/seller_setup': (context) => const SellerProfileSetupScreen(),
      },
    );
  }

  Widget _getHome(AuthProvider auth) {
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    final user = auth.currentUser!;
    if (user.role == UserRole.admin) {
      return const AdminDashboard();
    } else {
      if (user.isFirstLogin) {
        return const SellerProfileSetupScreen();
      }
      return const SellerDashboard();
    }
  }
}
