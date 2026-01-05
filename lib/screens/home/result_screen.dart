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
      final supabaseService = SupabaseService();
      await supabaseService.savePredictionToHistory(
        imageUrl: imageUrl,
        predictedLabel: predictedLabel,
        confidence: confidence,
        allScores: allScores,
      );
      debugPrint('✅ Prediction saved to Supabase');
    } catch (e) {
      debugPrint('❌ Supabase save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SAFE map conversion
    final rawArgs = ModalRoute.of(context)!.settings.arguments;
    final Map<String, dynamic> args =
        Map<String, dynamic>.from(rawArgs as Map);

    final File imageFile = args['imageFile'] as File;

    final Map<String, dynamic> result =
        Map<String, dynamic>.from(args['result'] ?? {});

    final String imageUrl = args['imageUrl']?.toString() ?? '';

    final String predictedLabel = result['label']?.toString() ?? 'Unknown';

    final double confidence =
        (result['confidence'] is num)
            ? (result['confidence'] as num).toDouble()
            : 0.0;

final Map<String, dynamic> allScores =
    Map<String, dynamic>.from(result['probabilities'] ?? {});


    // Save once when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (imageUrl.isNotEmpty) {
        _saveToSupabaseHistory(
          predictedLabel,
          confidence,
          allScores,
          imageUrl,
        );
      }
    });

    // Prepare scores for UI
    final probs = allScores.entries.map((e) {
      return {
        'label': e.key,
        'score': (e.value as num).toDouble(),
      };
    }).toList()
      ..sort((a, b) =>
          (b['score'] as double).compareTo(a['score'] as double));

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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: probs.length,
                itemBuilder: (_, i) {
                  return PredictionTile(
                   label: probs[i]['label'] as String,
                    score: probs[i]['score'] as double,
                  );
                },
              ),
            ),
            Text(
              imageUrl.isNotEmpty
                  ? 'Saved to cloud'
                  : 'Not saved to cloud',
              style: TextStyle(
                color: imageUrl.isNotEmpty
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
