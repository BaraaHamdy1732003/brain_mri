// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/tflite_service.dart';
import 'routes.dart';
import 'utils/theme.dart';
import 'services/supabase_service.dart';

class BrainMriApp extends StatelessWidget {
  const BrainMriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
     providers: [
     Provider<SupabaseService>(create: (_) => SupabaseService()),
  // keep your TFLiteService if you need it
  ],

      child: MaterialApp(
        title: 'Brain MRI App',
        theme: AppTheme.lightTheme,
        initialRoute: Routes.splash,
        // Assuming Routes.getRoutes() exists and returns Map<String, WidgetBuilder>
        routes: Routes.getRoutes(),
      ),
    );
  }
}
