import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/screens/auth/bloc/sign_in/sign_in_bloc.dart';
import 'package:university_journal/screens/auth/view/welcome_screen.dart';
import 'package:university_journal/screens/home_screen/view/home_screen.dart';

import 'bloc/auth/authentication_bloc.dart';

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
      home: MyHomePage(),
    );
  }
}
