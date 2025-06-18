import 'dart:math';
import 'package:flutter/material.dart';
import 'package:university_journal/bloc/group/group_repository.dart';

import '../../../../bloc/user/user.dart';
import '../../../../components/colors/colors.dart';
import '../../../../components/multiselect.dart';

class AddGroupDialog extends StatefulWidget {
  final VoidCallback onGroupAdded;
  final List<MyUser> students;

  const AddGroupDialog({
    super.key,
    required this.onGroupAdded,
    required this.students,
  });

  @override
  State<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  List<MyUser> selectedStudents = [];
  int? selectedCourseIndex;
  int? selectedFacultyIndex;

  final List<String> _courses = ['1 курс', '2 курс', '3 курс', '4 курс'];
  final List<String> _faculties = ['Экономический', 'Юридический'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth < 500 || screenHeight < 500) return const SizedBox.shrink();

    final dialogWidth = min(800.0, max(420.0, screenWidth * 0.45));

    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 60),
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: dialogWidth,
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
                child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Заголовок и кнопка закрытия ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Добавить группу',
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                            ),
                          ),
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  List<int> studentsIds = selectedStudents.map((e) => e.id).toList();
                                  int facultyId = selectedFacultyIndex! + 1;
                                  int courseId = selectedCourseIndex! + 1;

                                  final groupRepository = GroupRepository();
                                  final result = await groupRepository.addGroup(
                                      name: nameController.text,
                                      studentIds: studentsIds,
                                      courseId: courseId,
                                      facultyId: facultyId);

                                  if (result) {
                                    widget.onGroupAdded();
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('❌ Не удалось добавить группу')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4068EA),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                minimumSize: const Size.fromHeight(55),
                              ),
                              child: const Text('Сохранить', style: TextStyle(fontSize: 16)),
                            ),
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
                      const SizedBox(height: 28),
                      // --- Форма ---
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Название группы
                                Text(
                                  'Введите название группы',
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      hintText: 'Введите название группы',
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
                                    )),
                                const SizedBox(height: 28),
                                Text(
                                  'Выберите факультет',
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 18),
                                DropdownButtonFormField<int>(
                                  value: selectedFacultyIndex,
                                  decoration: InputDecoration(
                                    labelText: 'Факультет',
                                    labelStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                    filled: true,
                                    fillColor: Colors.white,
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
                                      borderSide: BorderSide(color: MyColors.blueJournal, width: 1.5),
                                    ),
                                  ),
                                  items: List.generate(_faculties.length, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text(
                                        _faculties[index],
                                        style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFacultyIndex = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Выберите курс';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 28),
                                // Выбор курса
                                Text(
                                  'Выберите курс',
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 18),
                                DropdownButtonFormField<int>(
                                  value: selectedCourseIndex,
                                  decoration: InputDecoration(
                                    labelText: 'Курс',
                                    labelStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                    filled: true,
                                    fillColor: Colors.white,
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
                                      borderSide: BorderSide(color: MyColors.blueJournal, width: 1.5),
                                    ),
                                  ),
                                  items: List.generate(_courses.length, (index) {
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text(
                                        _courses[index],
                                        style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCourseIndex = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Выберите курс';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  'Выберите студентов',
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 18),
                                GestureDetector(
                                  onTap: () async {
                                    final selected = await showDialog<List<MyUser>>(
                                      context: context,
                                      builder: (_) => MultiSelectDialog(
                                        items: widget.students,
                                        initiallySelected: selectedStudents,
                                        itemLabel: (user) => user.username,
                                      ),
                                    );

                                    if (selected != null) {
                                      setState(() {
                                        selectedStudents = selected;
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
                                      selectedStudents.isEmpty
                                          ? "Выберите из списка студента"
                                          : selectedStudents.map((s) => s.username).join(', '),
                                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                if (selectedStudents.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: selectedStudents.map((teacher) {
                                      return Chip(
                                        label: Text(teacher.username),
                                        side: BorderSide(color: Colors.grey.shade500),
                                        backgroundColor: Colors.white,
                                        deleteIcon: Icon(Icons.close, size: 18),
                                        deleteIconColor: Colors.grey.shade500,
                                        onDeleted: () {
                                          setState(() {
                                            selectedStudents.remove(teacher);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
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

  // Оформление полей
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }
}
