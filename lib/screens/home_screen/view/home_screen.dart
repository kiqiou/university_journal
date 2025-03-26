import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:university_journal/screens/home_screen/view/table.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DataTableScreen(),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
