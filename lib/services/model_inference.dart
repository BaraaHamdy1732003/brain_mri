import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service for loading and running a TensorFlow Lite brain MRI model.
class BrainMRIPredictor {
  Interpreter? _interpreter;
  late List<String> _labels;
  bool _isLoaded = false;

  /// Load the model and labels
  Future<void> loadModelAndLabels() async {
    try {
      // Load model from assets
      _interpreter = await Interpreter.fromAsset(
        'model/brain_mri_4class_balanced_model.tflite',
      );

      // Define your 4 class labels (adjust if your model uses different ones)
      _labels = ['brain_glioma', 'brain_menin', 'brain_tumor', 'normal'];

      _isLoaded = true;
      debugPrint('✅ Model loaded successfully with ${_labels.length} labels.');
    } catch (e) {
      debugPrint('❌ Failed to load model: $e');
      rethrow;
    }
  }

  /// Run inference on an image and return prediction
  Future<Map<String, dynamic>?> predict(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      throw Exception("❌ Model not loaded. Call loadModelAndLabels() first.");
    }

    try {
      // Decode image file
      final imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Invalid image file.');

      // Resize image to match model input (224x224)
      final img.Image resized = img.copyResize(image, width: 224, height: 224);

      // Convert to Float32 input
      final input = _imageToByteListFloat32(resized, 224);

      // Prepare output buffer
      final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      // Extract and process results
      final List<double> rawScores = List<double>.from(output[0]);
      final List<double> probs = _softmax(rawScores);
      final int maxIndex = probs.indexOf(probs.reduce(math.max));

      final result = {
        'label': _labels[maxIndex],
        'confidence': probs[maxIndex],
        'allScores': Map.fromIterables(_labels, probs),
      };

      debugPrint(
        '✅ Prediction: ${result['label']} '
        '(${(((result['confidence'] as double? ?? 0) * 100).toStringAsFixed(2))}%)',
      );

      return result;
    } catch (e) {
      debugPrint('❌ Error running model inference: $e');
      return null;
    }
  }

  /// Convert an [img.Image] to a Float32 tensor
  Float32List _imageToByteListFloat32(img.Image image, int inputSize) {
    final convertedBytes = Float32List(inputSize * inputSize * 3);
    int pixelIndex = 0;

    // Loop over pixels and normalize RGB to [0,1]
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        convertedBytes[pixelIndex++] = pixel.r / 255.0;
        convertedBytes[pixelIndex++] = pixel.g / 255.0;
        convertedBytes[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return convertedBytes;
  }

  /// Apply softmax to output logits
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  /// Close interpreter and free resources
  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
    debugPrint('🧹 Interpreter closed.');
  }
}
