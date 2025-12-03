// lib/services/last_prediction_store.dart
class LastPredictionStore {
  // Hold a simple map with keys: label, confidence (double), allScores (Map)
  static Map<String, dynamic>? _lastPrediction;

  static void set(Map<String, dynamic> prediction) {
    _lastPrediction = prediction;
  }

  static Map<String, dynamic>? get() => _lastPrediction;

  static void clear() => _lastPrediction = null;
}
