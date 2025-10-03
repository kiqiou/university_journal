import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:collection/collection.dart';

import '../../../bloc/services/journal/journal_repository.dart';
import '../../../bloc/services/journal/models/session.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../components/colors/colors.dart';

class JournalTable extends StatefulWidget {
  final bool isLoading;
  final bool isEditable;
  final bool? isHeadman;
  final int? selectedColumnIndex;
  final String? token;
  final List<Session> sessions;
  final List<MyUser> students;
  final void Function(int)? onColumnSelected;

  const JournalTable({
    super.key,
    required this.isLoading,
    required this.sessions,
    required this.isEditable,
    required this.students,
    this.onColumnSelected,
    this.selectedColumnIndex,
    this.isHeadman,
    this.token,
  });

  @override
  State<JournalTable> createState() => JournalTableState();
}

class JournalTableState extends State<JournalTable> {
  JournalDataSource? dataSource;
  List<GridColumn> columns = [];
  List<Session> _sessions = [];

  @override
  void initState() {
    super.initState();
    updateDataSource(widget.sessions, widget.students);
  }

  void updateDataSource(List<Session> sessions, List<MyUser> students) {
    // сортируем студентов по алфавиту
    final sortedStudents = List<MyUser>.from(students)
      ..sort((a, b) => a.username.compareTo(b.username));

    final grouped = groupSessionsByStudent(sessions, sortedStudents);

    setState(() {
      _sessions = sessions;

      extractUniqueDateTypes(sessions);

      columns = buildColumns(
        sessions: sessions,
        selectedColumnIndex: widget.selectedColumnIndex,
        onHeaderTap: _onHeaderTap,
      );

      dataSource = JournalDataSource(
        columns,
        grouped,
        sessions,
        widget.isEditable,
        widget.isHeadman,
        onUpdate: (sessionId, studentId, status, grade) async {
          final journalRepository = JournalRepository();
          final result = await journalRepository.updateAttendance(
            sessionId: sessionId,
            studentId: studentId,
            status: status,
            grade: grade,
            token: widget.token,
          );

          if (result == null || result['success'] != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось обновить данные')),
            );
            return null;
          }
          return result;
        },
      );
    });
  }

  @override
  void didUpdateWidget(covariant JournalTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessions != widget.sessions) {
      updateDataSource(widget.sessions, widget.students);
    } else if (oldWidget.selectedColumnIndex != widget.selectedColumnIndex) {
      setState(() {
        columns = buildColumns(
          sessions: _sessions,
          selectedColumnIndex: widget.selectedColumnIndex,
          onHeaderTap: _onHeaderTap,
        );
      });
    }
  }

  void _onHeaderTap(int index) {
    if (widget.isEditable) {
      widget.onColumnSelected?.call(index);
      setState(() {
        columns = buildColumns(
          sessions: _sessions,
          selectedColumnIndex: index,
          onHeaderTap: _onHeaderTap,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.isLoading || dataSource == null
              ? const Center(child: CircularProgressIndicator())
              : SfDataGrid(
            gridLinesVisibility: GridLinesVisibility.none,
            headerGridLinesVisibility: GridLinesVisibility.none,
            source: dataSource!,
            columns: columns,
            headerRowHeight: 100,
          ),
        ),
      ],
    );
  }
}

  /// Источник данных для таблицы
class JournalDataSource extends DataGridSource {
  final Future<Map<String, dynamic>?> Function(
      int sessionId, int studentId, String status, String grade)? onUpdate;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Map<String, Session>> _sessionData;
  final List<DataGridRow> _rows;
  final List<GridColumn> columns;
  final List<String> _dates;
  final List<Session> sessions;
  final bool isEditable;
  final bool? isHeadman;

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

  JournalDataSource(
    this.columns,
    this._sessionData,
    this.sessions,
    this.isEditable,
    this.isHeadman, {
    this.onUpdate,
  })  : _dates = extractUniqueDateTypes(sessions).toList(),
        _rows =
            _buildRows(_sessionData, extractUniqueDateTypes(sessions).toList());

  void removeColumn(String dateType) {
    for (var row in _rows) {
      row.getCells().removeWhere((cell) => cell.columnName == dateType);
    }
    _dates.remove(dateType);
    notifyListeners();
  }

  static List<DataGridRow> _buildRows(
      Map<String, Map<String, Session>> data,
      List<String> dates,
      ) {
    return data.entries.mapIndexed((index, entry) {
      final studentName = entry.key;
      final sessionsByDate = entry.value;

      return DataGridRow(
        cells: [
          DataGridCell<int>(columnName: '№', value: index + 1),
          DataGridCell<String>(columnName: 'ФИО', value: studentName),
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

        if (columnIndex == 1 || columnIndex == 0) {
          return Container(
            alignment: columnIndex == 1 ? Alignment.centerLeft : Alignment.center,
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

        final modifiedBy = session.modifiedByUsername ?? 'неизвестно';
        final updatedAtStr = session.updatedAt != null
            ? DateFormat('dd.MM.yyyy HH:mm').format(session.updatedAt!)
            : 'неизвестно';

        return Tooltip(
          message: 'Изменил: $modifiedBy\nВремя: $updatedAtStr',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: statusController,
                      textAlign: TextAlign.center,
                      readOnly: !(isEditable || (isHeadman ?? false)),
                      //enabled: isEditable,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        disabledBorder: InputBorder.none,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[нН]')),
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (newStatus) async {
                        final result = await onUpdate!(
                          session.id,
                          session.student.id,
                          newStatus,
                          gradeController.text,
                        );

                        if (result != null && result['success'] == true) {
                          _sessionData[studentName]?[date]?.status = newStatus;
                          _sessionData[studentName]?[date]?.grade =
                              gradeController.text;

                          _sessionData[studentName]?[date]?.modifiedByUsername =
                              result['modified_by'];
                          final parsedDate =
                              DateTime.tryParse(result['updated_at'] ?? '');
                          if (parsedDate != null) {
                            _sessionData[studentName]?[date]?.updatedAt =
                                parsedDate.toLocal();
                          }

                          _rows[rowIndex].getCells()[columnIndex] =
                              DataGridCell<Map<String, String>>(
                            columnName: date,
                            value: {
                              'status': newStatus,
                              'grade': gradeController.text,
                            },
                          );
                          notifyListeners();
                        }
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
                      readOnly: !isEditable,
                      //enabled: isEditable,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        disabledBorder: InputBorder.none,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (newGrade) async {
                        final result = await onUpdate!(
                          session.id,
                          session.student.id,
                          statusController.text,
                          newGrade,
                        );

                        if (result != null && result['success'] == true) {
                          _sessionData[studentName]?[date]?.status =
                              statusController.text;
                          _sessionData[studentName]?[date]?.grade = newGrade;

                          _sessionData[studentName]?[date]?.modifiedByUsername =
                              result['modified_by'];
                          final parsedDate =
                              DateTime.tryParse(result['updated_at'] ?? '');
                          if (parsedDate != null) {
                            _sessionData[studentName]?[date]?.updatedAt =
                                parsedDate.toLocal();
                          }
                          _sessionData[studentName]?[date]?.grade = newGrade;
                          _rows[rowIndex].getCells()[columnIndex] =
                              DataGridCell<Map<String, String>>(
                            columnName: date,
                            value: {
                              'status': statusController.text,
                              'grade': newGrade,
                            },
                          );
                          notifyListeners();
                        }
                      },
                    ),
                  ),
                ],
              ),
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
    dateTypes.add('${session.date} ${session.type} ${session.id}');
  }
  final sorted = dateTypes.toList()..sort((a, b) => a.compareTo(b));

  return sorted;
}

Map<String, Map<String, Session>> groupSessionsByStudent(
  List<Session> sessions,
  List<MyUser> students,
) {
  final Map<String, Map<String, Session>> result = {};

  for (var student in students) {
    result[student.username] = {};
  }

  for (var session in sessions) {
    final studentName = session.student.username;
    final dateTypeKey = '${session.date} ${session.type} ${session.id}';
    result.putIfAbsent(studentName, () => {});
    result[studentName]![dateTypeKey] = session;
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
  ];

  if (dateTypeColumns.isEmpty) {
    return columns; // Только № и ФИО
  }

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
                color: selectedColumnIndex == index
                    ? MyColors.blueJournal
                    : Colors.grey.shade400,
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
                    style: TextStyle(
                        fontFamily: 'Sora',
                        color: Colors.grey.shade800,
                        fontSize: 12),
                  ),
                ),
                Divider(height: 2, color: Colors.grey.shade400),
                Text(
                  sessionTypeShortNames[sessionType] ?? sessionType,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade900,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700),
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
