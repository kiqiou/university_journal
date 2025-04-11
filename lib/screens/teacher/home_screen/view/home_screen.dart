import 'package:flutter/material.dart';
import 'package:university_journal/screens/teacher/home_screen/components/side_navigation_menu.dart';
import 'package:university_journal/screens/teacher/home_screen/components/table.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  DateTime? _selectedDate;
  String? _selectedEventType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          TeacherSideNavigationMenu(),
          SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _showAddEventDialog(context);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text(
                      'Добавить занятие',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: DataTableScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 30,
              right: 30,
              child: Material(
                borderRadius: BorderRadius.circular(15),
                elevation: 8,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: AddEventDialogContent(
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    onEventTypeSelected: (eventType) {
                      setState(() {
                        _selectedEventType = eventType;
                      });
                    },
                    onSavePressed: () {
                      if (_selectedDate != null && _selectedEventType != null) {
                        print(
                            'Date: $_selectedDate, Type: $_selectedEventType');
                        Navigator.of(context).pop();
                      } else {
                        print('Please select date and event type');
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AddEventDialogContent extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Function(String) onEventTypeSelected;
  final VoidCallback onSavePressed;

  const AddEventDialogContent(
      {Key? key,
      required this.onDateSelected,
      required this.onEventTypeSelected,
      required this.onSavePressed})
      : super(key: key);

  @override
  _AddEventDialogContentState createState() => _AddEventDialogContentState();
}

class _AddEventDialogContentState extends State<AddEventDialogContent> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEventType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800,
      width: 100,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Добавить занятие в журнал',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.onSavePressed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        minimumSize: Size(0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('Сохранить',
                          style: TextStyle(color: Colors.white)),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Выберите дату занятия',
              style: TextStyle(fontSize: 16),
            ),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDateSelected(date);
              },
            ),
            SizedBox(height: 100),
            Text(
              'Выберите вид занятия',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 30),
            Wrap(
              spacing: 30,
              runSpacing: 20,
              children: [
                _buildOption('Лекция'),
                _buildOption('Семинар'),
                _buildOption('Практика'),
                _buildOption('Лабораторная'),
                _buildOption('Текущая аттестация'),
                _buildOption('Промежуточная аттестация'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String text) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedEventType = text;
        });
        widget.onEventTypeSelected(text);
      },
      style: ElevatedButton.styleFrom(
          backgroundColor:
          _selectedEventType == text ? Colors.indigoAccent : Colors.blue,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}


