import 'package:flutter/material.dart';

class PredictionTile extends StatelessWidget {
  final String label;
  final double score;

  const PredictionTile({
    super.key,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: LinearProgressIndicator(
        value: score,
        minHeight: 6,
      ),
      trailing: Text('${(score * 100).toStringAsFixed(2)}%'),
    );
  }
}
