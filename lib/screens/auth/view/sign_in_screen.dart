import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Имя'),
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите имя';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Пароль'),
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Пароль должен быть минимум 6 символов';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthenticationBloc>().add(
                    AuthenticationLoginRequested(
                      username: _usernameController.text,
                      password: _passwordController.text,
                    ),
                  );
                }
              },
              child: Text('Войти', style: TextStyle(color: Colors.grey.shade800, fontFamily: 'Montserrat', fontWeight: FontWeight.w600,)),
            ),
          ],
        ),
      ),
    );
  }
}