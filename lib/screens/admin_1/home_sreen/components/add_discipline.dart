import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'dart:math';

import '../../../../bloc/discipline/discipline.dart';
import '../../../../bloc/discipline/discipline_repository.dart';
import '../../../../bloc/group/group.dart';
import '../../../../bloc/user/user.dart';
import '../../../../components/colors/colors.dart';
import '../../../../components/multiselect.dart';

class AddCourseDialog extends StatefulWidget {
  final VoidCallback onCourseAdded;
  final List<Group> groups;
  final List<MyUser> teachers;

  const AddCourseDialog({
    super.key,
    required this.onCourseAdded,
    required this.groups,
    required this.teachers,
  });

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lectureHoursController = TextEditingController();
  final TextEditingController labHoursController = TextEditingController();
  final Map<String, TextEditingController> hoursControllers = {};

  @override
  void initState() {
    super.initState();
    for (var type in lessonTypes) {
      hoursControllers[type] = TextEditingController();
    }
  }
  @override
  void dispose() {
    for (var controller in hoursControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  final List<Discipline> disciplines = [];
  List<MyUser> selectedTeachers = [];
  List<Group> selectedGroups = [];
  List<MyUser> selectedTeachers2 = [];
  List<String> selectedTypes = [];
  List<String> selectedLessonTypes = [];

  bool nameError = false;
  bool teacherError = false;
  bool groupError = false;
  bool lecturesError = false;

  String? selectedLessonType;
  MyUser? selectedTeacher;
  Group? selectedGroup;

  final List<String> lessonTypes = [
    'Лекции',
    'Семинар',
    'Практика',
    'Лабораторные',
    'Текущая аттестация',
    'Промежуточная аттестация',
  ];

  bool get showLectureHours => selectedLessonType == 'Лекции';

  bool get showLabHours => selectedLessonType == 'Лабораторные';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const double minWidth = 380;
    const double maxWidth = 600;
    final double dialogWidth = min(maxWidth, max(minWidth, screenWidth * 0.45));
    final double dialogHeight = min(screenHeight * 0.95, screenHeight - 40);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(right: 30),
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и кнопки
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Создание дисциплины',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    List<int> teacherIds = selectedTeachers.map((e) => e.id).toList();
                                    List<int> groupIds = selectedGroups.map((e) => e.id).toList();

                                    bool result = await DisciplineRepository().addCourse(
                                      name: nameController.text,
                                      teacherIds: teacherIds,
                                      groupIds: groupIds,
                                    );

                                    if (result) {
                                      widget.onCourseAdded();
                                      Navigator.of(context).pop();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('❌ Не удалось добавить курс')),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4068EA),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                                  minimumSize: const Size(140, 48),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                child: const Text('Сохранить'),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4068EA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 28, color: Colors.white),
                                  splashRadius: 24,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Название дисциплины
                              Text(
                                'Название дисциплины*',
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: 'Введите название дисциплины',
                                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(color: MyColors.blueJournal, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                ),
                                validator: (value) => value == null || value.isEmpty ? 'Обязательное поле' : null,
                              ),
                              const SizedBox(height: 24),

                              // Виды занятий
                              Text(
                                'Выберите вид занятий',
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: lessonTypes.map((type) {
                                  final isSelected = selectedLessonTypes.contains(type);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedLessonTypes.remove(type);
                                        } else {
                                          selectedLessonTypes.add(type);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF4068EA) : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF4068EA) : Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),

                              // Контейнеры для часов
                              if (selectedLessonTypes.isNotEmpty)
                                ...List.generate(
                                  (selectedLessonTypes.length / 2).ceil(),
                                      (rowIndex) {
                                    final start = rowIndex * 2;
                                    final end = (start + 2 < selectedLessonTypes.length) ? start + 2 : selectedLessonTypes.length;
                                    final rowTypes = selectedLessonTypes.sublist(start, end);
                                    return Row(
                                      children: rowTypes.map((type) {
                                        return Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(right: rowTypes.last == type ? 0 : 12, bottom: 12),
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(22),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('$type*', style: TextStyle(fontWeight: FontWeight.w500)),
                                                SizedBox(height: 8),
                                                TextFormField(
                                                  controller: hoursControllers[type],
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText: 'Введите часы',
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                      borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                      borderSide: BorderSide(color: Color(0xFF4068EA), width: 1.2),
                                                    ),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                  validator: (value) {
                                                    if (selectedLessonTypes.contains(type) && (value == null || value.isEmpty)) {
                                                      return 'Обязательное поле';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),

                              // Привязка преподавателя
                              Text("Привязать преподавателя",
                                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () async {
                                  final selected = await showDialog<List<MyUser>>(
                                    context: context,
                                    builder: (_) => MultiSelectDialog(
                                      items: widget.teachers,
                                      initiallySelected: selectedTeachers,
                                      itemLabel: (user) => user.username,
                                    ),
                                  );

                                  if (selected != null) {
                                    setState(() {
                                      selectedTeachers = selected;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  child: Text(
                                    selectedTeachers.isEmpty
                                        ? "Выберите из списка преподавателей"
                                        : selectedTeachers.map((s) => s.username).join(', '),
                                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (selectedTeachers.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedTeachers.map((teacher) {
                                    return Chip(
                                      label: Text(teacher.username),
                                      side: BorderSide(color: Colors.grey.shade500),
                                      backgroundColor: Colors.white,
                                      deleteIcon: Icon(Icons.close, size: 18),
                                      deleteIconColor: Colors.grey.shade500,
                                      onDeleted: () {
                                        setState(() {
                                          selectedTeachers.remove(teacher);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 20),

                              // Привязка группы
                              Text(
                                "Привязать группу",
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () async {
                                  final selected = await showDialog<List<Group>>(
                                    context: context,
                                    builder: (_) => MultiSelectDialog(
                                      items: widget.groups,
                                      initiallySelected: selectedGroups,
                                      itemLabel: (group) => group.name,
                                    ),
                                  );

                                  if (selected != null) {
                                    setState(() {
                                      selectedGroups = selected;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: Colors.grey.shade400, width: 1.5), // чуть ярче при фокусе
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  child: Text(
                                    selectedGroups.isEmpty
                                        ? "Выберите из списка групп"
                                        : selectedGroups.map((s) => s.name).join(', '),
                                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (selectedGroups.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedGroups.map((group) {
                                    return Chip(
                                      label: Text(group.name),
                                      side: BorderSide(color: Colors.grey.shade500),
                                      backgroundColor: Colors.white,
                                      deleteIcon: Icon(Icons.close, size: 18),
                                      deleteIconColor: Colors.grey.shade500,
                                      onDeleted: () {
                                        setState(() {
                                          selectedGroups.remove(group);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
