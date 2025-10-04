// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:naca_app_mobile/views/screens/warnings_screen.dart';
import '../../core/app_colors.dart';
import '../../data/repo.dart';

class FastWeatherResultScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final DateTime date;
  final List<String> parameters;

  const FastWeatherResultScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.parameters,
  });

  @override
  State<FastWeatherResultScreen> createState() => _FastWeatherResultScreenState();
}

class _FastWeatherResultScreenState extends State<FastWeatherResultScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, double> _dailyData = {};
  final Map<String, Map<String, double>> _hourlyData = {};
  int _loadedParameters = 0;

  @override
  void initState() {
    super.initState();
    _fetchWeatherDataFast();
    
    // إضافة timeout للمستخدم (30 ثانية)
    Timer(const Duration(seconds: 30), () {
      if (_isLoading && _loadedParameters == 0) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Request timed out. Please try again later.'; // رسالة الخطأ عند انتهاء المهلة
        });
      }
    });
  }

  Future<void> _fetchWeatherDataFast() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadedParameters = 0;
    });

    try {
      final monthDay = DateFormat('MMdd').format(widget.date);
      
      // جلب معامل واحد فقط في البداية (الحرارة)
      if (widget.parameters.contains('T2M')) {
        await _fetchSingleParameter('T2M', monthDay);
      } else if (widget.parameters.isNotEmpty) {
        await _fetchSingleParameter(widget.parameters.first, monthDay);
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // جلب باقي المعاملات في الخلفية
      _fetchRemainingParameters(monthDay);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _fetchSingleParameter(String parameter, String monthDay) async {
    try {
      final dailyValue = await AppRepo.getProbabilityOfOneDay(
        monthDay,
        parameter,
        widget.latitude,
        widget.longitude,
      );
      _dailyData[parameter] = dailyValue;
      
      final hourlyValues = await AppRepo.getProbabilityOfHourlyData(
        monthDay,
        parameter,
        widget.latitude,
        widget.longitude,
      );
      _hourlyData[parameter] = hourlyValues;
      
      setState(() {
        _loadedParameters++;
      });
    } catch (e) {
      print("Error fetching $parameter: $e");
      rethrow;
    }
  }

  Future<void> _fetchRemainingParameters(String monthDay) async {
    final remainingParams = widget.parameters.where((p) => !_dailyData.containsKey(p)).toList();
    
    for (String parameter in remainingParams) {
      try {
        await _fetchSingleParameter(parameter, monthDay);
      } catch (e) {
        print("Error fetching additional parameter $parameter: $e");
      }
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
                child: _isLoading && _loadedParameters == 0
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
                              'Loading weather data...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'This may take a few moments',
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
                                      _fetchWeatherDataFast();
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
                                ],
                              ),
                            ),
                          )
                        : _buildWeatherData(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherData() {
    if (_dailyData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Loading indicator for additional parameters
          if (_loadedParameters < widget.parameters.length)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Loading additional parameters... (${_loadedParameters}/${widget.parameters.length})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Weather data cards
          ..._dailyData.entries.map((entry) => _buildParameterCard(entry.key, entry.value)),
          
          // Charts section
          if (_hourlyData.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text(
              'Detailed Charts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartsGrid(),
            const SizedBox(height: 32),
          ],
          
          // Show Warnings button
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A5AE0), Color(0xFF9C88FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A5AE0).withValues(alpha: 0.3),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WarningsScreen(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      date: widget.date,
                      dailyData: _dailyData,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon:  Icon(
                Icons.warning_amber_outlined,
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'Show Warnings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildParameterCard(String parameter, double value) {
    final parameterNames = {
      'T2M': 'Temperature',
      'RH2M': 'Humidity',
      'WS2M': 'Wind Speed',
      'PRECTOTCORR': 'Precipitation',
      'ALLSKY_SFC_SW_DWN': 'Solar Radiation',
    };

    final units = {
      'T2M': '°C',
      'RH2M': '%',
      'WS2M': 'm/s',
      'PRECTOTCORR': 'mm',
      'ALLSKY_SFC_SW_DWN': 'kWh/m²',
    };

    final icons = {
      'T2M': Icons.thermostat,
      'RH2M': Icons.water_drop,
      'WS2M': Icons.air,
      'PRECTOTCORR': Icons.cloud_queue,
      'ALLSKY_SFC_SW_DWN': Icons.wb_sunny,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icons[parameter] ?? Icons.help,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parameterNames[parameter] ?? parameter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expected value for this day',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)}${units[parameter] ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsGrid() {
    final availableParams = _hourlyData.keys.take(4).toList();
    if (availableParams.isEmpty) return const SizedBox();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: availableParams.length,
      itemBuilder: (context, index) {
        final parameter = availableParams[index];
        return _buildSingleChart(parameter);
      },
    );
  }

  Widget _buildSingleChart(String parameter) {
    final parameterNames = {
      'T2M': 'Temperature (°C)',
      'RH2M': 'Humidity (%)',
      'WS2M': 'Wind Speed (m/s)',
      'PRECTOTCORR': 'Precipitation (mm)',
      'ALLSKY_SFC_SW_DWN': 'Solar Radiation (kWh/m²)',
    };

    final hourlyData = _hourlyData[parameter];
    if (hourlyData == null || hourlyData.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    hourlyData.entries.forEach((entry) {
      final hour = double.tryParse(entry.key);
      if (hour != null) {
        spots.add(FlSpot(hour, entry.value));
      }
    });

    spots.sort((a, b) => a.x.compareTo(b.x));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameterNames[parameter] ?? parameter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
                      interval: 6,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _getParameterColor(parameter),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _getParameterColor(parameter).withValues(alpha: 0.1),
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

  Color _getParameterColor(String parameter) {
    switch (parameter) {
      case 'T2M':
        return Colors.orange;
      case 'RH2M':
        return Colors.blue;
      case 'WS2M':
        return Colors.green;
      case 'PRECTOTCORR':
        return Colors.lightBlue;
      case 'ALLSKY_SFC_SW_DWN':
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }
}