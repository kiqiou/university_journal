import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/screens/admin_1/views/admin_1_home_screen.dart';
import 'package:university_journal/screens/admin_2/views/admin_2_home_screen.dart';
import 'package:university_journal/screens/auth/views/sign_in_screen.dart';
import 'package:university_journal/screens/auth/views/sign_up_screen.dart';
import 'package:university_journal/screens/dean/view/main_screen.dart';
import 'package:university_journal/screens/student/view/main_screen.dart';
import 'package:university_journal/screens/teacher/views/main_screen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthenticationStatus.authenticated:
            final role = state.user?.role ?? '';
            switch (role) {
              case 'Администратор 1':
                return const Admin1MainScreen();
              case 'Администратор 2':
                return const Admin2MainScreen();
              case 'Декан':
                return const DeanMainScreen();
              case 'Преподаватель':
                return const TeacherMainScreen();
              case 'Студент':
                return const StudentMainScreen();
              default:
                return  SignInScreen();
            }
          case AuthenticationStatus.unauthenticated:
            return SignInScreen(errorMessage: state.error);
          case AuthenticationStatus.unknown:
            return SignInScreen();
        }
      },
    );
  }
}

