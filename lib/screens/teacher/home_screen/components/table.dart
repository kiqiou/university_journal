import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:collection/collection.dart';

import '../../../../bloc/journal/journal.dart';
import '../../../../bloc/journal/journal_repository.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late JournalDataSource dataSource;
  List<GridColumn> columns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final journalRepository = JournalRepository();
    final sessions = await journalRepository.journalData();
    final grouped = groupSessionsByStudent(sessions);

    setState(() {
      columns = buildColumns(sessions);
      dataSource = JournalDataSource(grouped, sessions);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Журнал')),
      body: isLoading
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
      : _dates = extractUniqueDates(sessions),
        _rows = _buildRows(_sessionData, extractUniqueDates(sessions));

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

/// Вспомогательные функции

List<String> extractUniqueDates(List<Session> sessions) {
  final dates = sessions.map((s) => s.date).toSet().toList();
  dates.sort();
  return dates;
}

Map<String, Map<String, Session>> groupSessionsByStudent(List<Session> sessions) {
  final Map<String, Map<String, Session>> result = {};

  for (var session in sessions) {
    final studentName = session.student.username;
    final date = session.date;
    if (!result.containsKey(studentName)) {
      result[studentName] = {};
    }
    result[studentName]![date] = session;
  }

  return result;
}


List<GridColumn> buildColumns(List<Session> sessions) {
  final uniqueDates = <String, String>{}; // date -> type

  for (var session in sessions) {
    uniqueDates[session.date] = session.sessionType;
  }

  final sortedDates = uniqueDates.keys.toList()..sort();

  return [
    GridColumn(
      columnName: '№',
      width: 50,
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
    for (var date in sortedDates)
      GridColumn(
        columnName: date,
        width: 60,
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
                child: Text(date, textAlign: TextAlign.center),
              ),
              Divider(height: 2, color: Colors.grey.shade400,),
              Text(
                uniqueDates[date] ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
  ];
}
