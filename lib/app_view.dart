import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/screens/admin_1/home_sreen/views/admin_1_home_screen.dart';
import 'package:university_journal/screens/admin_2/home_screen/admin_2_home_screen.dart';
import 'package:university_journal/screens/auth/view/sign_up_screen.dart';
import 'package:university_journal/screens/dekan/home_screen/dekan_home_screen.dart';
import 'package:university_journal/screens/student/home_screen/studenr_home_screen.dart';
import 'package:university_journal/screens/teacher/home_screen/view/home_screen.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        print('➡️ Обновление состояния: ${state.status}');
        Widget? nextScreen;

        if (state.status == AuthenticationStatus.authenticated) {
          final role = state.user?.role ?? '';
          print('🔐 Пользователь с ролью: $role');
          switch (role) {
            case 'Администратор 1':
              nextScreen = const Admin1HomeScreen();
              break;
            case 'Администратор 2':
              nextScreen = const Admin2HomeScreen();
              break;
            case 'Декан':
              nextScreen = const DekanHomeScreen();
              break;
            case 'Преподаватель':
              nextScreen = const TeacherHomeScreen();
              break;
            case 'Студент':
              nextScreen = const StudentHomeScreen();
              break;
            default:
              nextScreen = const WelcomeScreen();
              break;
          }
        } else if (state.status == AuthenticationStatus.unauthenticated) {
          nextScreen = const WelcomeScreen();
        }

        if (nextScreen != null) {
          print('🔄 Переход на: ${nextScreen.runtimeType}');
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

