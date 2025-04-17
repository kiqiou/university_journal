import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final double borderRadius;
  final IconData icon;
  final double size;
  final double width;
  final double height;
  final Color? containerColor;
  final bool withText;
  final String? text;
  final Color borderColor;

  IconContainer({
    super.key,
    this.borderRadius = 15.0,
    required this.icon,
    this.size = 20,
    this.height = 50,
    this.width = 50,
    this.containerColor,
    this.withText = false,
    this.text,
    this.borderColor = const Color(0xFFB0B0B0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: containerColor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: withText
          ? Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: size,
            ),
            const SizedBox(width: 8),
            Text(
              text ?? '',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : Center(
        child: Icon(
          icon,
          color: Colors.grey.shade600,
          size: size,
        ),
      ),
    );
  }
}