// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:naca_app_mobile/core/app_colors.dart';

class ContainerWidget extends StatefulWidget {
  const ContainerWidget({super.key});

  @override
  State<ContainerWidget> createState() => _ContainerWidgetState();
}

class _ContainerWidgetState extends State<ContainerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 83, 81, 159).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.paletteColor3.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      
      child: Column(
        children: [
          Text('12 AM'),
          Spacer(),
          Icon(Icons.wb_sunny),
          Spacer(),
          Text('20°'),
        ],
      ),
    );
  }
}