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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.w900,),
          bodyMedium: TextStyle(fontWeight: FontWeight.w900),
          bodySmall: TextStyle(fontWeight: FontWeight.w900,),

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
