import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../routes.dart';

// Services
import '../../services/tflite_service.dart';
import '../../services/local_storage.dart';
import '../../services/supabase_service.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _busy = false;
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService(); // Add this

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
      // Run model prediction
      final result = await tflite.runModelOnImage(_image!);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model returned no result.')),
        );
        setState(() => _busy = false);
        return;
      }

      // Upload image to Supabase Storage and get URL
      String? imageUrl;
      try {
        imageUrl = await _supabaseService.uploadImage(_image!);
        debugPrint('📸 Image uploaded successfully: $imageUrl');
      } catch (e) {
        debugPrint('⚠️ Image upload failed: $e');
        // Continue even if upload fails, just without saving to history
      }

      if (!mounted) return;
      Navigator.pushNamed(context, Routes.result, arguments: {
        'imageFile': _image,
        'result': result,
        'imageUrl': imageUrl ?? '', // Pass the uploaded image URL
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
    await LocalStorage.clearUserId();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
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
    );
  }
}