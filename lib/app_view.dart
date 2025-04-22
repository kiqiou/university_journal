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
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final roles = state.user?.roles ?? [];
        final cleanedRoles = roles.map((r) => r.trim()).toList();

        Widget? nextScreen;

        if (state.status == AuthenticationStatus.authenticated) {
          if (cleanedRoles.contains('Администратор 1')) {
            nextScreen = const Admin1HomeScreen();
          } else if (cleanedRoles.contains('Администратор 2')) {
            nextScreen = const Admin2HomeScreen();
          } else if (cleanedRoles.contains('Декан')) {
            nextScreen = const DekanHomeScreen();
          } else if (cleanedRoles.contains('Преподаватель')) {
            print('teacherscreen');
            nextScreen = const TeacherHomeScreen();
          } else if (cleanedRoles.contains('Студент')) {
            nextScreen = const StudentHomeScreen();
          }
        }

        if (nextScreen != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => nextScreen!),
                (_) => false,
          );
        }
      },
      child: const WelcomeScreen(),
    );
  }
}
