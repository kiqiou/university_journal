import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../bloc/services/attestation/model/attestation.dart';

class AttestationTable extends StatelessWidget {
  final List<Attestation> attestations;
  final bool isEditable;
  final Function(int attestationId, int usrIndex, String newGrade) onUpdate;

  const AttestationTable({
    super.key,
    required this.attestations,
    required this.onUpdate,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    final maxUsrCount = attestations.map((a) => a.usrItems.length).fold(0, max);

    return SfDataGrid(
      source: _AttestationDataSource(
        attestations: attestations,
        maxUsrCount: maxUsrCount,
        onUpdate: onUpdate,
        isEditable: isEditable,
      ),
      columns: [
        GridColumn(
          columnName: '№',
          width: 50,
          label: _headerCell('№'),
        ),
        GridColumn(
          columnName: 'ФИО',
          width: 180,
          label: _headerCell('ФИО'),
        ),
        GridColumn(
          columnName: 'Средний балл',
          width: 120,
          label: _headerCell('Средний балл'),
        ),
        for (int i = 0; i < maxUsrCount; i++)
          GridColumn(
            columnName: 'УСР-${i + 1}',
            width: 80,
            label: _headerCell('УСР-${i + 1}'),
          ),
        GridColumn(
          columnName: 'Итог',
          width: 100,
          label: _headerCell('Итог'),
        ),
      ],
    );
  }

  Widget _headerCell(String text) => Container(
    alignment: Alignment.center,
    color: Colors.grey.shade300,
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

class _AttestationDataSource extends DataGridSource {
  final List<Attestation> attestations;
  final int maxUsrCount;
  final bool isEditable;
  final Function(int attestationId, int usrIndex, String newGrade) onUpdate;

  _AttestationDataSource({
    required this.attestations,
    required this.maxUsrCount,
    required this.onUpdate,
    required this.isEditable,
  });

  @override
  List<DataGridRow> get rows => List.generate(attestations.length, (index) {
    final a = attestations[index];
    return DataGridRow(
      cells: [
        DataGridCell<int>(columnName: '№', value: index + 1),
        DataGridCell<String>(columnName: 'ФИО', value: a.student.username),
        DataGridCell<String>(
            columnName: 'Средний балл',
            value: a.averageScore?.toStringAsFixed(2) ?? '-'),
        ...List.generate(maxUsrCount, (i) {
          final grade = i < a.usrItems.length ? a.usrItems[i].grade : null;
          return DataGridCell<String>(
              columnName: 'УСР-${i + 1}', value: grade?.toString() ?? '');
        }),
        DataGridCell<String>(columnName: 'Итог', value: a.result),
      ],
    );
  });

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: row.getCells().asMap().entries.map((entry) {
      final colIndex = entry.key;
      final cell = entry.value;

      final isUSRColumn = colIndex >= 3 && colIndex < 3 + maxUsrCount;

      if (isUSRColumn && isEditable) {
        final usrIndex = colIndex - 3;
        final attestationIndex = rows.indexOf(row);
        final controller = TextEditingController(text: cell.value);

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(border: InputBorder.none),
            onSubmitted: (newGrade) {
              final attestationId = attestations[attestationIndex].id;
              onUpdate(attestationId, usrIndex, newGrade);
            },
          ),
        );
      }

      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        child: Text(cell.value.toString()),
      );
    }).toList());
  }
}

