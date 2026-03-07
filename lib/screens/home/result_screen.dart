import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/supabase_service.dart';
import '../../services/mri_context.dart';
import '../../widgets/prediction_tile.dart';
import '../../l10n/language_provider.dart';
import '../../l10n/app_localizations.dart';

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
    } catch (_) {}
  }

  String _localizeLabel(BuildContext context, String label) {
    final loc = AppLocalizations.of(context);
    return loc.text(label);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<LanguageProvider>(context);

    final rawArgs = ModalRoute.of(context)!.settings.arguments;
    final Map<String, dynamic> args =
        Map<String, dynamic>.from(rawArgs as Map);

    final File imageFile = args['imageFile'];
    final Map<String, dynamic> result =
        Map<String, dynamic>.from(args['result'] ?? {});

    final String imageUrl = args['imageUrl'] ?? '';
    final String rawPredictedLabel =
        result['label'] ?? 'unknown';

    final double confidence =
        (result['confidence'] as num?)?.toDouble() ?? 0.0;

    final Map<String, dynamic> allScores =
        Map<String, dynamic>.from(result['probabilities'] ?? {});

    MRIContext.predictedLabel = rawPredictedLabel;
    MRIContext.confidence = confidence;
    MRIContext.probabilities = allScores;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (imageUrl.isNotEmpty) {
        _saveToSupabaseHistory(
          rawPredictedLabel,
          confidence,
          allScores,
          imageUrl,
        );
      }
    });

    final probs = allScores.entries
        .map((e) => {
              'label': e.key,
              'score': (e.value as num).toDouble(),
            })
        .toList()
      ..sort(
        (a, b) =>
            (b['score'] as double).compareTo(a['score'] as double),
      );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.text('result')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // Cycle EN → RU → AR → EN
              if (provider.isEnglish) {
                provider.setRussian();
              } else if (provider.isRussian) {
                provider.setArabic();
              } else {
                provider.setEnglish();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(imageFile, height: 220),
            const SizedBox(height: 12),
            Text(
              '${loc.text('predicted')}: ${_localizeLabel(context, rawPredictedLabel)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${loc.text('confidence')}: ${(confidence * 100).toStringAsFixed(2)}%',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: probs.length,
                itemBuilder: (_, i) {
                  return PredictionTile(
                    label: _localizeLabel(context, probs[i]['label'] as String),
                    score: probs[i]['score'] as double,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}