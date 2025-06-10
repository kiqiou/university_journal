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
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          displayMedium: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          displaySmall: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          headlineMedium: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          headlineSmall: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          titleLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          titleMedium: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          titleSmall: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          bodyLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          bodyMedium: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          bodySmall: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          labelLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          labelMedium: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          labelSmall: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: Colors.indigo,
          onPrimary: Colors.white,
        ),
      ),
      home: Builder(
        builder: (context) => const AppView(),
      ),
    );
  }
}
