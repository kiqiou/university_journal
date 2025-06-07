import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/simple_bloc_observer.dart';
import 'app.dart';
import 'bloc/auth/authentication_bloc.dart';
import 'bloc/user/user_repository.dart';

void main() async {
  final authRepository = UserRepository();
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  runApp(RepositoryProvider.value(
    value: authRepository,
    child: BlocProvider(
      create: (_) => AuthenticationBloc(userRepository: authRepository),
      child: const MyApp(),
    ),
  ),);
}


