import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  /// Load model and label file
  Future<void> loadModelAndLabels() async {
    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset(
        'assets/model/brain_mri_4class_balanced_model.tflite',
      );

      // Load label file
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelsData.split('\n').where((e) => e.trim().isNotEmpty).toList();

      _isModelLoaded = true;
      debugPrint('✅ Model and labels loaded successfully.');
    } catch (e) {
      debugPrint('❌ Failed to load model or labels: $e');
    }
  }

  /// Run inference on a given image
  Future<Map<String, dynamic>?> runModelOnImage(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      debugPrint('⚠️ Model not loaded yet.');
      return null;
    }

    try {
      // Decode and resize image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Invalid image file.');

      final resized = img.copyResize(image, width: 224, height: 224);

      // Convert to tensor input (Float32 normalized)
      final input = _imageToByteListFloat32(resized, 224);

      // Prepare output buffer
      final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      // Process results
      final scores = List<double>.from(output[0]);
      final maxIndex = scores.indexOf(scores.reduce(math.max));
      final predictedLabel = _labels[maxIndex];
      final confidence = _softmax(scores)[maxIndex];

      debugPrint('✅ Prediction: $predictedLabel (${(confidence * 100).toStringAsFixed(2)}%)');

      return {
        'label': predictedLabel,
        'confidence': confidence,
        'allScores': Map.fromIterables(_labels, scores),
      };
    } catch (e) {
      debugPrint('❌ Error during inference: $e');
      return null;
    }
  }

  /// Convert an image to a normalized Float32 tensor input
  Float32List _imageToByteListFloat32(img.Image image, int inputSize) {
    final convertedBytes = Float32List(inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);

        // ✅ Access RGB directly (image v4+)
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        convertedBytes[pixelIndex++] = r / 255.0;
        convertedBytes[pixelIndex++] = g / 255.0;
        convertedBytes[pixelIndex++] = b / 255.0;
      }
    }

    return convertedBytes;
  }

  /// Softmax helper for probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  /// Clean up interpreter
  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    debugPrint('🧹 Interpreter closed.');
  }
}
