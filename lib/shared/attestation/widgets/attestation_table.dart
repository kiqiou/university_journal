import 'dart:math';
import 'package:flutter/foundation.dart';
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
  final void Function(int, int)? onUSRUpdate;

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
    _initializeDataSource();
  }

  void _initializeDataSource() {
    widget.attestations.sort((a, b) => a.student.username
        .toLowerCase()
        .compareTo(b.student.username.toLowerCase()));

    final maxUsrCount =
        widget.attestations.map((a) => a.usrItems.length).fold(0, max);

    _dataSource = _AttestationDataSource(
      attestations: widget.attestations,
      maxUsrCount: maxUsrCount,
      isEditable: widget.isEditable,
      selectedColumnIndex: widget.selectedColumnIndex,
      onAttestationUpdate: widget.onAttestationUpdate,
      onUSRUpdate: widget.onUSRUpdate,
    );
  }

  void updateAverageScore(int attestationId, double newScore) {
    _dataSource.updateAverageScore(attestationId, newScore);
  }

  @override
  @override
  void didUpdateWidget(covariant AttestationTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.attestations.sort((a, b) =>
        a.student.username.toLowerCase().compareTo(b.student.username.toLowerCase()));

    _dataSource.attestations = widget.attestations;
    _dataSource.refreshRows(); // <-- ВАЖНО

    if (widget.selectedColumnIndex != oldWidget.selectedColumnIndex) {
      _dataSource.selectedColumnIndex = widget.selectedColumnIndex;
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
        _buildHeaderColumn('№', 50, center: true),
        _buildHeaderColumn('Список студентов', 200, center: false),
        _buildHeaderColumn('Средний балл', 90),
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
        _buildHeaderColumn('Итог', 100),
      ],
    );
  }

  GridColumn _buildHeaderColumn(String text, double width,
      {bool center = true}) {
    return GridColumn(
      columnName: text,
      width: width,
      label: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: center ? Alignment.center : Alignment.centerLeft,
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.grey.shade900,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _AttestationDataSource extends DataGridSource {
  final Map<String, TextEditingController> _controllers = {};
  List<DataGridRow> _rows = [];
  List<Attestation> attestations;
  final int maxUsrCount;
  final bool isEditable;
  final Function(int, double?, String?)? onAttestationUpdate;
  final Function(int, int)? onUSRUpdate;
  int? selectedColumnIndex;

  _AttestationDataSource({
    required this.attestations,
    required this.maxUsrCount,
    this.onAttestationUpdate,
    this.onUSRUpdate,
    required this.isEditable,
    this.selectedColumnIndex,
  }) {
    _rows = _buildRows();
  }

  void refreshRows() {
    _controllers.forEach((_, c) => c.dispose());
    _controllers.clear();
    _rows = _buildRows();
    notifyListeners();
  }

  void updateAverageScore(int attestationId, double newScore) {
    final rowIndex = attestations.indexWhere((a) => a.id == attestationId);
    if (rowIndex == -1) return;

    attestations[rowIndex].averageScore = newScore;

    final key = '$attestationId-avg';
    final controller = _controllers[key];
    if (controller != null) {
      controller.text = newScore.toStringAsFixed(2);
    }
    notifyListeners();
  }


  @override
  List<DataGridRow> get rows => _rows;

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  List<DataGridRow> _buildRows() {
    return List.generate(attestations.length, (index) {
      final a = attestations[index];
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: '№', value: index + 1),
        DataGridCell<String>(columnName: 'ФИО', value: a.student.username),
        DataGridCell<String>(
          columnName: 'Средний балл',
          value: _controllers.putIfAbsent(
            '${a.id}-avg',
                () => TextEditingController(
              text: a.averageScore?.toStringAsFixed(2) ?? '',
            ),
          ).text,
        ),
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
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowIndex = _rows.indexOf(row);
    if (rowIndex == -1) throw Exception('Row not found in data source');
    final attestation = attestations[rowIndex];
    final attestationId = attestation.id;
    return DataGridRowAdapter(
      key: ValueKey(attestation.id),
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
        if (isUSRColumn) {
          final usrIndex = columnIndex - 3;
          final usrItem = usrIndex < attestation.usrItems.length
              ? attestation.usrItems[usrIndex]
              : null;
          final key = '${attestationId}-$columnIndex';
          final controller = _controllers.putIfAbsent(
            key,
            () => TextEditingController(text: cell.value.toString()),
          );
          return _buildEditableCell(
            controller: controller,
            readOnly: !isEditable,
            isNumber: true,
            onChanged: (newValue) {
              final parsedGrade = int.tryParse(newValue);
              if (usrItem != null && parsedGrade != null) {
                onUSRUpdate?.call(usrItem.id, parsedGrade);
              }
            },
          );
        }

        if (isAverageScore) {
          final key = '${attestationId}-avg';
          final controller = _controllers.putIfAbsent(
            key,
                () => TextEditingController(
              text: attestation.averageScore?.toStringAsFixed(2) ?? '',
            ),
          );
          return _buildEditableCell(
            controller: controller,
            readOnly: true,
            onChanged: (_) {},
          );
        }

        if (isResult) {
          final key = '${attestationId}-$columnIndex';
          final controller = _controllers.putIfAbsent(
            key,
            () => TextEditingController(text: cell.value.toString()),
          );
          return _buildEditableCell(
            controller: controller,
            readOnly: !isEditable,
            onChanged: (value) {
              onAttestationUpdate?.call(attestationId, null, value);
            },
          );
        }
        return Container();
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
