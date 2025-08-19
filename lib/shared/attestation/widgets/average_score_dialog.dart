import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../bloc/services/attestation/model/attestation.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../components/widgets/multiselect.dart';

Future<void> showAverageScoreDialog(
    BuildContext context,
    List<Attestation> attestations,
    List<Session> sessions,
    Function(int, double?, String?) onUpdate,
    ) async {
  final types = ['Лекция', 'Практика', 'Лабораторная', 'Семинар'];

  final selectedTypes = await showDialog<List<String>>(
    context: context,
    builder: (context) => MultiSelectDialog<String>(
      items: types,
      initiallySelected: [],
      itemLabel: (type) => type,
    ),
  );

  if (selectedTypes == null) return; // пользователь отменил

  final students = sessions.map((s) => s.student).toSet().toList();

  calculateAverageScore(
    context: context,
    selectedTypes: selectedTypes,
    allSessions: sessions,
    students: students,
    onUpdate: onUpdate,
    attestations: attestations,
  );
}


void calculateAverageScore({
  required BuildContext context,
  required List<String> selectedTypes,
  required List<Session> allSessions,
  required List<MyUser> students,
  required List<Attestation> attestations,
  required Function(int, double?, String?) onUpdate,
}) {
  // Если типы не выбраны — считаем по всем
  final useTypes = selectedTypes.isEmpty
      ? <String>{'Лекция', 'Практика', 'Лабораторная', 'Семинар'}
      : selectedTypes.toSet();

  // Карта студент.id -> attestation.id
  final studentToAttestationId = {
    for (var attestation in attestations) attestation.student.id: attestation.id
  };

  print('DEBUG allSessions=${allSessions.length} '
      'attestations=${attestations.length} '
      'useTypes=$useTypes');

  print('Вызов onUpdate');

  for (final student in students) {
    print('DEBUG студент: ${student.username} id=${student.id}');

    final studentSessions = allSessions.where((session) {
      return session.student.id == student.id &&
          useTypes.contains(session.type);
    }).toList();

    final grades = studentSessions
        .map((s) => int.tryParse(s.grade ?? ''))
        .whereType<int>()
        .toList();

    final average = grades.isNotEmpty
        ? grades.reduce((a, b) => a + b) / grades.length
        : null;

    final attestationId = studentToAttestationId[student.id];
    print('Вызов onUpdate для attestationId: $attestationId, средний балл: $average');

    if (attestationId != null) {
      onUpdate.call(attestationId, average, null);
    } else {
      print('Нет соответствия для студента ${student.username}');
    }
  }

  print('Вызов onUpdate завершен');
}


