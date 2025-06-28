import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/screens/admin_1/views/admin_1_home_screen.dart';
import 'package:university_journal/screens/admin_2/views/admin_2_home_screen.dart';
import 'package:university_journal/screens/auth/views/sign_up_screen.dart';
import 'package:university_journal/screens/dekan/view/main_screen.dart';
import 'package:university_journal/screens/student/view/main_screen.dart';
import 'package:university_journal/screens/teacher/views/main_screen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        log('➡️ Обновление состояния: ${state.status}');
        log('🔐 Пользователь с ролью: ${state.user?.role ?? 'Не определено'}');
        Widget? nextScreen;

        if (state.status == AuthenticationStatus.authenticated) {
          final role = state.user?.role ?? '';
          log('🔐 Пользователь с ролью: $role');
          switch (role) {
            case 'Администратор 1':
              nextScreen = const Admin1MainScreen();
              break;
            case 'Администратор 2':
              nextScreen = const Admin2MainScreen();
              break;
            case 'Декан':
              nextScreen = const DeanMainScreen();
              break;
            case 'Преподаватель':
              nextScreen = const TeacherMainScreen();
              break;
            case 'Студент':
              nextScreen = const StudentMainScreen();
              break;
            default:
              nextScreen = const WelcomeScreen();
              break;
          }
        } else if (state.status == AuthenticationStatus.unauthenticated) {
          nextScreen = const WelcomeScreen();
        }

        if (nextScreen != null) {
          log('🔄 Переход на: ${nextScreen.runtimeType}');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => nextScreen!),
            );
          });
        }
        return WelcomeScreen();
      },
    );
  }
}

