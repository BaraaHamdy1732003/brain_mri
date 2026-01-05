import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../routes.dart';
import '../../services/mri_api_service.dart';
import '../../services/supabase_service.dart';
import '../../services/local_storage.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _busy = false;
  int _selectedIndex = 0;

  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();

  // -----------------------------
  // PICK IMAGE
  // -----------------------------
  Future<void> _pick(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 95,
      );

      if (picked == null) return;

      setState(() {
        _image = File(picked.path);
      });
    } catch (e) {
      _showSnack('Failed to pick image');
    }
  }

  // -----------------------------
  // PREDICT (FLASK)
  // -----------------------------
  Future<void> _predict() async {
    if (_image == null) {
      _showSnack('Please select an MRI image first');
      return;
    }

    setState(() => _busy = true);

    try {
      // 1️⃣ Flask prediction
      final result = await MRIApiService.predict(_image!);

      final label = result['label'];
      final confidence = result['confidence'];
      final probabilities = result['probabilities'];

      // 2️⃣ Save for chatbot context
     /* LastPredictionStore.save(
        label: label,
        confidence: confidence,
        probabilities: probabilities,
      );*/

      // 3️⃣ Upload image to Supabase (NON-BLOCKING)
      String? imageUrl;
      try {
        imageUrl = await _supabaseService.uploadImage(_image!);
        debugPrint('📸 Image uploaded successfully: $imageUrl');
      } catch (e) {
        debugPrint('⚠️ Image upload failed: $e');
      }

      if (!mounted) return;

      // 4️⃣ Navigate to result screen
      Navigator.pushNamed(
        context,
        Routes.result,
        arguments: {
          'imageFile': _image,
          'result': result,
          'imageUrl': imageUrl ?? '',
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<void> _logout() async {
    await LocalStorage.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  // -----------------------------
  // BOTTOM NAV
  // -----------------------------
  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, Routes.profile);
    }
  }

  // -----------------------------
  // UI
  // -----------------------------
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
                        ? Image.asset(
                            'assets/images/logo.png',
                            height: 180,
                          )
                        : Image.file(
                            _image!,
                            height: 220,
                          ),

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

                    const SizedBox(height: 16),

                    CustomButton(
                      label: 'Predict',
                      onPressed: _predict,
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      // -----------------------------
      // FLOATING CHAT BUTTON
      // -----------------------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.chat),
        icon: const Icon(Icons.chat),
        label: const Text('Ask AI'),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }

  // -----------------------------
  // HELPERS
  // -----------------------------
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
