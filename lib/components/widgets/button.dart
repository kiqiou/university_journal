import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../colors/colors.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onChange;
  final String buttonName;

  const MyButton({super.key, required this.onChange, required this.buttonName});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            onChange();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.blueJournal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            buttonName,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
