class MRIContext {
  static String? predictedLabel;
  static double? confidence;
  static Map<String, dynamic>? probabilities;

  static bool get hasResult =>
      predictedLabel != null &&
      confidence != null &&
      probabilities != null;

  static void clear() {
    predictedLabel = null;
    confidence = null;
    probabilities = null;
  }
}
