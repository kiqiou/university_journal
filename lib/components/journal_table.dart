import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:collection/collection.dart';

import '../../../bloc/journal/journal.dart';
import '../bloc/journal/journal_repository.dart';
import 'colors/colors.dart';

class JournalTable extends StatefulWidget {
  final bool isLoading;
  final List<Session> sessions;
  final void Function(List<Session>)? onSessionsChanged;

  const JournalTable({super.key, required this.isLoading, required this.sessions, this.onSessionsChanged});

  @override
  State<JournalTable> createState() => JournalTableState();
}

class JournalTableState extends State<JournalTable> {
  JournalDataSource? dataSource;
  List<GridColumn> columns = [];
  List<Session> _sessions = [];
  int? _selectedColumnIndex;

  @override
  void initState() {
    super.initState();
    updateDataSource(widget.sessions);
  }

  void updateDataSource(List<Session> sessions) {
    final grouped = groupSessionsByStudent(sessions);

    setState(() {
      _sessions = sessions;
      columns = buildColumns(
        sessions: sessions,
        selectedColumnIndex: _selectedColumnIndex,
        onHeaderTap: _onHeaderTap,
      );
      dataSource = JournalDataSource(columns, grouped, sessions, onUpdate: (sessionId, studentId, status, grade) async {
        final repository = JournalRepository();
        final success = await repository.updateAttendance(
          sessionId: sessionId,
          studentId: studentId,
          status: status,
          grade: grade,
        );

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось обновить данные')),
          );
        }
      },);
    });
  }

  void _onHeaderTap(int index) {
    setState(() {
      _selectedColumnIndex = index;
      columns = buildColumns(
        sessions: _sessions, // ⬅️ используем сохранённые сессии
        selectedColumnIndex: _selectedColumnIndex,
        onHeaderTap: _onHeaderTap,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (_selectedColumnIndex != null)
            ElevatedButton(
              onPressed: () async {
                final dates = extractUniqueDateTypes(dataSource!.sessions);
                final toRemove = dates[_selectedColumnIndex!];
                final session = dataSource?.sessions.firstWhere(
                      (s) => '${s.date} ${s.sessionType} ${s.sessionId}' == toRemove,
                );
                final repository = JournalRepository();
                final success = await repository.deleteSession(sessionId: session!.sessionId);

                if (success) {
                  final updatedSessions = List<Session>.from(dataSource!.sessions)
                    ..removeWhere((s) => s.sessionId == session.sessionId);

                  setState(() {
                    _selectedColumnIndex = null;
                    updateDataSource(updatedSessions);
                    widget.onSessionsChanged?.call(updatedSessions);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ошибка при удалении занятия')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.blueJournal,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 23),
                textStyle: TextStyle(fontSize: 18),
                minimumSize: Size(170, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Удалить занятие',
                style: TextStyle(color: Colors.white),
              ),
            ),
          widget.isLoading || dataSource == null
              ? const Center(child: CircularProgressIndicator())
              : SfDataGrid(
                  gridLinesVisibility: GridLinesVisibility.none,
                  headerGridLinesVisibility: GridLinesVisibility.none,
                  source: dataSource!,
                  columns: columns,
                  headerRowHeight: 100,
                ),
        ],
      ),
    );
  }
}

/// Источник данных для таблицы
class JournalDataSource extends DataGridSource {
  final List<DataGridRow> _rows;
  final List<GridColumn> columns;
  final List<String> _dates;
  final Map<String, Map<String, Session>> _sessionData;
  final List<Session> sessions;

  final Future<void> Function(int sessionId, int studentId, String status, String grade)? onUpdate;

  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _getController(String key, String initialText) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialText);
    } else {
      if (!_controllers[key]!.value.selection.isValid) {
        _controllers[key]!.text = initialText;
      }
    }
    return _controllers[key]!;
  }

  JournalDataSource(this.columns,
      this._sessionData,
      this.sessions, {
        this.onUpdate,
      })
      : _dates = extractUniqueDateTypes(sessions).toList(),
        _rows = _buildRows(_sessionData, extractUniqueDateTypes(sessions).toList());

  void removeColumn(String dateType) {
    for (var row in _rows) {
      row.getCells().removeWhere((cell) => cell.columnName == dateType);
    }
    _dates.remove(dateType);
    notifyListeners();
  }

  static List<DataGridRow> _buildRows(Map<String, Map<String, Session>> data,
      List<String> dates,) {
    return data.entries.mapIndexed((index, entry) {
      final name = entry.key;
      final sessionsByDate = entry.value;

      return DataGridRow(
        cells: [
          DataGridCell<int>(columnName: '№', value: index + 1),
          DataGridCell<String>(columnName: 'ФИО', value: name),
          for (final date in dates)
            DataGridCell<Object>(
              columnName: date,
              value: {
                'status': sessionsByDate[date]?.status ?? '',
                'grade': sessionsByDate[date]?.grade ?? '',
              },
            ),
        ],
      );
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

        if (columnIndex == 0 || columnIndex == 1) {
          // № и ФИО
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(cell.value.toString(), textAlign: TextAlign.center),
          );
        }

        final value = cell.value as Map<String, String>;
        final status = value['status'] ?? '';
        final grade = value['grade'] ?? '';

        final rowIndex = _rows.indexOf(row);
        final studentName = _rows[rowIndex].getCells()[1].value;
        final date = cell.columnName;

        final session = _sessionData[studentName]?[date];
        if (session == null) {
          return Container();
        }

        final statusKey = '$studentName|$date|status';
        final gradeKey = '$studentName|$date|grade';

        final statusController = _getController(statusKey, status);
        final gradeController = _getController(gradeKey, grade);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: IntrinsicHeight(  // чтобы дочерние виджеты растянулись по высоте
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: statusController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[нН]')),
                      LengthLimitingTextInputFormatter(1),
                    ],
                    onChanged: (newStatus) async {
                      if (onUpdate != null) {
                        print('Обновление данных оценивания');
                        await onUpdate!(session.sessionId, session.student.id, newStatus, gradeController.text);
                      }
                      _sessionData[studentName]?[date]?.status = newStatus;
                      _rows[rowIndex].getCells()[columnIndex] = DataGridCell<Map<String, String>>(
                        columnName: date,
                        value: {
                          'status': newStatus,
                          'grade': gradeController.text,
                        },
                      );
                      notifyListeners();
                    },
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.grey.shade400,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                Expanded(
                  child: TextField(
                    controller: gradeController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(2),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (newGrade) async {
                      if (onUpdate != null) {
                        print('Обновление данных оценивания');
                        await onUpdate!(session.sessionId, session.student.id, statusController.text, newGrade,);
                      }
                      _sessionData[studentName]?[date]?.grade = newGrade;
                      _rows[rowIndex].getCells()[columnIndex] = DataGridCell<Map<String, String>>(
                        columnName: date,
                        value: {
                          'status': statusController.text,
                          'grade': newGrade,
                        },
                      );
                      notifyListeners();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}


  List<String> extractUniqueDateTypes(List<Session> sessions) {
    final Set<String> dateTypes = {};

    for (var session in sessions) {
      dateTypes.add('${session.date} ${session.sessionType} ${session.sessionId}');
    }
    final sorted = dateTypes.toList()
      ..sort((a, b) => a.compareTo(b));

    return sorted;
  }

Map<String, Map<String, Session>> groupSessionsByStudent(List<Session> sessions) {
  final Map<String, Map<String, Session>> result = {};

  for (var session in sessions) {
    final studentName = session.student.username;
    final dateTypeKey = '${session.date} ${session.sessionType} ${session.sessionId}';

    result.putIfAbsent(studentName, () => {});
    result[studentName]![dateTypeKey] = session; // ⬅️ берём только одну сессию (последнюю)
  }

  return result;
}

  List<GridColumn> buildColumns({
    required List<Session> sessions,
    required int? selectedColumnIndex,
    required void Function(int index) onHeaderTap,
  }) {
    final dateTypeColumns = extractUniqueDateTypes(sessions);

    const sessionTypeShortNames = {
      'Лекция': 'Лек',
      'Практика': 'Практ',
      'Семинар': 'Сем',
      'Лабораторная': 'Лаб',
    };

    final columns = <GridColumn>[
      // №
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
      // ФИО
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
    ];

    for (var entry in dateTypeColumns.asMap().entries) {
      final index = entry.key;
      final dateType = entry.value;

      final parts = dateType.split(' ');
      final sessionType = parts.length > 1 ? parts[1] : '';

      columns.add(
        GridColumn(
          columnName: dateType,
          width: 80,
          allowSorting: true,
          label: GestureDetector(
            onTap: () => onHeaderTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(
                  color: selectedColumnIndex == index ? MyColors.blueJournal : Colors.grey.shade400,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      dateType.split(' ').first,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(height: 2, color: Colors.grey.shade400),
                  Text(
                    sessionTypeShortNames[sessionType] ?? sessionType,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return columns;
  }

