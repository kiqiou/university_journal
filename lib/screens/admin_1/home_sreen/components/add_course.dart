import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'dart:math';

import '../../../../bloc/discipline/discipline.dart';
import '../../../../bloc/discipline/discipline_repository.dart';
import '../../../../bloc/group/group.dart';
import '../../../../bloc/user/user.dart';

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
        padding: const EdgeInsets.only(right: 0),
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
                        const Expanded(
                          child: Text(
                            'Создание дисциплины',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    widget.onCourseAdded();
                                    Navigator.of(context).pop();
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
                              const Text(
                                'Название дисциплины',
                                style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: 'Введите название дисциплины',
                                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                  filled: true,
                                  fillColor: const Color(0xFFF3F4F6),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                  ),
                                ),
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Обязательное поле' : null,
                              ),
                              const SizedBox(height: 24),

                              // Виды занятий
                              const Text(
                                'Выберите вид занятий',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 10),
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
                                          color: isSelected ? const Color(0xFF4068EA) : const Color(0xFFE5E7EB),
                                          width: 2,
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
                              if (selectedLessonTypes.contains('Лекции') || selectedLessonTypes.contains('Лабораторные'))
                                Row(
                                  children: [
                                    if (selectedLessonTypes.contains('Лекции'))
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(22),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Лекции*', style: TextStyle(fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: lectureHoursController,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: 'Введите часы',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                validator: (value) {
                                                  if (selectedLessonTypes.contains('Лекции') && (value == null || value.isEmpty)) {
                                                    return 'Обязательное поле';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (selectedLessonTypes.contains('Лабораторные'))
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 12),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(22),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Лабораторные*', style: TextStyle(fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: labHoursController,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: 'Введите часы',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                validator: (value) {
                                                  if (selectedLessonTypes.contains('Лабораторные') && (value == null || value.isEmpty)) {
                                                    return 'Обязательное поле';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                              // Привязка преподавателя
                              const Text("Привязать преподавателя"),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<MyUser>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: teacherError ? Colors.red : Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                hint: const Text("Выберите из списка преподавателя"),
                                value: selectedTeachers.isNotEmpty ? selectedTeachers.first : null,
                                items: widget.teachers
                                    .map((t) => DropdownMenuItem<MyUser>(
                                  value: t,
                                  child: Text(t.username),
                                ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedTeachers = val != null ? [val] : [];
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Обязательное поле. Выберите хотя бы одного преподавателя.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              if (selectedTeachers.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  children: selectedTeachers.map((teacher) {
                                    return Chip(
                                      label: Text(teacher.username),
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
                              const Text("Привязать группу"),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<Group>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: groupError ? Colors.red : Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                hint: const Text("Выберите из списка группу"),
                                value: selectedGroups.isNotEmpty ? selectedGroups.first : null,
                                items: widget.groups
                                    .map((g) => DropdownMenuItem<Group>(
                                  value: g,
                                  child: Text(g.name),
                                ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedGroups = val != null ? [val] : [];
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Обязательное поле. Выберите хотя бы одну группу.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              if (selectedGroups.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedGroups.map((group) {
                                    return Chip(
                                      label: Text(group.name),
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

