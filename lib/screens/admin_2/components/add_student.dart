import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';
import 'package:university_journal/components/widgets/cancel_button.dart';
import 'dart:math';

import '../../../../components/colors/colors.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/user_repository.dart';

class AddStudentDialog extends StatefulWidget {
  final VoidCallback onStudentAdded;
  final List<GroupSimple> groups;
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
  GroupSimple? selectedGroup;
  String? fio;
  String? group;
  bool isHeadman = false;

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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Создание студента',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                          ),
                        ),
                        Row(children: [
                          MyButton(onChange: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final authRepository = UserRepository();

                              await authRepository.signUp(
                                username: fio ?? '',
                                password: '123456',
                                roleId: 5,
                                groupId: selectedGroup?.id,
                                isHeadman: isHeadman,
                              );
                              widget.onSave(fio ?? '', group);
                              widget.onStudentAdded();
                              Navigator.of(context).pop();
                            }
                          }, buttonName: 'Сохранить'),
                          SizedBox(width: 12,),
                          CancelButton(onPressed:  () => Navigator.of(context).pop(),),
                        ],),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              DropdownButtonFormField<GroupSimple>(
                                items: widget.groups
                                    .map((group) => DropdownMenuItem<GroupSimple>(
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
                                onChanged: (GroupSimple? value) {
                                  setState(() {
                                    selectedGroup = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Отметить как старосту',
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      value: isHeadman,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          isHeadman = newValue ?? false;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      activeColor: MyColors.blueJournal,
                                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isHeadman ? 'Да' : 'Нет',
                                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                  ),
                                ],
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
}