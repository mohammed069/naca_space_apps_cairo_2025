import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../data/repo.dart';

class WeatherResultScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final DateTime date;
  final List<String> parameters;

  const WeatherResultScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.parameters,
  });

  @override
  State<WeatherResultScreen> createState() => _WeatherResultScreenState();
}

class _WeatherResultScreenState extends State<WeatherResultScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, double> _dailyData = {};
  final Map<String, Map<String, double>> _hourlyData = {};

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    
    // إضافة timeout للمستخدم (45 ثانية)
    Timer(const Duration(seconds: 45), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'try again later'; 
        });
      }
    });
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final monthDay = DateFormat('MMdd').format(widget.date);
      
      // Fetch daily data for each parameter
      for (String parameter in widget.parameters) {
        final dailyValue = await AppRepo.getProbabilityOfOneDay(
          monthDay,
          parameter,
          widget.latitude,
          widget.longitude,
        );
        _dailyData[parameter] = dailyValue;

        // Fetch hourly data for each parameter
        final hourlyValues = await AppRepo.getProbabilityOfHourlyData(
          monthDay,
          parameter,
          widget.latitude,
          widget.longitude,
        );
        _hourlyData[parameter] = hourlyValues;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Weather Data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 24),
                            Text(
                              'جاري تحميل بيانات الطقس...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'it may take a few seconds',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _errorMessage = null;
                                      });
                                      _fetchWeatherData();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _fetchWeatherData,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _buildWeatherContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and Date Info
          _buildLocationDateCard(),
          const SizedBox(height: 20),

          // Parameter Cards
          ...widget.parameters.map((parameter) => _buildParameterCard(parameter)),

          const SizedBox(height: 20),

          // Hourly Chart
          _buildHourlyChart(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location: ${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Date: ${DateFormat('MMMM dd, yyyy').format(widget.date)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(String parameter) {
    final value = _dailyData[parameter];
    if (value == null) return const SizedBox.shrink();

    final parameterInfo = _getParameterInfo(parameter);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: parameterInfo['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              parameterInfo['icon'],
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parameterInfo['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${value.toStringAsFixed(2)} ${parameterInfo['unit']}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyChart() {
    if (_hourlyData.isEmpty) return const SizedBox.shrink();
    
    // Use the first parameter for the chart (typically temperature)
    final firstParameter = widget.parameters.first;
    final hourlyValues = _hourlyData[firstParameter];
    if (hourlyValues == null || hourlyValues.isEmpty) return const SizedBox.shrink();

    // Convert hourly data to chart spots
    final spots = <FlSpot>[];
    final sortedHours = hourlyValues.keys.toList()..sort();
    
    for (int i = 0; i < sortedHours.length; i++) {
      final hour = int.parse(sortedHours[i]);
      final value = hourlyValues[sortedHours[i]]!;
      spots.add(FlSpot(hour.toDouble(), value));
    }

    final parameterInfo = _getParameterInfo(firstParameter);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                parameterInfo['icon'],
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Hourly ${parameterInfo['name']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 4,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${value.toInt()}:00',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: null,
                      reservedSize: 42,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 23,
                minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 2,
                maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: parameterInfo['color'],
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: parameterInfo['color'],
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: parameterInfo['color'].withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getParameterInfo(String parameter) {
    switch (parameter) {
      case 'T2M':
        return {
          'name': 'Temperature',
          'icon': '🌡️',
          'unit': '°C',
          'color': Colors.orange,
        };
      case 'RH2M':
        return {
          'name': 'Humidity',
          'icon': '💧',
          'unit': '%',
          'color': Colors.blue,
        };
      case 'WS2M':
        return {
          'name': 'Wind Speed',
          'icon': '💨',
          'unit': 'm/s',
          'color': Colors.green,
        };
      case 'PRECTOTCORR':
        return {
          'name': 'Precipitation',
          'icon': '🌧️',
          'unit': 'mm/hr',
          'color': Colors.indigo,
        };
      case 'ALLSKY_SFC_SW_DWN':
        return {
          'name': 'Solar Radiation',
          'icon': '☀️',
          'unit': 'W/m²',
          'color': Colors.yellow,
        };
      default:
        return {
          'name': parameter,
          'icon': '📊',
          'unit': '',
          'color': Colors.grey,
        };
    }
  }
}
