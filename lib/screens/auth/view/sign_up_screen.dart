import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_journal/bloc/auth/authentication_bloc.dart';
import 'package:university_journal/bloc/user/authentication_user.dart';
import 'package:university_journal/screens/auth/view/sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
            TextFormField(
              decoration: InputDecoration(labelText: 'Айди роли'),
              controller: _roleIdController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите айди';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthenticationBloc>().add(
                    AuthenticationRegisterRequested(
                      username: _usernameController.text,
                      password: _passwordController.text,
                      roleId: int.parse(_roleIdController.text),
                    )
                  );
                }
              },
              child: Text('Зарегистрироваться'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(),
                  ),
                );
              },
              child: Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
