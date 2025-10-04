
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../widgets/custom_form_widgets.dart';
import 'fast_weather_result_screen.dart';

class OpenMapScreen extends StatefulWidget {
  const OpenMapScreen({super.key});

  @override
  State<OpenMapScreen> createState() => _OpenMapScreenState();
}

class _OpenMapScreenState extends State<OpenMapScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  LatLng? selectedLocation;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyyMMdd').format(picked);
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location on the map'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to weather result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FastWeatherResultScreen(
            latitude: selectedLocation!.latitude,
            longitude: selectedLocation!.longitude,
            date: _selectedDate!,
            parameters: const [
              'T2M',
              'RH2M', 
              'WS2M',
              'PRECTOTCORR',
              'ALLSKY_SFC_SW_DWN'
            ],
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Map'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  
                  // Header Section
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Choose Location on Map',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select a location and date to get weather data',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Map Selection Button
                  CustomElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MapPickerScreen(
                            onLocationSelected: (location) {
                              setState(() {
                                selectedLocation = location;
                              });
                              debugPrint('Location selected: ${location.latitude}, ${location.longitude}');
                            },
                          ),
                        ),
                      );
                    },
                    text: 'Open Map',
                    icon: Icons.map,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Selected Location Display
                  if (selectedLocation != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.iconAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Selected Location:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Latitude: ${selectedLocation!.latitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Longitude: ${selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Date Selection Field
                  CustomTextFormField(
                    controller: _dateController,
                    labelText: 'Select Date',
                    hintText: 'Tap to select date',
                    prefixIcon: Icons.calendar_today,
                    suffixIcon: Icons.date_range,
                    onSuffixIconPressed: _selectDate,
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Date is required';
                      }
                      return null;
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Submit Button
                  CustomElevatedButton(
                    onPressed: _onSubmit,
                    text: 'Submit',
                    icon: Icons.send,
                    width: double.infinity,
                    height: 56,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  
  const MapPickerScreen({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? selectedPoint;
  
  // Default location (Cairo, Egypt)
  static const LatLng defaultLocation = LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (selectedPoint != null)
            IconButton(
              onPressed: () {
                widget.onLocationSelected(selectedPoint!);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              tooltip: 'Confirm Location',
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: defaultLocation,
          initialZoom: 10.0,
          onTap: (tapPosition, point) {
            setState(() {
              selectedPoint = point;
            });
            debugPrint('Location clicked: ${point.latitude}, ${point.longitude}');
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.naca_app_mobile',
            maxNativeZoom: 19,
          ),
          if (selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedPoint!,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_pin,
                    color: AppColors.error,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: selectedPoint != null
          ? FloatingActionButton.extended(
              onPressed: () {
                widget.onLocationSelected(selectedPoint!);
                Navigator.of(context).pop();
              },
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.textPrimary,
              label: const Text('Confirm Location'),
              icon: const Icon(Icons.check),
            )
          : null,
      bottomSheet: selectedPoint != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlayBackground,
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.iconAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الموقع المحدد:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Latitude: ${selectedPoint!.latitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Longitude: ${selectedPoint!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}