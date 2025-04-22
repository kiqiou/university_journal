import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Журнал МИТСО',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black87,
          primary: Colors.indigo,
          onPrimary: Colors.white,
        ),
      ),
      home: const AppView(), // теперь AppView — не MaterialApp, а просто экран
    );
  }
}