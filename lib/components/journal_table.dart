import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:collection/collection.dart';

import '../../../bloc/journal/journal.dart';

class JournalTable extends StatefulWidget {
  final bool isLoading;

  const JournalTable({super.key, required this.isLoading});

  @override
  State<JournalTable> createState() => JournalTableState();
}

class JournalTableState extends State<JournalTable> {
  late JournalDataSource dataSource;
  List<GridColumn> columns = [];

  @override
  void initState() {
    super.initState();
  }

  void updateDataSource(List<Session> sessions) {
    final grouped = groupSessionsByStudent(sessions);
    setState(() {
      columns = buildColumns(sessions);
      dataSource = JournalDataSource(grouped, sessions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Журнал')),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfDataGrid(
        gridLinesVisibility: GridLinesVisibility.none,
        headerGridLinesVisibility: GridLinesVisibility.none,
        source: dataSource,
        columns: columns,
        headerRowHeight: 100,
      ),
    );
  }
}

/// Источник данных для таблицы
class JournalDataSource extends DataGridSource {
  final List<DataGridRow> _rows;
  final List<String> _dates;
  final Map<String, Map<String, Session>> _sessionData;

  JournalDataSource(this._sessionData, List<Session> sessions)
      : _dates = extractUniqueDateTypes(sessions).toList(),
        _rows = _buildRows(_sessionData, extractUniqueDateTypes(sessions).toList());

  static List<DataGridRow> _buildRows(
      Map<String, Map<String, Session>> data,
      List<String> dates,
      ) {
    return data.entries.mapIndexed((index, entry) {
      final name = entry.key;
      final sessionsByDate = entry.value;

      return DataGridRow(cells: [
        DataGridCell<int>(columnName: '№', value: index + 1),
        DataGridCell<String>(columnName: 'ФИО', value: name),
        for (final date in dates)
          DataGridCell<String>(
            columnName: date,
            value: sessionsByDate[date]?.status ?? '',
          ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().asMap().entries.map((entry) {
        final columnIndex = entry.key;
        final cell = entry.value;
        final isEditable = columnIndex > 1;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: isEditable
              ? TextField(
            controller: TextEditingController(text: cell.value.toString()),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
            onChanged: (value) {
              final rowIndex = _rows.indexOf(row);
              final studentName = _rows[rowIndex].getCells()[1].value;
              final date = _dates[columnIndex - 2]; // учесть № и ФИО

              _sessionData[studentName]?[date]?.status = value;

              _rows[rowIndex].getCells()[columnIndex] =
                  DataGridCell<String>(columnName: date, value: value);

              notifyListeners();
            },
          )
              : Text(cell.value.toString(), textAlign: TextAlign.center),
        );
      }).toList(),
    );
  }
}

List<String> extractUniqueDateTypes(List<Session> sessions) {
  final Set<String> dateTypes = {};

  for (var session in sessions) {
    dateTypes.add('${session.date} ${session.sessionType}');
  }
  final sorted = dateTypes.toList()
    ..sort((a, b) => a.compareTo(b));

  return sorted;
}

Map<String, Map<String, Session>> groupSessionsByStudent(List<Session> sessions) {
  final Map<String, Map<String, Session>> result = {};

  for (var session in sessions) {
    final studentName = session.student.username;
    final dateTypeKey = '${session.date} ${session.sessionType}';

    result.putIfAbsent(studentName, () => {});
    result[studentName]![dateTypeKey] = session;
  }

  return result;
}

List<GridColumn> buildColumns(List<Session> sessions) {
  final dateTypeColumns = extractUniqueDateTypes(sessions);

  const sessionTypeShortNames = {
    'Лекция': 'Лек',
    'Практика': 'Практ',
    'Семинар': 'Сем',
    'Лабораторная': 'Лаб',

  };

  return [
    GridColumn(
      columnName: '№',
      width: 50,
      allowSorting: true,
      label: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: const Text('№'),
      ),
    ),
    GridColumn(
      columnName: 'ФИО',
      width: 200,
      allowSorting: true,
      label: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: const Text('ФИО'),
      ),
    ),
    for (var dateType in dateTypeColumns)
      GridColumn(
        columnName: dateType,
        width: 60,
        allowSorting: true,
        label: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(dateType.split(' ').first, textAlign: TextAlign.center),
              ),
              Divider(height: 2, color: Colors.grey.shade400),
              Text(
                sessionTypeShortNames[dateType.split(' ').last] ?? dateType.split(' ').last,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
  ];
}
