import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';

class ProbabilityDistributionChart extends StatelessWidget {
  final Map<String, dynamic> distributionData;
  final String parameter;
  final String unit;

  const ProbabilityDistributionChart({
    super.key,
    required this.distributionData,
    required this.parameter,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (distributionData.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('No data available for distribution analysis'),
          ),
        ),
      );
    }

    final bellCurve = distributionData['bellCurve'] as List<Map<String, double>>? ?? [];
    final mean = distributionData['mean'] as double? ?? 0.0;
    final median = distributionData['median'] as double? ?? 0.0;
    final stdDev = distributionData['stdDev'] as double? ?? 0.0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Probability Distribution - $parameter',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}$unit',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(3),
                            style: const TextStyle(fontSize: 10),
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
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  lineBarsData: [
                    // Bell curve
                    LineChartBarData(
                      spots: bellCurve.map((point) => 
                        FlSpot(point['x']!, point['y']!)
                      ).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    // Mean line
                    LineChartBarData(
                      spots: [
                        FlSpot(mean, 0),
                        FlSpot(mean, _getMaxY(bellCurve) * 0.8),
                      ],
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                    // Median line
                    LineChartBarData(
                      spots: [
                        FlSpot(median, 0),
                        FlSpot(median, _getMaxY(bellCurve) * 0.6),
                      ],
                      isCurved: false,
                      color: Colors.orange,
                      barWidth: 2,
                      dashArray: [3, 3],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatisticItem(
                    label: 'Mean',
                    value: '${mean.toStringAsFixed(1)}$unit',
                    color: Colors.red,
                  ),
                  const SizedBox(width: 16),
                  _StatisticItem(
                    label: 'Median',
                    value: '${median.toStringAsFixed(1)}$unit',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _StatisticItem(
                    label: 'Std Dev',
                    value: '${stdDev.toStringAsFixed(1)}$unit',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<Map<String, double>> bellCurve) {
    if (bellCurve.isEmpty) return 1.0;
    return bellCurve.map((point) => point['y']!).reduce((a, b) => a > b ? a : b);
  }
}

class PercentilesChart extends StatelessWidget {
  final Map<String, double> percentiles;
  final String parameter;
  final String unit;

  const PercentilesChart({
    super.key,
    required this.percentiles,
    required this.parameter,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (percentiles.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('No percentile data available'),
          ),
        ),
      );
    }

    final p10 = percentiles['p10'] ?? 0.0;
    final p25 = percentiles['p25'] ?? 0.0;
    final p50 = percentiles['p50'] ?? 0.0;
    final p75 = percentiles['p75'] ?? 0.0;
    final p90 = percentiles['p90'] ?? 0.0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Probability Ranges - $parameter',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Expected Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$parameter is expected between ${p10.toStringAsFixed(1)}$unit (10th percentile) and ${p90.toStringAsFixed(1)}$unit (90th percentile).',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PercentileItem(label: '10%', value: p10, unit: unit, color: Colors.blue),
                  const SizedBox(width: 8),
                  _PercentileItem(label: '25%', value: p25, unit: unit, color: Colors.green),
                  const SizedBox(width: 8),
                  _PercentileItem(label: '50%', value: p50, unit: unit, color: Colors.orange),
                  const SizedBox(width: 8),
                  _PercentileItem(label: '75%', value: p75, unit: unit, color: Colors.purple),
                  const SizedBox(width: 8),
                  _PercentileItem(label: '90%', value: p90, unit: unit, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfidenceIntervalChart extends StatelessWidget {
  final Map<String, double> confidenceInterval;
  final String parameter;
  final String unit;

  const ConfidenceIntervalChart({
    super.key,
    required this.confidenceInterval,
    required this.parameter,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (confidenceInterval.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('No confidence interval data available'),
          ),
        ),
      );
    }

    final mean = confidenceInterval['mean'] ?? 0.0;
    final lower = confidenceInterval['lower'] ?? 0.0;
    final upper = confidenceInterval['upper'] ?? 0.0;
    final stdDev = confidenceInterval['stdDev'] ?? 0.0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.textAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Confidence Interval (95%) - $parameter',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('Time');
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}$unit',
                            style: const TextStyle(fontSize: 10),
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
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Mean line
                    LineChartBarData(
                      spots: [
                        FlSpot(0, mean),
                        FlSpot(10, mean),
                      ],
                      isCurved: false,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    // Upper bound
                    LineChartBarData(
                      spots: [
                        FlSpot(0, upper),
                        FlSpot(10, upper),
                      ],
                      isCurved: false,
                      color: AppColors.primary.withValues(alpha: 0.5),
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                    // Lower bound
                    LineChartBarData(
                      spots: [
                        FlSpot(0, lower),
                        FlSpot(10, lower),
                      ],
                      isCurved: false,
                      color: AppColors.primary.withValues(alpha: 0.5),
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  betweenBarsData: [
                    BetweenBarsData(
                      fromIndex: 1,
                      toIndex: 2,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '95% Confidence Interval',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lower.toStringAsFixed(1)}$unit - ${upper.toStringAsFixed(1)}$unit',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Mean: ${mean.toStringAsFixed(1)}$unit ± ${stdDev.toStringAsFixed(1)}$unit',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoricalComparisonChart extends StatelessWidget {
  final Map<String, double> yearlyComparison;
  final String parameter;
  final String unit;

  const HistoricalComparisonChart({
    super.key,
    required this.yearlyComparison,
    required this.parameter,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (yearlyComparison.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('No historical comparison data available'),
          ),
        ),
      );
    }

    final sortedYears = yearlyComparison.keys.toList()..sort();
    final spots = sortedYears.asMap().entries.map((entry) {
      final index = entry.key;
      final year = entry.value;
      final value = yearlyComparison[year]!;
      return FlSpot(index.toDouble(), value);
    }).toList();

    final historicalAverage = yearlyComparison.values.reduce((a, b) => a + b) / yearlyComparison.length;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historical Comparison - $parameter',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (sortedYears.length / 5).ceil().toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedYears.length) {
                            return Text(
                              sortedYears[index],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}$unit',
                            style: const TextStyle(fontSize: 10),
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
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Yearly data
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    ),
                    // Historical average line
                    LineChartBarData(
                      spots: [
                        FlSpot(0, historicalAverage),
                        FlSpot(sortedYears.length.toDouble() - 1, historicalAverage),
                      ],
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatisticItem(
                    label: 'Historical Avg',
                    value: '${historicalAverage.toStringAsFixed(1)}$unit',
                    color: Colors.red,
                  ),
                  const SizedBox(width: 16),
                  _StatisticItem(
                    label: 'Years of Data',
                    value: '${sortedYears.length}',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  _StatisticItem(
                    label: 'Latest Year',
                    value: sortedYears.last,
                    color: AppColors.primaryLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatisticItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PercentileItem extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _PercentileItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}