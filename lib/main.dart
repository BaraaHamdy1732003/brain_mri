import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes.dart';
import 'services/supabase_service.dart';
import 'l10n/app_localizations.dart';
import 'l10n/language_provider.dart'; // Import the correct LanguageProvider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load environment variables
  await dotenv.load(fileName: ".env");
  debugPrint("✅ .env loaded successfully");

  /// Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  debugPrint("✅ Supabase initialized");

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(
          create: (_) => SupabaseService(),
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider()), // Add this
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>( // Use Consumer to listen to language changes
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Brain MRI Classifier',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          locale: languageProvider.locale, // Set the locale from provider
          initialRoute: Routes.splash,
          routes: Routes.getRoutes(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}