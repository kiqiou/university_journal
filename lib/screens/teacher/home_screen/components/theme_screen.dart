import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeScreen extends StatefulWidget{
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Тема'),
    );
  }
}