import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/simple_bloc_observer.dart';
import 'app.dart';
import 'bloc/auth/authentication_bloc.dart';
import 'bloc/user/authentication_user.dart';

void main() async {
  final authRepository = AuthRepository();
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  runApp(RepositoryProvider.value(
    value: authRepository,
    child: BlocProvider(
      create: (_) => AuthenticationBloc(authRepository: authRepository),
      child: const MyApp(),
    ),
  ),);
}


