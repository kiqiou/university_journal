import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../colors/colors.dart';

class MyButton extends StatelessWidget{
  final VoidCallback onChange;
  final String buttonName;
  const MyButton({super.key, required this.onChange, required this.buttonName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, right: 20.0),
      child: Align(
        alignment:
        Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {onChange();},
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            MyColors.blueJournal,
            padding:
            EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 23),
            textStyle:
            TextStyle(fontSize: 18),
            minimumSize: Size(170, 50),
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                  10),
            ),
          ),
          child: Text(
            buttonName,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

}