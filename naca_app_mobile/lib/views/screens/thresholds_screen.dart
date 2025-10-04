import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/settings_provider.dart';

class ThresholdsScreen extends StatefulWidget {
  const ThresholdsScreen({super.key});

  @override
  State<ThresholdsScreen> createState() => _ThresholdsScreenState();
}

class _ThresholdsScreenState extends State<ThresholdsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _thresholdController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _thresholdController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                        'Settings',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Thresholds Section
                      _buildCustomThresholdsSection(),
                      const SizedBox(height: 24),
                      
                      // Measurement Units Section
                      _buildMeasurementUnitsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomThresholdsSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Custom Thresholds',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Add threshold form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _thresholdController,
                    decoration: InputDecoration(
                      labelText: 'Threshold Value',
                      labelStyle: TextStyle(color: AppColors.primary),
                      hintText: 'Enter numeric value',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.05),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a threshold value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: AppColors.primary),
                      hintText: 'Describe what this threshold represents',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      prefixIcon: Icon(Icons.description, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.05),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length < 3) {
                        return 'Description must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addThreshold,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Threshold'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Saved thresholds list
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                if (settingsProvider.customThresholds.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No custom thresholds saved yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saved Thresholds:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ...settingsProvider.customThresholds.asMap().entries.map(
                      (entry) => _buildThresholdItem(entry.key, entry.value),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdItem(int index, CustomThreshold threshold) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              threshold.value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              threshold.description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () => _removeThreshold(index),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementUnitsSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.straighten, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Measurement Units',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Temperature Unit
                _buildUnitDropdown(
                  'Temperature',
                  Icons.thermostat,
                  settingsProvider.temperatureUnit.toString().split('.').last.toUpperCase(),
                  ['CELSIUS', 'FAHRENHEIT'],
                  (value) {
                    final unit = value == 'CELSIUS' 
                        ? TemperatureUnit.celsius 
                        : TemperatureUnit.fahrenheit;
                    settingsProvider.updateTemperatureUnit(unit);
                  },
                ),
                const SizedBox(height: 16),
                
                // Wind Speed Unit
                _buildUnitDropdown(
                  'Wind Speed',
                  Icons.air,
                  settingsProvider.windSpeedUnit.toString().split('.').last.toUpperCase(),
                  ['MS', 'KMH', 'MPH'],
                  (value) {
                    WindSpeedUnit unit;
                    switch (value) {
                      case 'MS':
                        unit = WindSpeedUnit.ms;
                        break;
                      case 'KMH':
                        unit = WindSpeedUnit.kmh;
                        break;
                      case 'MPH':
                        unit = WindSpeedUnit.mph;
                        break;
                      default:
                        unit = WindSpeedUnit.ms;
                    }
                    settingsProvider.updateWindSpeedUnit(unit);
                  },
                ),
                const SizedBox(height: 16),
                
                // Pressure Unit
                _buildUnitDropdown(
                  'Pressure',
                  Icons.compress,
                  settingsProvider.pressureUnit.toString().split('.').last.toUpperCase(),
                  ['HPA', 'ATM', 'PSI'],
                  (value) {
                    PressureUnit unit;
                    switch (value) {
                      case 'HPA':
                        unit = PressureUnit.hpa;
                        break;
                      case 'ATM':
                        unit = PressureUnit.atm;
                        break;
                      case 'PSI':
                        unit = PressureUnit.psi;
                        break;
                      default:
                        unit = PressureUnit.hpa;
                    }
                    settingsProvider.updatePressureUnit(unit);
                  },
                ),
                const SizedBox(height: 16),
                
                // Radiation Unit
                _buildUnitDropdown(
                  'Solar Radiation',
                  Icons.wb_sunny,
                  settingsProvider.radiationUnit.toString().split('.').last.toUpperCase(),
                  ['KWHM2', 'WM2', 'MWCM2'],
                  (value) {
                    RadiationUnit unit;
                    switch (value) {
                      case 'KWHM2':
                        unit = RadiationUnit.kwhm2;
                        break;
                      case 'WM2':
                        unit = RadiationUnit.wm2;
                        break;
                      case 'MWCM2':
                        unit = RadiationUnit.mwcm2;
                        break;
                      default:
                        unit = RadiationUnit.kwhm2;
                    }
                    settingsProvider.updateRadiationUnit(unit);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnitDropdown(
    String label,
    IconData icon,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: currentValue,
            underline: const SizedBox(),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  _formatUnitLabel(option),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  String _formatUnitLabel(String unit) {
    switch (unit) {
      case 'CELSIUS':
        return '°C';
      case 'FAHRENHEIT':
        return '°F';
      case 'MS':
        return 'm/s';
      case 'KMH':
        return 'km/h';
      case 'MPH':
        return 'mph';
      case 'HPA':
        return 'hPa';
      case 'ATM':
        return 'atm';
      case 'PSI':
        return 'psi';
      case 'KWHM2':
        return 'kWh/m²';
      case 'WM2':
        return 'W/m²';
      case 'MWCM2':
        return 'mW/cm²';
      default:
        return unit;
    }
  }

  void _addThreshold() async {
    if (_formKey.currentState!.validate()) {
      final value = double.parse(_thresholdController.text);
      final description = _descriptionController.text.trim();
      
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.addThreshold(value, description);
      
      // Clear form
      _thresholdController.clear();
      _descriptionController.clear();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Threshold "$description" added successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _removeThreshold(int index) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final threshold = settingsProvider.customThresholds[index];
    
    await settingsProvider.removeThreshold(index);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete, color: Colors.white),
              const SizedBox(width: 8),
              Text('Threshold "${threshold.description}" removed'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}