import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../bloc/services/attestation/model/attestation.dart';
import '../../../components/colors/colors.dart';

class AttestationTable extends StatefulWidget {
  final List<Attestation> attestations;
  final bool isEditable;
  final void Function(int?)? onColumnSelected;
  final int? selectedColumnIndex;
  final Function(int, double?, String?)? onAttestationUpdate;
  final Function(int, int)? onUSRUpdate;

  const AttestationTable({
    super.key,
    required this.attestations,
    required this.isEditable,
    this.onColumnSelected,
    this.selectedColumnIndex,
    this.onAttestationUpdate,
    this.onUSRUpdate,
  });

  @override
  AttestationTableState createState() => AttestationTableState();
}

class AttestationTableState extends State<AttestationTable> {
  late _AttestationDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    final maxUsrCount = widget.attestations.map((a) => a.usrItems.length).fold(0, max);
    _dataSource = _AttestationDataSource(
      attestations: widget.attestations,
      maxUsrCount: maxUsrCount,
      isEditable: widget.isEditable,
      selectedColumnIndex: widget.selectedColumnIndex,
      onAttestationUpdate: widget.onAttestationUpdate,
      onUSRUpdate: widget.onUSRUpdate,
    );
  }

  @override
  void didUpdateWidget(covariant AttestationTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.attestations != oldWidget.attestations) {
      _dataSource.attestations.clear();
      _dataSource.attestations.addAll(widget.attestations);
      _dataSource.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxUsrCount =
        widget.attestations.map((a) => a.usrItems.length).fold(0, max);

    return SfDataGrid(
      gridLinesVisibility: GridLinesVisibility.none,
      headerGridLinesVisibility: GridLinesVisibility.none,
      headerRowHeight: 100,
      source: _dataSource,
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
              'Список студентов',
              style: TextStyle(
                  color: Colors.grey.shade900,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        GridColumn(
          columnName: 'Средний балл',
          width: 90,
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
            label: GestureDetector(
              onTap: () {
                if (widget.onColumnSelected != null) {
                  widget.onColumnSelected!(i);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  border: Border.all(
                      color: widget.selectedColumnIndex == i
                          ? MyColors.blueJournal
                          : Colors.grey.shade400),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'УСР-${i + 1}',
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
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
}

class _AttestationDataSource extends DataGridSource {
  final Map<String, TextEditingController> _controllers = {};
  late final List<DataGridRow> _rows;
  final List<Attestation> attestations;
  final int maxUsrCount;
  final bool isEditable;
  final Function(int, double?, String?)? onAttestationUpdate;
  final Function(int, int)? onUSRUpdate;
  int? selectedColumnIndex;

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  _AttestationDataSource({
    required this.attestations,
    required this.maxUsrCount,
    this.onAttestationUpdate,
    this.onUSRUpdate,
    required this.isEditable,
    this.selectedColumnIndex,
  }) {
    _rows = List.generate(attestations.length, (index) {
      final a = attestations[index];
      return DataGridRow(cells: [
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
      ]);
    });
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = _rows.indexOf(row);
    if (rowIndex == -1) throw Exception('Row not found in data source');

    final attestation = attestations[rowIndex];
    final attestationId = attestation.id;

    return DataGridRowAdapter(
      cells: row.getCells().asMap().entries.map((entry) {
        final columnIndex = entry.key;
        final cell = entry.value;

        final isUSRColumn = columnIndex >= 3 && columnIndex < 3 + maxUsrCount;
        final isAverageScore = columnIndex == 2;
        final isResult = columnIndex == 3 + maxUsrCount;

        if (columnIndex == 0 || columnIndex == 1) {
          return _buildStaticCell(cell.value.toString(),
              align:
                  columnIndex == 1 ? Alignment.centerLeft : Alignment.center);
        }

        final key = '${attestationId}-$columnIndex';
        final controller = _controllers.putIfAbsent(
          key,
          () => TextEditingController(text: cell.value.toString()),
        );

        if (isUSRColumn) {
          final usrIndex = columnIndex - 3;
          final usrItem = usrIndex < attestation.usrItems.length
              ? attestation.usrItems[usrIndex]
              : null;

          return _buildEditableCell(
            controller: controller,
            readOnly: !isEditable,
            isNumber: true,
            onChanged: (newValue) {
              print('🟡 Result changed: $newValue');
              final parsedGrade = int.tryParse(newValue);
              if (usrItem != null && parsedGrade != null) {
                onUSRUpdate?.call(usrItem.id, parsedGrade);
              }
            },
          );
        }

        if (isAverageScore) {
          return _buildStaticCell((cell.value.toString()));
        }

        if (isResult) {
          return _buildEditableCell(
            controller: controller,
            readOnly: !isEditable,
            onChanged: (value) {
              print('🟡 Result changed: $value');
              onAttestationUpdate?.call(attestationId, null, value);
            },
          );
        }

        return Container(); // fallback
      }).toList(),
    );
  }

  Widget _buildStaticCell(String text, {Alignment align = Alignment.center}) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEditableCell({
    required TextEditingController controller,
    required bool readOnly,
    required Function(String) onChanged,
    bool isNumber = false,
    bool isDecimal = false,
  }) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        style: TextStyle(color: Colors.grey.shade700),
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : isNumber
                ? TextInputType.number
                : TextInputType.text,
        inputFormatters: [
          if (isNumber) LengthLimitingTextInputFormatter(2),
          if (isNumber) FilteringTextInputFormatter.digitsOnly,
          if (isDecimal)
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
