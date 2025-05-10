import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../components/colors/colors.dart';

class AddEventDialogContent extends StatefulWidget {
  final void Function(DateTime) onDateSelected;
  final void Function(String) onEventTypeSelected;
  final VoidCallback onSavePressed;

  const AddEventDialogContent({
    super.key,
    required this.onDateSelected,
    required this.onEventTypeSelected,
    required this.onSavePressed,
  });

  @override
  AddEventDialogContentState createState() => AddEventDialogContentState();
}

class AddEventDialogContentState extends State<AddEventDialogContent> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedEventType;
  OverlayEntry? _dropdownOverlay;
  OverlayEntry? _monthDropdownOverlay;
  final LayerLink _layerLink = LayerLink();
  final LayerLink _monthLayerLink = LayerLink();

  final List<String> _eventTypes = [
    'Лекция',
    'Семинар',
    'Практика',
    'Лабораторная',
    'Текущая аттестация',
    'Промежуточная аттестация',
  ];
  final List<String> _months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
  ];

  final GlobalKey _dropdownKey = GlobalKey();
  final GlobalKey _monthDropdownKey = GlobalKey();

  void _showDropdown() {
    if (_dropdownOverlay != null) return;
    final RenderBox box = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideDropdown,
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + size.height + 4,
              width: size.width,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _eventTypes.length,
                    separatorBuilder: (_, __) => SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final type = _eventTypes[index];
                      final isSelected = _selectedEventType == type;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.blue : Colors.white,
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            side: BorderSide(color: Colors.grey, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedEventType = type;
                            });
                            widget.onEventTypeSelected(type);
                            _hideDropdown();
                          },
                          child: Text(
                            type,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _hideDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  void _showMonthDropdown() {
    if (_monthDropdownOverlay != null) return;
    final RenderBox box = _monthDropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    _monthDropdownOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideMonthDropdown,
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + size.height + 4,
              width: size.width,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 350),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _months.length,
                    separatorBuilder: (_, __) => SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final isSelected = _focusedDay.month == index + 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.blue : Colors.white,
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            side: BorderSide(color: Colors.grey, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              // Сохраняем выбранный день, если он есть в новом месяце, иначе берем последний день месяца
                              int day = _selectedDate.day;
                              int year = _focusedDay.year;
                              int daysInMonth = DateTime(year, index + 2, 0).day;
                              if (day > daysInMonth) day = daysInMonth;
                              _selectedDate = DateTime(year, index + 1, day);
                              _focusedDay = DateTime(year, index + 1, day);
                            });
                            widget.onDateSelected(_selectedDate);
                            _hideMonthDropdown();
                          },
                          child: Text(
                            _months[index],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_monthDropdownOverlay!);
  }

  void _hideMonthDropdown() {
    _monthDropdownOverlay?.remove();
    _monthDropdownOverlay = null;
  }

  String _monthName(int month) => _months[month - 1];

  @override
  void dispose() {
    _hideDropdown();
    _hideMonthDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        widget.onSavePressed();
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.blueJournal,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 22),
                        minimumSize: Size(0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Сохранить', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: MyColors.blueJournal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 32),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
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
            SizedBox(height: 12),
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDateSelected(selectedDay);
              },
              headerVisible: false,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withValues(),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: MyColors.blueJournal,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // День
                Container(
                  width: 100,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Text(
                    _selectedDate.day.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(width: 15),
                // Месяц (выпадающий)
                CompositedTransformTarget(
                  link: _monthLayerLink,
                  child: GestureDetector(
                    key: _monthDropdownKey,
                    onTap: _showMonthDropdown,
                    child: Container(
                      width: 220,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _monthName(_focusedDay.month),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                // Год
                Container(
                  width: 150,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Text(
                    _selectedDate.year.toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Выберите тип занятия',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            // Кастомная кнопка выбора типа занятия
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                key: _dropdownKey,
                onTap: () {
                  if (_dropdownOverlay == null) {
                    _showDropdown();
                  } else {
                    _hideDropdown();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedEventType ?? 'Выберите тип занятия',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedEventType == null ? Colors.grey : Colors.black,
                        ),
                      ),
                      Icon(
                        _dropdownOverlay != null ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
