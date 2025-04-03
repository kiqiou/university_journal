import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final double borderRadius;
  final IconData icon;
  final double size;
  final double width;
  final double height;
  Color? containerColor;

  IconContainer(
      {super.key,
      this.borderRadius = 15.0,
      required this.icon,
      this.size = 20,
      this.height = 50,
      this.width = 50,
      this.containerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: containerColor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.grey.shade600,
          size: size,
        ),
      ),
    );
  }
}
