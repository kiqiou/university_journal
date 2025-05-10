import 'package:flutter/material.dart';

class DekanHomeScreen extends StatefulWidget {
  const DekanHomeScreen({super.key});

  @override
  State<DekanHomeScreen> createState() => _DekanHomeScreenState();
}

class _DekanHomeScreenState extends State<DekanHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                // Expanded(
                //   child: JournalTable(),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  }