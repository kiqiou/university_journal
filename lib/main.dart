import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:university_journal/simple_bloc_observer.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Используем готовую конфигурацию
  );
  Bloc.observer = SimpleBlocObserver();
}
