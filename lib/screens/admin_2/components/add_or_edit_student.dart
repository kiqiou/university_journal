import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:university_journal/components/widgets/button.dart';
import 'package:university_journal/components/widgets/cancel_button.dart';
import 'package:university_journal/screens/admin_1/components/textfield_with_text.dart';
import 'dart:math';

import '../../../../components/colors/colors.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';

class AddAndEditStudentDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final List<SimpleGroup> groups;
  final MyUser? student;
  final bool isEdit;

  const AddAndEditStudentDialog({
    super.key,
    required this.onSuccess, required this.groups, required this.isEdit, this.student,
  });

  @override
  State<AddAndEditStudentDialog> createState() => _AddAndEditStudentDialogState();
}

class _AddAndEditStudentDialogState extends State<AddAndEditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController middleNameController;
  late TextEditingController usernameController;
  SimpleGroup? selectedGroup;
  String? fio;
  String? group;
  bool isHeadman = false;

  @override
  void initState() {
    super.initState();

    firstNameController =
        TextEditingController(text: widget.student?.firstName ?? '');
    lastNameController =
        TextEditingController(text: widget.student?.lastName ?? '');
    middleNameController =
        TextEditingController(text: widget.student?.middleName ?? '');
    usernameController =
        TextEditingController(text: widget.student?.username ?? '');

    if (widget.isEdit && widget.student?.group != null) {
      selectedGroup = widget.groups.firstWhere(
            (g) => g.id == widget.student!.group!.id,
        orElse: () => widget.groups.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                            widget.isEdit ? 'Создание студента': 'Редактирование студента',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                          ),
                        ),
                        Row(children: [
                          MyButton(onChange: () async {
                            final userRepository = UserRepository();

                            if (widget.isEdit) {
                              await userRepository.updateUser(
                                userId: widget.student!.id,
                                username: usernameController.text,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                middleName: middleNameController.text,
                              );
                            } else {
                              await userRepository.signUp(
                                username: fio ?? '',
                                password: '123456',
                                roleId: 5,
                                groupId: selectedGroup?.id,
                                isHeadman: isHeadman,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                middleName: middleNameController.text,
                              );
                            }
                            widget.onSuccess();
                            Navigator.of(context).pop();
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
                              TextFieldWithText(
                                textController: lastNameController,
                                textFieldName: 'Фамилия*',
                                inputDecorationText: 'Введите фамилию студента',
                              ),

                              TextFieldWithText(
                                textController: firstNameController,
                                textFieldName: 'Имя*',
                                inputDecorationText: 'Введите имя студента',
                              ),

                              TextFieldWithText(
                                textController: middleNameController,
                                textFieldName: 'Отчество*',
                                inputDecorationText: 'Введите отчество студента',
                              ),

                              TextFieldWithText(
                                textController: usernameController,
                                textFieldName: 'Юзернейм*',
                                inputDecorationText: 'Введите юзернейм студента',
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                ],
                              ),
                              Text(
                                'Привязка группы',
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              DropdownButtonFormField<SimpleGroup>(
                                initialValue: selectedGroup,
                                value: selectedGroup,
                                items: widget.groups
                                    .map((group) => DropdownMenuItem<SimpleGroup>(
                                  value: group,
                                  child: Text(group.name),
                                ))
                                    .toList(),
                                onChanged: (SimpleGroup? value) {
                                  setState(() {
                                    selectedGroup = value;
                                  });
                                },
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