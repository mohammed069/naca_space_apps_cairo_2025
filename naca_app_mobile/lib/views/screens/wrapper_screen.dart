// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:naca_app_mobile/views/screens/coordinates_screen.dart';
import 'package:naca_app_mobile/views/screens/home_screen.dart';
import 'package:naca_app_mobile/views/screens/open_map_screen.dart';
import 'package:naca_app_mobile/views/screens/search_by_city.dart';
import '../../core/app_colors.dart';
// Import screens (create these files if they don't exist)
// import 'home_screen.dart';
// import 'search_by_city_screen.dart';
// import 'open_map_screen.dart';
// import 'coordinates_screen.dart';

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  int _currentIndex = 0;

  // Placeholder widgets - replace with actual screens when available
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
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.textAccent,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_city_rounded),
                activeIcon: Icon(Icons.location_city_rounded),
                label: 'City',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded),
                activeIcon: Icon(Icons.map_rounded),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.gps_fixed_rounded),
                activeIcon: Icon(Icons.gps_fixed_rounded),
                label: 'Coordinates',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

