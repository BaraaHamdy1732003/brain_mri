import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/supabase_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _loading = true;

  Map<String, int> classCounts = {
    'brain_glioma': 0,
    'brain_menin': 0,
    'brain_tumor': 0,
    'normal': 0,
  };

  // Store confidences for accuracy calculation
  List<double> _allConfidences = [];
  double _averageConfidence = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      final history = await _supabaseService.getHistory();

      for (var item in history) {
        final rawLabel = item['predicted_label'];
        final confidence = item['confidence'];

        if (rawLabel == null) continue;

        final label = rawLabel.toString().trim();

        if (classCounts.containsKey(label)) {
          classCounts[label] = (classCounts[label] ?? 0) + 1;
        }

        // Collect confidence scores
        if (confidence != null) {
          _allConfidences.add(confidence.toDouble());
        }
      }

      // Calculate average confidence
      if (_allConfidences.isNotEmpty) {
        _averageConfidence = _allConfidences.reduce((a, b) => a + b) / _allConfidences.length;
      }
    } catch (e) {
      debugPrint('Analysis error: $e');
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  bool _isEmpty() {
    return classCounts.values.every((v) => v == 0);
  }

  int _total() {
    return classCounts.values.fold(0, (a, b) => a + b);
  }

  String _mostCommon() {
    String most = '';
    int max = 0;

    classCounts.forEach((key, value) {
      if (value > max) {
        max = value;
        most = key;
      }
    });

    // Get display name and truncate if needed
    String displayName = _displayName(most);
    if (displayName.length > 12) {
      displayName = displayName.replaceAll(' Tumor', '');
    }
    return displayName;
  }

  String _displayName(String key) {
    switch (key) {
      case 'brain_glioma':
        return 'Glioma';
      case 'brain_menin':
        return 'Meningioma';
      case 'brain_tumor':
        return 'Pituitary Tumor';
      case 'normal':
        return 'Normal';
      default:
        return '';
    }
  }

  // Updated accuracy calculation using actual confidence scores
  double _calculateAccuracy() {
    if (_allConfidences.isEmpty) return 0.0;
    return _averageConfidence * 100; // Convert to percentage
  }

  // Get confidence color based on value
  Color _getConfidenceColor() {
    final accuracy = _calculateAccuracy();
    if (accuracy >= 90) return const Color(0xFF059669); // Green
    if (accuracy >= 75) return const Color(0xFF2563EB); // Blue
    if (accuracy >= 60) return const Color(0xFFFBAB7E); // Orange
    return const Color(0xFFDC2626); // Red
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            )
          : _isEmpty()
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No prediction history available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start making predictions to see analytics',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Main Chart Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Prediction Distribution',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Total: ${_total()}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Legend
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _buildLegendItem('Glioma', const Color(0xFF4158D0)),
                                  _buildLegendItem('Meningioma', const Color(0xFF0093E9)),
                                  _buildLegendItem('Pituitary', const Color(0xFFFBAB7E)),
                                  _buildLegendItem('Normal', const Color(0xFF85FFBD)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Bar Chart
                              SizedBox(
                                height: 220,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _maxY(),
                                    barGroups: _buildEnhancedBars(),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF64748B),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final keys = classCounts.keys.toList();
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                _shortName(keys[value.toInt()]),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: _getGridInterval(),
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: const Color(0xFFE2E8F0),
                                          strokeWidth: 1,
                                          dashArray: [5, 5],
                                        );
                                      },
                                    ),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipPadding: const EdgeInsets.all(6),
                                        tooltipMargin: 6,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '${rod.toY.toInt()} predictions',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Statistics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Most Common',
                              _mostCommon(),
                              Icons.trending_up,
                              const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              'Categories',
                              '4 Types',
                              Icons.category,
                              const Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total',
                              '${_total()}',
                              Icons.analytics,
                              const Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              'Confidence',
                              '${_calculateAccuracy().toStringAsFixed(1)}%',
                              Icons.verified,
                              _getConfidenceColor(),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Detailed Breakdown Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detailed Breakdown',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._buildDetailedBreakdown(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  double _maxY() {
    int max = classCounts.values.reduce((a, b) => a > b ? a : b);
    return (max + 2).toDouble();
  }

  double _getGridInterval() {
    int max = classCounts.values.reduce((a, b) => a > b ? a : b);
    if (max <= 10) return 2;
    if (max <= 20) return 5;
    return 10;
  }

  String _shortName(String key) {
    switch (key) {
      case 'brain_glioma':
        return 'Glioma';
      case 'brain_menin':
        return 'Meningioma';
      case 'brain_tumor':
        return 'Pituitary';
      case 'normal':
        return 'Normal';
      default:
        return '';
    }
  }

  List<BarChartGroupData> _buildEnhancedBars() {
    final values = classCounts.values.toList();
    final colors = [
      [const Color(0xFF4158D0), const Color(0xFFC850C0)], // Purple gradient
      [const Color(0xFF0093E9), const Color(0xFF80D0C7)], // Blue gradient
      [const Color(0xFFFBAB7E), const Color(0xFFF7CE68)], // Orange gradient
      [const Color(0xFF85FFBD), const Color(0xFFFFFB7D)], // Green gradient
    ];

    return List.generate(values.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index].toDouble(),
            width: 24,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: colors[index % colors.length],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          )
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 12),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailedBreakdown() {
    final List<Widget> breakdownItems = [];
    final colors = [
      const Color(0xFF4158D0),
      const Color(0xFF0093E9),
      const Color(0xFFFBAB7E),
      const Color(0xFF85FFBD),
    ];
    
    int index = 0;
    classCounts.forEach((key, value) {
      final percentage = _total() > 0 ? (value / _total() * 100) : 0;
      breakdownItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors[index % colors.length],
                      colors[index % colors.length].withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(key),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: value / _total(),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors[index % colors.length],
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
      index++;
    });
    
    return breakdownItems;
  }
}