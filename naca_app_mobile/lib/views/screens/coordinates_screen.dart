import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../widgets/custom_form_widgets.dart';

class CoordinatesScreen extends StatefulWidget {
  const CoordinatesScreen({super.key});

  @override
  State<CoordinatesScreen> createState() => _CoordinatesScreenState();
}

class _CoordinatesScreenState extends State<CoordinatesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  
  DateTime? _selectedDate;

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String? _validateCoordinate(String? value, String coordinateType) {
    if (value == null || value.trim().isEmpty) {
      return '$coordinateType is required';
    }
    
    final double? coordinate = double.tryParse(value.trim());
    if (coordinate == null) {
      return 'Please enter a valid numeric value';
    }
    
    if (coordinateType == 'Latitude') {
      if (coordinate < -90 || coordinate > 90) {
        return 'Latitude must be between -90 and 90';
      }
    } else if (coordinateType == 'Longitude') {
      if (coordinate < -180 || coordinate > 180) {
        return 'Longitude must be between -180 and 180';
      }
    }
    
    return null;
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
      // Placeholder action - does nothing for now
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordinates form submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      appBar: AppBar(
        title: const Text(
          'Coordinates',
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
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
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
                  
                  // Latitude Field
                  CustomTextFormField(
                    controller: _latitudeController,
                    labelText: 'Latitude',
                    hintText: 'Enter latitude (-90 to 90)',
                    prefixIcon: Icons.my_location,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?[0-9]*\.?[0-9]*$'),
                      ),
                    ],
                    validator: (value) => _validateCoordinate(value, 'Latitude'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Longitude Field
                  CustomTextFormField(
                    controller: _longitudeController,
                    labelText: 'Longitude',
                    hintText: 'Enter longitude (-180 to 180)',
                    prefixIcon: Icons.place,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?[0-9]*\.?[0-9]*$'),
                      ),
                    ],
                    validator: (value) => _validateCoordinate(value, 'Longitude'),
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
                    icon: Icons.gps_fixed,
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