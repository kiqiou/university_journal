import 'package:flutter/material.dart';
import 'package:university_journal/screens/admin_1/home_sreen/views/admin_1_home_screen.dart';
import 'package:university_journal/screens/teacher/home_screen/view/home_screen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

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
      home: TeacherHomeScreen(),
    );
  }
}
