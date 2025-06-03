import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'dart:math';

import 'package:university_journal/bloc/user/authentication_user.dart';

import '../../../../bloc/journal/group.dart';
import '../../../../bloc/journal/journal_repository.dart';
import '../../../../bloc/user/user.dart';

class AddCourseDialog extends StatefulWidget {
  final VoidCallback onCourseAdded;
  final List<Group> groups;
  final List<MyUser> teachers;

  const AddCourseDialog({super.key, required this.onCourseAdded, required this.groups, required this.teachers});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final groupNameController = TextEditingController();
  List<MyUser> selectedTeachers = [];
  List<Group> selectedGroups = [];
  String? name;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth < 500) return const SizedBox.shrink();
    if (screenHeight < 500) return const SizedBox.shrink();
    // Делаем ширину больше, как на первом скрине, и добавляем большой max
    final dialogWidth = min(800.0, max(420.0, screenWidth * 0.45));
    final dialogHeight = min(1200.0, screenHeight - 60);

    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 60), // Увеличенный отступ справа!
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
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
                    // --- Шапка ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // ВЫРОВНЯТЬ ПО ВЕРХУ!
                      children: [
                        const Expanded(
                          child: Text(
                            'Создание дисциплины',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    List<int> teacherIds = selectedTeachers.map((e) => e.id).toList();
                                    List<int> groupIds = selectedGroups.map((e) => e.id).toList();

                                    bool result = await JournalRepository().addCourse(
                                      name: groupNameController.text,
                                      teacherIds: teacherIds,
                                      groupIds: groupIds,
                                    );

                                    if (result) {
                                      widget.onCourseAdded(); // Чтобы обновить список
                                      Navigator.of(context).pop(); // Закрываем диалог
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
                                  minimumSize: const Size(160, 55),
                                  // <-- высота и ширина!
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
                    // --- Форма ---
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Название дисциплины*',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: groupNameController,
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
                              ),
                              const SizedBox(height: 48),
                              const Text(
                                'Привязка преподавателя',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 18),
                              MultiSelectDialogField<MyUser>(
                                items: widget.teachers
                                    .map((teacher) => MultiSelectItem<MyUser>(teacher, teacher.username))
                                    .toList(),
                                title: const Text("Преподаватели"),
                                selectedColor: Colors.blue,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                ),
                                buttonIcon: const Icon(Icons.group_add),
                                buttonText: const Text("Преподаватели"),
                                onConfirm: (values) {
                                  selectedTeachers = values;
                                },
                                validator: (values) =>
                                (values == null || values.isEmpty) ? 'Выберите хотя бы одного преподавателя' : null,
                              ),
                              const SizedBox(height: 48),
                              const Text(
                                'Привязка группы',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 18),
                              MultiSelectDialogField<Group>(
                                items: widget.groups
                                    .map((group) => MultiSelectItem<Group>(group, group.name))
                                    .toList(),
                                title: const Text("Группы"),
                                selectedColor: Colors.blue,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                ),
                                buttonIcon: const Icon(Icons.group_add),
                                buttonText: const Text("Группы"),
                                onConfirm: (values) {
                                  selectedGroups = values;
                                },
                                validator: (values) =>
                                (values == null || values.isEmpty) ? 'Выберите хотя бы одну группу' : null,
                              )
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

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
    color: const Color(0xFFF3F4F6),
    borderRadius: BorderRadius.circular(11),
    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
    );
  }
}