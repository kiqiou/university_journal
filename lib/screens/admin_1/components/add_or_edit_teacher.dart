import 'dart:math';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:university_journal/components/widgets/button.dart';
import 'package:university_journal/components/widgets/cancel_button.dart';
import 'package:university_journal/screens/admin_1/components/textfield_with_text.dart';

import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/widgets/input_decoration.dart';

class AddAndEditTeacherDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final MyUser? teacher;
  final bool isEdit;

  const AddAndEditTeacherDialog({super.key, required this.onSuccess, required this.isEdit, this.teacher});

  @override
  State<AddAndEditTeacherDialog> createState() => _AddAndEditTeacherDialogState();
}

class _AddAndEditTeacherDialogState extends State<AddAndEditTeacherDialog> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController middleNameController;
  late TextEditingController usernameController;
  late TextEditingController positionController;
  late TextEditingController bioController;

  final _formKey = GlobalKey<FormState>();
  Uint8List? _selectedPhotoBytes;
  String? _photoPreviewUrl;
  String? _photoName;

  @override
  void initState() {
    super.initState();

    firstNameController =
        TextEditingController(text: widget.teacher?.firstName ?? '');
    lastNameController =
        TextEditingController(text: widget.teacher?.lastName ?? '');
    middleNameController =
        TextEditingController(text: widget.teacher?.middleName ?? '');
    usernameController =
        TextEditingController(text: widget.teacher?.username ?? '');
    positionController =
        TextEditingController(text: widget.teacher?.position ?? '');
    bioController =
        TextEditingController(text: widget.teacher?.bio ?? '');

    _photoPreviewUrl = widget.teacher?.photoUrl;
  }

  void _pickImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _selectedPhotoBytes = reader.result as Uint8List;
            _photoPreviewUrl = html.Url.createObjectUrlFromBlob(file);
            _photoName = file.name;
          });
        });
      }
    });
  }

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.isEdit ? 'Редактирование' :
                            'Создание преподавателя',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade700),
                          ),
                        ),
                        MyButton(
                          onChange: () async {
                            final userRepository = UserRepository();

                            if (widget.isEdit) {
                              await userRepository.updateUser(
                                userId: widget.teacher!.id,
                                username: usernameController.text,
                                position: positionController.text,
                                bio: bioController.text,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                middleName: middleNameController.text,
                                photoBytes: _selectedPhotoBytes,
                                photoName: _photoName,
                              );
                            } else {
                              await userRepository.signUp(
                                username: usernameController.text,
                                password: '123456',
                                roleId: 1,
                                position: positionController.text,
                                bio: bioController.text,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                middleName: middleNameController.text,
                                photoBytes: _selectedPhotoBytes,
                                photoName: _photoName,
                              );
                            }

                            widget.onSuccess();
                            Navigator.of(context).pop();
                          },
                          buttonName: 'Сохранить',
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              CancelButton(
                                  onPressed: () => Navigator.of(context).pop()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 260,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _photoPreviewUrl != null
                              ? Image.network(_photoPreviewUrl!)
                              : Icon(Icons.person,
                                  size: 54, color: Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(width: 18),
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4068EA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child:
                                Icon(Icons.add, color: Colors.white, size: 26),
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
                              TextFieldWithText(
                                textController: lastNameController,
                                textFieldName: 'Фамилия*',
                                inputDecorationText: 'Введите фамилию преподавателя',
                              ),

                              TextFieldWithText(
                                textController: firstNameController,
                                textFieldName: 'Имя*',
                                inputDecorationText: 'Введите имя преподавателя',
                              ),

                              TextFieldWithText(
                                textController: middleNameController,
                                textFieldName: 'Отчество*',
                                inputDecorationText: 'Введите отчество преподавателя',
                              ),

                              TextFieldWithText(
                                textController: usernameController,
                                textFieldName: 'Юзернейм*',
                                inputDecorationText: 'Введите юзернейм преподавателя',
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                ],
                              ),

                              TextFieldWithText(
                                textController: positionController,
                                textFieldName: 'Должность*',
                                inputDecorationText: 'Введите должность преподавателя',
                              ),

                              TextFieldWithText(
                                textController: bioController,
                                textFieldName: 'Краткая биография*',
                                inputDecorationText: 'Введите краткую биографию преподавателя',
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
