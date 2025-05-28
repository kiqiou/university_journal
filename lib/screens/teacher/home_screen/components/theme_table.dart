import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../bloc/journal/journal.dart';

class ThemeTable extends StatefulWidget {
  final List<Session> sessions;
  final Future<bool> Function(int sessionId, String? date, String? type, String? topic)? onUpdate;

  const ThemeTable({super.key, required this.sessions, this.onUpdate});

  @override
  State<ThemeTable> createState() => _ThemeTableState();
}

class _ThemeTableState extends State<ThemeTable> {

  List<Session> getUniqueSessions(List<Session> sessions) {
    final seenIds = <int>{};
    final unique = <Session>[];

    for (final s in sessions) {
      if (!seenIds.contains(s.sessionId)) {
        seenIds.add(s.sessionId);
        unique.add(s);
      }
    }
    return unique;
  }

  @override
  Widget build(BuildContext context) {
    final sessions = getUniqueSessions(widget.sessions);
    return Scaffold(
      appBar: AppBar(title: const Text('Темы'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(4),
            2: FlexColumnWidth(2),
          },
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Дата',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Тема',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Вид занятия',
                  ),
                ),
              ],
            ),
            ...sessions.map((session) {
              final topicController = TextEditingController(text: session.topic ?? '');
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(session.date),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: topicController,
                      decoration: InputDecoration.collapsed(
                          hintText: 'Введите тему', hintStyle: TextStyle(color: Colors.grey.shade300)),
                      onChanged: (newTopic) async {
                        if (widget.onUpdate != null) {
                          final success = await widget.onUpdate!(session.sessionId, null, null, newTopic,);
                          if (success) {
                            log('обновление вызвано');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Тема обновлена')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(session.sessionType),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
