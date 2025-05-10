import 'package:flutter/material.dart';

class MyIconContainer extends StatelessWidget {
  final double borderRadius;
  final IconData icon;
  final double size;
  final double width;
  final double height;
  Color? containerColor;
  bool? withText;
  String? text;

  MyIconContainer({
    super.key,
    this.borderRadius = 15.0,
    required this.icon,
    this.size = 20,
    this.height = 50,
    this.width = 50,
    this.containerColor,
    this.withText = false,
    this.text,
  });

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
      child: withText!
          ? Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox( width: 8,),
                  Icon(
                    icon,
                    color: Colors.grey.shade600,
                    size: size,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
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