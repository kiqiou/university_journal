import 'dart:math';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';
import 'package:university_journal/components/widgets/cancel_button.dart';

import '../../../bloc/services/user/user_repository.dart';
import '../../../components/colors/colors.dart';
import '../../../components/widgets/input_decoration.dart';

class AddTeacherDialog extends StatefulWidget {
  final VoidCallback onTeacherAdded;

  const AddTeacherDialog({super.key, required this.onTeacherAdded});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  String? fio;
  String? position;
  String? bio;
  Uint8List? _selectedPhotoBytes;
  String? _photoPreviewUrl;
  String? _photoName;

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
                            'Создание преподавателя',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade700),
                          ),
                        ),
                        MyButton(
                            onChange: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final userRepository = UserRepository();

                                await userRepository.signUp(
                                  username: fio ?? '',
                                  password: '123456',
                                  roleId: 1,
                                  position: position,
                                  bio: bio,
                                  photoBytes: _selectedPhotoBytes,
                                  photoName: _photoName,
                                );
                                widget.onTeacherAdded();
                                Navigator.of(context).pop();
                              }
                            },
                            buttonName: 'Сохранить'),
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
                              Text(
                                'ФИО преподавателя*',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                decoration: textInputDecoration(
                                    'Введите ФИО преподавателя'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Введите ФИО преподавателя'
                                        : null,
                                onSaved: (value) => fio = value,
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Пасада',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                decoration:
                                    textInputDecoration('Введите пасаду'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Введите пасаду преподавателя'
                                        : null,
                                onSaved: (value) => position = value,
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Краткая биография',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                decoration: textInputDecoration(
                                    'Введите краткую биографию'),
                                maxLines: 2,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Введите биографию преподавателя'
                                        : null,
                                onSaved: (value) => bio = value,
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
