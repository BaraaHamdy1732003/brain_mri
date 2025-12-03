// lib/screens/home/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../routes.dart';

// Services
import '../../services/tflite_service.dart';
import '../../services/local_storage.dart';
import '../../services/supabase_service.dart';
import '../../services/last_prediction_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _busy = false;
  int _selectedIndex = 1; // Home is selected by default

  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();

  Future<void> _pick(ImageSource src) async {
    final picked = await _picker.pickImage(source: src, imageQuality: 85);
    if (picked == null) return;
    setState(() => _image = File(picked.path));
    await _analyze();
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() => _busy = true);

    final tflite = Provider.of<TFLiteService>(context, listen: false);

    try {
      final result = await tflite.runModelOnImage(_image!);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model returned no result.')),
        );
        setState(() => _busy = false);
        return;
      }

      // Save the last prediction in memory so the chat can use it
      LastPredictionStore.set(result);

      // Upload image
      String? imageUrl;
      try {
        imageUrl = await _supabaseService.uploadImage(_image!);
        debugPrint('📸 Image uploaded successfully: $imageUrl');
      } catch (e) {
        debugPrint('⚠️ Image upload failed: $e');
      }

      if (!mounted) return;
      Navigator.pushNamed(context, Routes.result, arguments: {
        'imageFile': _image,
        'result': result,
        'imageUrl': imageUrl ?? '',
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    await LocalStorage.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // HOME (left)
      Navigator.pushReplacementNamed(context, Routes.home);
    } else if (index == 1) {
      // PROFILE (right)
      Navigator.pushNamed(context, Routes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain MRI Classifier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, Routes.history),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      // -----------------------------
      // BODY
      // -----------------------------
      body: Center(
        child: _busy
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing image...'),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image == null
                        ? Image.asset('assets/images/logo.png', height: 180)
                        : Image.file(_image!, height: 220),

                    const SizedBox(height: 16),

                    CustomButton(
                      label: 'Pick from gallery',
                      onPressed: () => _pick(ImageSource.gallery),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      label: 'Take a picture',
                      onPressed: () => _pick(ImageSource.camera),
                    ),

                    const SizedBox(height: 12),
                    const Text('Tip: use clear MRI images.'),
                  ],
                ),
              ),
      ),

      // -----------------------------
      // BOTTOM NAVIGATION
      // -----------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // HOME ICON LEFT
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // PROFILE ICON RIGHT
            label: 'Profile',
          ),
        ],
      ),

      // -----------------------------
      // Floating chat button -> opens ChatScreen
      // -----------------------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.chat),
        icon: const Icon(Icons.chat),
        label: const Text('Ask AI'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
