import 'package:flutter/material.dart';

class MenuArrow extends StatelessWidget{
  final VoidCallback onTap;
  final double top;
  final double left;
  const MenuArrow({super.key, required this.onTap, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(blurRadius: 4, color: Colors.black26)
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey.shade500,
            size: 20,
          ),
        ),
      ),
    );
  }

}