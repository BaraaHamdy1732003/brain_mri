import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../widgets/prediction_tile.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Future<void> _saveToSupabaseHistory(
    String predictedLabel,
    double confidence,
    Map<String, dynamic> allScores,
    String imageUrl,
  ) async {
    try {
      debugPrint('🔄 Attempting to save to Supabase...');
      debugPrint('📊 Prediction: $predictedLabel');
      debugPrint('🎯 Confidence: $confidence');
      debugPrint('🖼️ Image URL: $imageUrl');
      debugPrint('📈 All scores: $allScores');

      final supabaseService = SupabaseService();
      await supabaseService.savePredictionToHistory(
        imageUrl: imageUrl,
        predictedLabel: predictedLabel,
        confidence: confidence,
        allScores: allScores,
      );
      debugPrint('✅ Prediction saved to Supabase history');
    } catch (e) {
      debugPrint('❌ Failed to save to Supabase history: $e');
      debugPrint('📋 Error details: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final File imageFile = args['imageFile'] as File;
    final Map<String, dynamic> result =
        (args['result'] ?? {}) as Map<String, dynamic>;
    final String imageUrl = args['imageUrl']?.toString() ?? '';

    final String predictedLabel = result['label']?.toString() ?? 'Unknown';
    final double confidence = (result['confidence'] as double?) ?? 0.0;
    final Map<String, dynamic> allScores = 
        (result['allScores'] ?? {}) as Map<String, dynamic>;

    // Debug the incoming arguments
    debugPrint('🎬 ResultScreen loaded with:');
    debugPrint('📁 Image file: ${imageFile.path}');
    debugPrint('📦 Result: $result');
    debugPrint('🔗 Image URL from args: $imageUrl');
    debugPrint('🏷️ Predicted label: $predictedLabel');

    // Save to Supabase when screen loads ONLY if we have an image URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (imageUrl.isNotEmpty) {
        _saveToSupabaseHistory(predictedLabel, confidence, allScores, imageUrl);
      } else {
        debugPrint('⚠️ Cannot save to Supabase: imageUrl is empty');
        debugPrint('📋 Available args keys: ${args.keys}');
      }
    });

    // Convert allScores to list for display
    final List<Map<String, dynamic>> probs = allScores.entries.map((entry) {
      return {
        'label': entry.key,
        'score': (entry.value as double?) ?? 0.0,
      };
    }).toList();

    probs.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(imageFile, height: 220),
            const SizedBox(height: 12),
            Text(
              'Predicted: $predictedLabel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: probs.length,
                itemBuilder: (_, idx) {
                  final p = probs[idx];
                  return PredictionTile(
                    label: p['label']?.toString() ?? '',
                    score: (p['score'] as double?) ?? 0.0,
                  );
                },
              ),
            ),
            if (imageUrl.isNotEmpty)
              const Text(
                'Saved to cloud',
                style: TextStyle(color: Colors.green),
              )
            else
              const Text(
                'Not saved to cloud (no image URL)',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }
}