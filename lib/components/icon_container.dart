import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {

  final double borderRadius;
  final IconData icon;

  const IconContainer({super.key, this.borderRadius = 15.0, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
          child: Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
      ),);
  }
}
