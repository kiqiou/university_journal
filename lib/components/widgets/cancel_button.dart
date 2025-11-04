import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../colors/colors.dart';

class CancelButton extends StatelessWidget{
  final VoidCallback onPressed;
  const CancelButton({super.key, required this.onPressed,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: MyColors.blueJournal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.close, size: 28, color: Colors.white),
        splashRadius: 24,
        onPressed: onPressed,
      ),
    );
  }
}