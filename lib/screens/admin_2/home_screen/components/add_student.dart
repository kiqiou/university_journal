import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../bloc/group/group.dart';
import '../../../../bloc/user/user_repository.dart';
import '../../../../components/colors/colors.dart';

class AddStudentDialog extends StatefulWidget {
  final VoidCallback onStudentAdded;
  final List<Group> groups;
  final void Function(String studentName, String? group) onSave;

  const AddStudentDialog({
    super.key,
    required this.onStudentAdded,
    required this.onSave, required this.groups,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  Group? selectedGroup;
  String? fio;
  String? group;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth < 500) return const SizedBox.shrink();
    if (screenHeight < 500) return const SizedBox.shrink();

    final dialogWidth = min(800.0, max(420.0, screenWidth * 0.45));
    final dialogHeight = min(1200.0, screenHeight - 60);

    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 60),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Создание студента',
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
                                    _formKey.currentState!.save();
                                    final authRepository = UserRepository();

                                    await authRepository.signUp(
                                      username: fio ?? '',
                                      password: '123456',
                                      roleId: 5,
                                      groupId: selectedGroup?.id,
                                    );
                                    widget.onSave(fio ?? '', group);
                                    widget.onStudentAdded();
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
                                  minimumSize: const Size(160, 55),
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
                    const SizedBox(height: 25),
                    // --- Форма ---
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Поле ФИО студента*
                              Text(
                                'ФИО студента*',
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                    decoration:   InputDecoration(
                                      hintText: 'Введите ФИО студента',
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
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Введите ФИО студента' : null,
                                onSaved: (value) => fio = value,
                              ),
                              const SizedBox(height: 48),
                              // Поле "Привязать группу"
                              Text(
                                'Привязка группы',
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              DropdownButtonFormField<Group>(
                                items: widget.groups
                                    .map((group) => DropdownMenuItem<Group>(
                                  value: group,
                                  child: Text(group.name),
                                ))
                                    .toList(),
                                decoration: InputDecoration(
                                  labelText: 'Группа',
                                  labelStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: MyColors.blueJournal, width: 1.5),
                                  ),
                                ),
                                value: selectedGroup,
                                onChanged: (Group? value) {
                                  setState(() {
                                    selectedGroup = value!;
                                  });
                                },
                                validator: (value) =>
                                value == null ? 'Выберите одну группу' : null,
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
}