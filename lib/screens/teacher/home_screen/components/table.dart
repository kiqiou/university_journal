import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataTableScreen extends StatefulWidget {
  const DataTableScreen({super.key});

  @override
  DataTableScreenState createState() => DataTableScreenState();
}

class DataTableScreenState extends State<DataTableScreen> {
  late EmployeeDataSource employeeDataSource;
  final List<Employee> employees = List.generate(
    22,
    (index) => Employee('Иванов Иван', List.generate(10, (i) => 'Н')),
  );

  int? selectedRowIndex;
  int? selectedColumnIndex;

  @override
  void initState() {
    super.initState();
    employeeDataSource = EmployeeDataSource(employees);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Журнал')),
      body: SfDataGrid(
        source: employeeDataSource,
        headerRowHeight: 100,
        editingGestureType: EditingGestureType.doubleTap,
        columns: [
          GridColumn(
            columnName: '№',
            label: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.grey.shade400),
              ),
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text('№'),
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
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Center(child: Text('ФИО')),
            ),
          ),
          for (int i = 1; i <= 10; i++)
            GridColumn(
              columnName: 'Дата $i',
              width: 50,
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
                      child: Text(
                        '03.02.2025',
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
  List<DataGridRow> _dataGridRows = [];
  final List<Employee> employees;
  final String? userRole;

  EmployeeDataSource(this.employees, {this.userRole}) {
    buildDataGridRows();
  }

  void buildDataGridRows() {
    _dataGridRows = employees
        .asMap()
        .entries
        .map(
          (entry) =>
          DataGridRow(cells: [
            DataGridCell<int>(columnName: '№', value: entry.key + 1),
            DataGridCell<String>(columnName: 'ФИО', value: entry.value.name),
            for (int i = 0; i < entry.value.attendance.length; i++)
              DataGridCell<String>(
                columnName: 'Дата ${i + 1}',
                value: entry.value.attendance[i],
              )
          ]),
    )
        .toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  Future<void> onCellSubmit(DataGridRow row, RowColumnIndex rowColumnIndex, GridColumn column) async {
    if (rowColumnIndex.rowIndex < 0) return;
    int employeeIndex = rowColumnIndex.rowIndex;
    print("Ячейка изменена: ${column.columnName}");
    employees[employeeIndex].attendance[rowColumnIndex.columnIndex - 2] = column.columnName;
    notifyListeners();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rowIndex = _dataGridRows.indexOf(row);

    return DataGridRowAdapter(
      cells: row
          .getCells()
          .asMap()
          .entries
          .map((entry) {
        int columnIndex = entry.key;

        TextEditingController controller = TextEditingController(
          text: entry.value.value?.toString() ?? '',
        );

        return GestureDetector(
          onTap: () {
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: TextField(
              enabled: true,
              controller: controller,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
              onChanged: (value) {
                if (columnIndex > 1) {
                  employees[rowIndex].attendance[columnIndex - 2] = value;
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}