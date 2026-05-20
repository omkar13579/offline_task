import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/hive_service.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

final sellerUpdateProvider = StateProvider<int>((ref) => 0);

class SellerDashboard extends ConsumerWidget {
  const SellerDashboard({super.key});

  void _showProductDialog(BuildContext context, WidgetRef ref, [ProductModel? product]) {
    final titleController = TextEditingController(text: product?.title ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222354),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          product == null ? 'Add Product' : 'Edit Product',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8A56FF))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8A56FF))),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Stock',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8A56FF))),
              ),
              keyboardType: TextInputType.number,
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
              final title = titleController.text;
              final price = double.tryParse(priceController.text) ?? 0;
              final stock = int.tryParse(stockController.text) ?? 0;

              if (title.isNotEmpty && price > 0 && stock >= 0) {
                final auth = ref.read(authProvider);
                if (product == null) {
                  final newProduct = ProductModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    sellerEmail: auth.currentUser!.email,
                    title: title,
                    price: price,
                    stock: stock,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await HiveService.getProductBox().add(newProduct);
                } else {
                  product.title = title;
                  product.price = price;
                  product.stock = stock;
                  product.updatedAt = DateTime.now();
                  await product.save();
                }
                ref.read(sellerUpdateProvider.notifier).state++;
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(product == null ? 'Create' : 'Update', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sellerUpdateProvider);

    final user = ref.read(authProvider).currentUser;
    final products = HiveService.getProductBox()
        .values
        .where((p) => p.sellerEmail == user?.email)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF131438),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1B4B),
        elevation: 0,
        title: const Text('Seller Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider).logout(),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1B4B), Color(0xFF131438)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: products.isEmpty
            ? const Center(
          child: Text(
            'No products yet. Add your first product!',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  product.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Price: \$${product.price}  •  Stock: ${product.stock}\nUpdated: ${DateFormat('yyyy-MM-dd HH:mm').format(product.updatedAt)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFFAC86FF)),
                      onPressed: () => _showProductDialog(context, ref, product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () async {
                        await product.delete();
                        ref.read(sellerUpdateProvider.notifier).state++;
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context, ref),
        backgroundColor: const Color(0xFF8A56FF),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}