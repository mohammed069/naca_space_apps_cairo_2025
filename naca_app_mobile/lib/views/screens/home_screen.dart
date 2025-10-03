// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:naca_app_mobile/views/widgets/containr_widget.dart';
import '../../core/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isHourly = true;
  Color backgroundColor = Colors.white24;

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
        child: Column(
          children: [
            // Weather info section at top
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: const Column(
                children: [
                  Text(
                    'Montreal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '19°',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Mostly Clear',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'H:24° L:18°',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded section with Stack
            Expanded(
              child: Stack(
                children: [
                  // Centered house image
                  const Center(
                    child: Image(image: AssetImage('assets/image/house.png')),
                  ),

                  // Bottom container above navigation bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 280,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isHourly ? Colors.white24 : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isHourly = true;
                                    backgroundColor = Colors.white24;
                                  });
                                },
                                child: Text('Hourly'),
                              ),
                              Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isHourly
                                      ? Colors.black
                                      : Colors.white24,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isHourly = false;
                                    backgroundColor = Colors.black;
                                  });
                                },
                                child: Text('Weekly'),
                              ),
                              SizedBox(width: 20),
                            ],
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ContainerWidget(),
                                SizedBox(width: 16),
                                ContainerWidget(),
                                SizedBox(width: 16),
                                ContainerWidget(),
                                SizedBox(width: 16),
                                ContainerWidget(),
                                SizedBox(width: 16),
                                ContainerWidget(),
                                SizedBox(width: 16),
                                ContainerWidget(),
                                SizedBox(width: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
