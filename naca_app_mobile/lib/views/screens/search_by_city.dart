import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../widgets/custom_form_widgets.dart';
import 'package:naca_app_mobile/views/screens/fast_weather_result_screen.dart';

class SearchByCityScreen extends StatefulWidget {
  const SearchByCityScreen({super.key});

  @override
  State<SearchByCityScreen> createState() => _SearchByCityScreenState();
}

class _SearchByCityScreenState extends State<SearchByCityScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _cityController.dispose();
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

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final locations = await locationFromAddress(
          _cityController.text.trim(),
        );
        if (locations.isNotEmpty) {
          final loc = locations.first;

          // Navigate to weather result screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FastWeatherResultScreen(
                latitude: loc.latitude,
                longitude: loc.longitude,
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No location found for this city.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Search by City',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
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

                  // City Search Field
                  CustomTextFormField(
                    controller: _cityController,
                    labelText: 'City/Place Name',
                    hintText: 'Enter city or place name',
                    prefixIcon: Icons.location_city,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'City name is required';
                      }
                      return null;
                    },
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
                    icon: Icons.search,
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
