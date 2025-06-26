import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../bloc/journal/journal.dart';

class ThemeTable extends StatefulWidget {
  final List<Session> sessions;
  final VoidCallback onTopicChanged;
  final bool isEditable;
  final Future<bool> Function(
      int sessionId, String? date, String? type, String? topic)? onUpdate;

  const ThemeTable(
      {super.key,
      required this.sessions,
      this.onUpdate,
      required this.isEditable,
      required this.onTopicChanged});

  @override
  State<ThemeTable> createState() => _ThemeTableState();
}

class _ThemeTableState extends State<ThemeTable> {
  Timer? _debounce;

  List<Session> getUniqueSessions(List<Session> sessions) {
    final seenIds = <int>{};
    final unique = <Session>[];

    for (final s in sessions) {
      if (!seenIds.contains(s.id)) {
        seenIds.add(s.id);
        unique.add(s);
      }
    }
    return unique;
  }

  List<Session> sortSessionsByDate(List<Session> sessions) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    sessions.sort((a, b) {
      try {
        final dateA = dateFormat.parse(a.date);
        final dateB = dateFormat.parse(b.date);
        return dateA.compareTo(dateB);
      } catch (e) {
        return a.date.compareTo(b.date);
      }
    });

    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    final sessions = getUniqueSessions(widget.sessions);
    final sortedSessions = sortSessionsByDate(sessions);
    return Scaffold(
      appBar:
          AppBar(title: const Text('Темы'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(4),
            2: FlexColumnWidth(2),
          },
          border: TableBorder.all(
            color: Colors.grey.withOpacity(0.25),
            width: 1.0,
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Дата',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Тема',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Вид занятия',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            ...sortedSessions.map((session) {
              final topicController =
                  TextEditingController(text: session.topic ?? '');
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        session.date,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                        enabled: widget.isEditable,
                        controller: topicController,
                        decoration: InputDecoration.collapsed(
                            hintText: 'Введите тему',
                            hintStyle: TextStyle(color: Colors.grey.shade300)),
                        onChanged: (newTopic) {
                          // Отменяем предыдущий таймер
                          if (_debounce?.isActive ?? false) _debounce!.cancel();

                          // Первый таймер отслеживает остановку ввода (например, 1000 мс)
                          _debounce =
                              Timer(const Duration(milliseconds: 1000), () {
                            // Второй таймер – дополнительная задержка перед действием (например, 2000 мс)
                            Future.delayed(const Duration(milliseconds: 2000),
                                () async {
                              if (widget.onUpdate != null) {
                                final success = await widget.onUpdate!(
                                    session.id, null, null, newTopic);
                                if (success) {
                                  widget.onTopicChanged();
                                  log('обновление вызвано');
                                }
                              }
                            });
                          });
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        session.sessionType,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
