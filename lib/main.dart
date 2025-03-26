import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:university_journal/simple_bloc_observer.dart';

import 'app.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
}
