import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
import '../../services/mri_api_service.dart';
import '../../services/supabase_service.dart';
import '../../services/local_storage.dart';
import '../../widgets/custom_button.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/language_provider.dart';
import '../analysis/analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _busy = false;
  int _selectedIndex = 0;

  final ImagePicker _picker = ImagePicker();
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService();
  }

  // -----------------------------
  // PICK IMAGE
  // -----------------------------
  Future<void> _pick(ImageSource source) async {
    final t = AppLocalizations.of(context);

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 95,
      );

      if (picked == null) return;

      if (!mounted) return;
      setState(() {
        _image = File(picked.path);
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack(t.text('pick_failed'));
    }
  }

  // -----------------------------
  // PREDICT
  // -----------------------------
  Future<void> _predict() async {
    final t = AppLocalizations.of(context);

    if (_image == null) {
      _showSnack(t.text('select_mri_first'));
      return;
    }

    if (!mounted) return;
    setState(() => _busy = true);

    try {
      final result = await MRIApiService.predict(_image!);

      String? imageUrl;
      try {
        imageUrl = await _supabaseService.uploadImage(_image!);
      } catch (e) {
        debugPrint('Image upload failed: $e');
      }

      if (!mounted) return;

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
      _showSnack('${t.text('error')}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<void> _logout() async {
    final t = AppLocalizations.of(context);
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.text('logout')),
        content: Text(t.text('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.text('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.text('confirm')),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await LocalStorage.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  // -----------------------------
  // BOTTOM NAV
  // -----------------------------
  void _onNavTap(int index) {
    if (_selectedIndex == index) return; // Don't navigate if same tab
    
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        // Already on home, do nothing
        break;
      case 1:
        Navigator.pushReplacementNamed(context, Routes.chat);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, Routes.profile);
        break;
    }
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.text('brain_mri_classifier')),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (languageCode) {
              languageProvider.changeLanguage(languageCode);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    if (languageProvider.locale.languageCode == 'en')
                      const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('English'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ru',
                child: Row(
                  children: [
                    if (languageProvider.locale.languageCode == 'ru')
                      const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Русский'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ar',
                child: Row(
                  children: [
                    if (languageProvider.locale.languageCode == 'ar')
                      const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('العربية'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, Routes.history),
            tooltip: t.text('history'),
          ),
          IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: t.text('analysis'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnalysisScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: t.text('logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _busy
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      t.text('analyzing'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image display
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: _image == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  height: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Image selection buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: t.text('pick_gallery'),
                              onPressed: () => _pick(ImageSource.gallery),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomButton(
                              label: t.text('take_picture'),
                              onPressed: () => _pick(ImageSource.camera),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Predict button
                      CustomButton(
                        label: t.text('predict'),
                        onPressed: _predict,
                      ),
                      const SizedBox(height: 12),

                      // Tip text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          t.text('tip_clear_mri'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t.text('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: t.text('ai_consultant'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: t.text('profile'),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // HELPERS
  // -----------------------------
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}