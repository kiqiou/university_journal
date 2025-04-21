import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/screens/admin_1/home_sreen/views/admin_1_home_screen.dart';
import 'package:university_journal/screens/admin_2/home_screen/admin_2_home_screen.dart';
import 'package:university_journal/screens/auth/view/sign_up_screen.dart';
import 'package:university_journal/screens/dekan/home_screen/dekan_home_screen.dart';
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
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: ((context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            if (state.user?.roles.contains('Администратор 1') == true) {
              return BlocProvider(
                create: (context) => context.read<AuthenticationBloc>(),
                child: const Admin1HomeScreen(),
              );
            } else if (state.user?.roles.contains('Администратор 2') == true) {
              return BlocProvider(
                create: (context) => context.read<AuthenticationBloc>(),
                child: const Admin2HomeScreen(),
              );
            } else if (state.user?.roles.contains('Декан') == true) {
              return BlocProvider(
                create: (context) => context.read<AuthenticationBloc>(),
                child: const DekanHomeScreen(),
              );
            } else if (state.user?.roles.contains('Преподаватель') == true) {
              return BlocProvider(
                create: (context) => context.read<AuthenticationBloc>(),
                child: const TeacherHomeScreen(),
              );
            } else if (state.user?.roles.contains('Студент') == true) {
              return BlocProvider(
                create: (context) => context.read<AuthenticationBloc>(),
                child: const Admin2HomeScreen(),
              );
            } else {
              // 🔒 Return a default screen if no roles matched
              return const WelcomeScreen();
            }
          } else {
            return const WelcomeScreen();
          }
        }),
      ),
    );
  }
}
