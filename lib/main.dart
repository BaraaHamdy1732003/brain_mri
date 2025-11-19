import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/tflite_service.dart';
import 'services/supabase_service.dart';
import 'routes.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load .env
  await dotenv.load(fileName: ".env");
  debugPrint("✅ .env loaded successfully");

  /// Initialize Supabase BEFORE running the app
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  debugPrint("✅ Supabase initialized");

  /// Load TFLite model
  final tfliteService = TFLiteService();
  try {
    await tfliteService.loadModelAndLabels();
    debugPrint("✅ TFLite model loaded");
  } catch (e) {
    debugPrint("❌ Failed to load model: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        /// Supabase service
        Provider<SupabaseService>(
          create: (_) => SupabaseService(),
        ),

        /// TFLite
        Provider<TFLiteService>.value(value: tfliteService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain MRI Classifier',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: Routes.splash,
      routes: Routes.getRoutes(),
    );
  }
}
