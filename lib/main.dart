import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/simple_bloc_observer.dart';
import 'app.dart';
import 'bloc/auth/authentication_bloc.dart';
import 'bloc/services/user/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  final authRepository = UserRepository();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Bloc.observer = SimpleBlocObserver();
  runApp(RepositoryProvider.value(
    value: authRepository,
    child: BlocProvider(
      create: (_) => AuthenticationBloc(userRepository: authRepository),
      child: const MyApp(),
    ),
  ),);
}


