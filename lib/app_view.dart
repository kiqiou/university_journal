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
          primary: Color.fromRGBO(255, 158, 0, 1),
          onPrimary: Colors.white,
        ),
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: ((context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return BlocProvider(
              create: (context) => SignInBloc(
                  context.read<AuthenticationBloc>().userRepository
              ),
              child: const MyHomePage(),
            );
          } else {
            return WelcomeScreen();
          }
        }),
      ),
    );
  }
}
