import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../services/hive_service.dart';
import '../providers/auth_provider.dart';

final adminUpdateProvider = StateProvider<int>((ref) => 0);

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  void _createSeller(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222354),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Create Seller', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Seller Email',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8A56FF))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Temporary Password',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8A56FF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A56FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                if (HiveService.userExists(emailController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User already exists'), backgroundColor: Colors.redAccent),
                  );
                } else {
                  await HiveService.createSeller(
                    emailController.text.trim(),
                    passwordController.text,
                  );
                  ref.read(adminUpdateProvider.notifier).state++;
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(adminUpdateProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF131438),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1B4B),
          elevation: 0,
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          actions: [
            IconButton(
              onPressed: () => ref.read(authProvider).logout(),
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
          bottom: TabBar(
            labelColor: const Color(0xFF8A56FF),
            unselectedLabelColor: Colors.white60,
            indicatorColor: const Color(0xFF8A56FF),
            indicatorWeight: 3,
            tabs: const [
              Tab(child: Text('Sellers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
              Tab(child: Text('Active Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1B4B), Color(0xFF131438)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            children: [
              _buildSellerList(ref),
              _buildActiveProducts(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createSeller(context, ref),
          backgroundColor: const Color(0xFF8A56FF),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSellerList(WidgetRef ref) {
    final sellers = HiveService.getUserBox().values.where((u) => u.role == UserRole.seller).toList();
    if (sellers.isEmpty) {
      return const Center(child: Text('No sellers found.', style: TextStyle(color: Colors.white60, fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sellers.length,
      itemBuilder: (context, index) {
        final seller = sellers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8A56FF).withOpacity(0.2),
              child: const Icon(Icons.person, color: Color(0xFFAC86FF)),
            ),
            title: Text(seller.email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Status: ${seller.isActive ? 'Active' : 'Inactive'}',
              style: TextStyle(color: seller.isActive ? Colors.greenAccent : Colors.white38),
            ),
            trailing: Switch(
              activeColor: const Color(0xFF8A56FF),
              value: seller.isActive,
              onChanged: (value) async {
                seller.isActive = value;
                await seller.save();
                ref.read(adminUpdateProvider.notifier).state++;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveProducts() {
    final userBox = HiveService.getUserBox();
    final activeSellerEmails = userBox.values
        .where((u) => u.role == UserRole.seller && u.isActive)
        .map((u) => u.email)
        .toSet();

    final products = HiveService.getProductBox().values.toList();

    if (products.isEmpty) {
      return const Center(child: Text('No products found.', style: TextStyle(color: Colors.white60, fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isSellerActive = activeSellerEmails.contains(product.sellerEmail);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSellerActive ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.01),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSellerActive ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.02)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              product.title,
              style: TextStyle(
                color: isSellerActive ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
                decoration: isSellerActive ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Seller: ${product.sellerEmail}\nPrice: \$${product.price}',
                style: TextStyle(color: isSellerActive ? Colors.white60 : Colors.white24, fontSize: 13),
              ),
            ),
            trailing: isSellerActive
                ? const Icon(Icons.check_circle_rounded, color: Colors.greenAccent)
                : const Icon(Icons.block_flipped, color: Colors.redAccent),
          ),
        );
      },
    );
  }
}