import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataTableScreen extends StatefulWidget {
  @override
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  late EmployeeDataSource employeeDataSource;
  final List<Employee> employees = List.generate(
    22,
        (index) => Employee('Иванов Иван Иванович', List.generate(10, (i) => 'Н')),
  );

  int? selectedRowIndex;
  int? selectedColumnIndex;

  @override
  void initState() {
    super.initState();
    employeeDataSource = EmployeeDataSource(employees, onCellTap: (rowIndex, colIndex) {
      setState(() {
        selectedRowIndex = rowIndex;
        selectedColumnIndex = colIndex;
      });
    }, getSelectedCell: () => (selectedRowIndex, selectedColumnIndex));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Журнал')),
      body: SfDataGrid(
        source: employeeDataSource,
        headerRowHeight: 100,
        selectionMode: SelectionMode.single,
        onCellTap: (details) {
          setState(() {
            selectedRowIndex = details.rowColumnIndex.rowIndex - 1;
            selectedColumnIndex = details.rowColumnIndex.columnIndex;
          });
        },
        columns: [
          GridColumn(
              columnName: '№',
              label: Container(padding: EdgeInsets.all(8), alignment: Alignment.center, child: Text('№'))),
          GridColumn(
              columnName: 'ФИО',
              width: 200,
              label: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text('Список группы'))),
          for (int i = 1; i <= 10; i++)
            GridColumn(
              columnName: 'Дата $i',
              width: 50,
              label: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        '03.02.25',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey.shade400,
                      margin: EdgeInsets.symmetric(vertical: 2),
                    ),
                    Text(
                      'Лек',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Employee {
  Employee(this.name, this.attendance);

  final String name;
  final List<String> attendance;
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource(this.employees, {required this.onCellTap, required this.getSelectedCell}) {
    buildDataGridRows();
  }

  final Function(int rowIndex, int colIndex) onCellTap;
  final Function() getSelectedCell;
  List<DataGridRow> _dataGridRows = [];
  final List<Employee> employees;

  void buildDataGridRows() {
    _dataGridRows = employees
        .asMap()
        .entries
        .map(
          (entry) => DataGridRow(cells: [
        DataGridCell<int>(columnName: '№', value: entry.key + 1),
        DataGridCell<String>(columnName: 'ФИО', value: entry.value.name),
        for (int i = 0; i < entry.value.attendance.length; i++)
          DataGridCell<String>(columnName: 'Дата ${i + 1}', value: entry.value.attendance[i]),
      ]),
    )
        .toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rowIndex = _dataGridRows.indexOf(row);
    var (selectedRow, selectedColumn) = getSelectedCell();

    return DataGridRowAdapter(
      cells: row.getCells().asMap().entries.map((entry) {
        int columnIndex = entry.key;
        bool isSelected = rowIndex == selectedRow && columnIndex == selectedColumn;

        return GestureDetector(
          onTap: () {
            onCellTap(rowIndex, columnIndex);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent, // Подсветка
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Text(entry.value.value.toString()),
          ),
        );
      }).toList(),
    );
  }
}
