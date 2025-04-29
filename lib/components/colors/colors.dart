import 'package:flutter/material.dart';

class MyColors{

      static const int _blueJurnalPrimaryValue = 0xFF4068EA;
  static const MaterialAccentColor blueJournal = MaterialAccentColor(
    _blueJurnalPrimaryValue,
    <int, Color>{
      100: Color(0xFF4068EA),
    },
  );
  static const int _greyJurnalPrimaryValue = 0xFF696A6E;
  static const MaterialAccentColor greyJournal = MaterialAccentColor(
    _greyJurnalPrimaryValue,
    <int, Color>{
      100: Color(0xFF696A6E),
    },
  );
}