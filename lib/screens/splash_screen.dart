import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/local_storage.dart';
import '../services/tflite_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _init() async {
    // Load TFLite if not loaded (we kept it in provider but ensure loaded)
    final tf = Provider.of<TFLiteService>(context, listen: false);
    try {
      await tf.loadModelAndLabels();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 800));

    final userId = await LocalStorage.getUserId();
    if (userId != null) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
