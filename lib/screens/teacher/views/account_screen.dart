import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth/authentication_bloc.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Левая часть с биографией и дисциплинами
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Преподаватель', style: TextStyle(fontSize: 23, color: Colors.black87), ),
                        SizedBox(
                          height: 60,
                        ),
                        const Text(
                          'Краткая биография',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.user!.bio.toString(),
                          style: const TextStyle(fontSize: 17, color: Colors.black87),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Основные дисциплины',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        ...state.user!.disciplines.map((course) => _buildDisciplineItem(course.name)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120,
                      ),
                      Container(
                        width: 300,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: state.user!.photoUrl != null
                              ? Image.network(state.user!.photoUrl!)
                              : Icon(
                                  Icons.person_outline,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ФИО преподавателя',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.user!.username.toString(),
                        style: TextStyle(fontSize: 17, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Пасада',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.user!.position.toString(),
                        style: const TextStyle(fontSize: 17, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Адрес университета',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ул. Казинца, д. 21, к.3 220099 г. Минск',
                        style: TextStyle(fontSize: 17, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDisciplineItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Text(
            '- ',
            style: TextStyle(
              fontSize: 17,
                color: Colors.black87
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                  color: Colors.black87
              ),
            ),
          ),
        ],
      ),
    );
  }
}
