import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/seller_profile_model.dart';
import '../services/hive_service.dart';
import '../providers/auth_provider.dart';

final profileLoadingProvider = StateProvider<bool>((ref) => false);
final pickedImagePathProvider = StateProvider<String?>((ref) => null);

class SellerProfileSetupScreen extends ConsumerStatefulWidget {
  const SellerProfileSetupScreen({super.key});

  @override
  ConsumerState<SellerProfileSetupScreen> createState() => _SellerProfileSetupScreenState();
}

class _SellerProfileSetupScreenState extends ConsumerState<SellerProfileSetupScreen> {
  late final TextEditingController _shopNameController;
  late final TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      ref.read(pickedImagePathProvider.notifier).state = image.path;
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      ref.read(profileLoadingProvider.notifier).state = true;
      final auth = ref.read(authProvider);
      final pickedImagePath = ref.read(pickedImagePathProvider);
      
      final profile = SellerProfileModel(
        email: auth.currentUser!.email,
        shopName: _shopNameController.text.trim(),
        address: _addressController.text.trim(),
        profileImagePath: pickedImagePath,
      );

      await HiveService.getProfileBox().add(profile);
      await auth.completeSellerProfile();
      if (mounted) {
        ref.read(profileLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileLoadingProvider);
    final pickedImagePath = ref.watch(pickedImagePathProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Complete Your Profile', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1B4B), Color(0xFF292A73), Color(0xFF3B1E61)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Welcome! Please complete your shop details.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.white70),
                            ),
                            const SizedBox(height: 32),
                            // Centered Image Picker
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF8A56FF), width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF8A56FF).withOpacity(0.2),
                                              blurRadius: 16,
                                            )
                                          ]),
                                      clipBehavior: Clip.antiAlias,
                                      child: pickedImagePath != null
                                          ? Image.file(
                                              File(pickedImagePath),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.add_a_photo_outlined, size: 48, color: Color(0xFFAC86FF)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    pickedImagePath != null ? 'Change Photo' : 'Tap to add photo',
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _shopNameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Shop Name',
                                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                      prefixIcon: Icon(Icons.store_outlined, color: Colors.white.withOpacity(0.6)),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.2),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFF8A56FF), width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                      ),
                                    ),
                                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _addressController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Address',
                                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                      prefixIcon: Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.6)),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.2),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFF8A56FF), width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                      ),
                                    ),
                                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 24),
                            if (isLoading)
                              const Center(child: CircularProgressIndicator(color: Color(0xFF8A56FF)))
                            else
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(colors: [Color(0xFF8A56FF), Color(0xFF4D17E2)]),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8A56FF).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text(
                                    'Complete Setup',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
