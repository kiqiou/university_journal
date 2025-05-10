import 'package:flutter/material.dart';

class MyColors{

      static const int _blueJournalPrimaryValue = 0xFF4068EA;
  static const MaterialAccentColor blueJournal = MaterialAccentColor(
    _blueJournalPrimaryValue,
    <int, Color>{
      100: Color(0xFF4068EA),
    },
  );
  static const int _greyJournalPrimaryValue = 0xFF696A6E;
  static const MaterialAccentColor greyJournal = MaterialAccentColor(
    _greyJournalPrimaryValue,
    <int, Color>{
      100: Color(0xFF696A6E),
    },
  );
}