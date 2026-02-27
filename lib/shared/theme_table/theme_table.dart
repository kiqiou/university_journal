import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../bloc/services/journal/models/session.dart';

class ThemeTable extends StatefulWidget {
  final List<Session> sessions;
  final VoidCallback? onTopicChanged;
  final Future<void> Function(int sessionId, String topic)? onUpdate;
  final bool isEditable;
  final bool isGroupSplit;

  const ThemeTable(
      {super.key,
      required this.sessions,
      required this.isEditable,
      this.onTopicChanged,
      required this.isGroupSplit,
      this.onUpdate});

  @override
  State<ThemeTable> createState() => _ThemeTableState();
}

class _ThemeTableState extends State<ThemeTable> {
  final Map<int, TextEditingController> _controllers = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    for (final session in widget.sessions) {
      _controllers[session.id] = TextEditingController(text: session.topic ?? '');
    }
  }

  @override
  void didUpdateWidget(covariant ThemeTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (final session in widget.sessions) {
      final existing = _controllers[session.id];
      if (existing == null) {
        _controllers[session.id] =
            TextEditingController(text: session.topic ?? '');
      } else if (existing.text != (session.topic ?? '')) {
        existing.text = session.topic ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

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
            3: FlexColumnWidth(1),
          },
          border: TableBorder.all(
            color: Colors.grey.withOpacity(0.25),
            width: 1.0,
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: widget.isGroupSplit
                  ? [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('Дата', textAlign: TextAlign.center)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('Тема', textAlign: TextAlign.center)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('Вид занятия',
                                textAlign: TextAlign.center)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child:
                                Text('Подгруппа', textAlign: TextAlign.center)),
                      ),
                    ]
                  : [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('Дата', textAlign: TextAlign.center)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('Тема', textAlign: TextAlign.center)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('Вид занятия',
                                textAlign: TextAlign.center)),
                      ),
                    ],
            ),
            ...sortedSessions.map((session) {
              final topicController = _controllers[session.id]!;
              final rowChildren = [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(session.date, textAlign: TextAlign.center)),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    enabled: widget.isEditable,
                    controller: topicController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Введите тему',
                      hintStyle: TextStyle(color: Colors.grey.shade300),
                    ),
                    onChanged: (newTopic) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        Future.delayed(const Duration(milliseconds: 2000),
                            () async {
                          if (widget.onUpdate != null) {
                            await widget.onUpdate!(session.id, newTopic);
                            log('обновление вызвано');
                          }
                        });
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(session.type, textAlign: TextAlign.center)),
                ),
              ];

              if (widget.isGroupSplit) {
                rowChildren.add(
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        session.subGroup != null
                            ? session.subGroup.toString()
                            : 'Общее',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              return TableRow(children: rowChildren);
            }),
          ],
        ),
      ),
    );
  }
}
