import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      gridLinesVisibility: GridLinesVisibility.none,
      headerGridLinesVisibility: GridLinesVisibility.none,
      headerRowHeight: 100,
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
          allowSorting: true,
          label: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(8),
            child: Text(
              '№',
              style: TextStyle(
                  color: Colors.grey.shade900,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        GridColumn(
          columnName: 'Список студентов',
          width: 200,
          allowSorting: true,
          label: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              'ФИО',
              style: TextStyle(
                  color: Colors.grey.shade900,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        GridColumn(
          columnName: 'Средний балл',
          width: 120,
          label: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              'Средний балл',
              style: TextStyle(
                  color: Colors.grey.shade900,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700),
            ),
          ),
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
          label: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: Text(
              'Итог',
              style: TextStyle(
                  color: Colors.grey.shade900,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700),
            ),
          ),
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
            value: a.averageScore.toStringAsFixed(2)),
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
      final columnIndex = entry.key;
      final cell = entry.value;
      final rowIndex = rows.indexOf(row);

      final isUSRColumn = columnIndex >= 3 && columnIndex < 3 + maxUsrCount;

      if (columnIndex == 1 || columnIndex == 0) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            cell.value.toString(),
            textAlign: columnIndex == 1 ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }

      if (isUSRColumn && isEditable) {
        final usrIndex = columnIndex - 3;
        final attestationId = attestations[rowIndex].id;
        final controller = TextEditingController(text: cell.value);

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            ),
            style: TextStyle(color: Colors.grey.shade700),
            onSubmitted: (newGrade) {
              onUpdate(attestationId, usrIndex, newGrade);
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(2),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        );
      }

      // 📄 Нередактируемые ячейки
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          cell.value.toString(),
          style: TextStyle(color: Colors.grey.shade800),
        ),
      );
    }).toList(),
    );
  }
}

