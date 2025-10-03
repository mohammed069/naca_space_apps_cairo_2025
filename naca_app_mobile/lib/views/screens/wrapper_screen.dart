// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:naca_app_mobile/views/screens/coordinates_screen.dart';
import 'package:naca_app_mobile/views/screens/home_screen.dart';
import 'package:naca_app_mobile/views/screens/open_map_screen.dart';
import 'package:naca_app_mobile/views/screens/search_by_city.dart';
import '../../core/app_colors.dart';

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchByCityScreen(),
    const OpenMapScreen(),
    const CoordinatesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        height: 65,
        backgroundColor: Colors.transparent,
        color: AppColors.primaryDark.withOpacity(0.9),
        buttonBackgroundColor: AppColors.primary,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 600),
        items: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.home_rounded,
              size: 26,
              color: _currentIndex == 0 ? Colors.white : AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.location_city_rounded,
              size: 26,
              color: _currentIndex == 1 ? Colors.white : AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.map_rounded,
              size: 26,
              color: _currentIndex == 2 ? Colors.white : AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.gps_fixed_rounded,
              size: 26,
              color: _currentIndex == 3 ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

