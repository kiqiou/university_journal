import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:html' as html;

import '../../../components/widgets/multiselect.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/widgets/input_decoration.dart';

class TeachersList extends StatefulWidget {
  final Future<void> Function() loadTeachers;
  final Future<void> Function() loadDisciplines;
  final List<MyUser> teachers;
  final List<Discipline> disciplines;

  const TeachersList({
    super.key,
    required this.loadTeachers,
    required this.teachers,
    required this.disciplines,
    required this.loadDisciplines,
  });

  @override
  State<TeachersList> createState() => _TeachersList();
}

class _TeachersList extends State<TeachersList> {
  final userRepository = UserRepository();
  final usernameController = TextEditingController();
  final positionController = TextEditingController();
  final bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? selectedIndex;
  bool isLoading = true;
  bool showDeleteDialog = false;
  bool showEditDialog = false;
  bool showLinkDisciplineDialog = false;
  List<Discipline> selectedDisciplines = [];

  @override
  void initState() {
    super.initState();
    widget.loadTeachers();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const baseScreenWidth = 1920.0;
    const baseButtonHeight = 40.0;
    const baseWidths = [260.0, 290.0, 320.0];
    final scale = screenWidth / baseScreenWidth;
    final buttonHeights = baseButtonHeight * scale;
    final buttonWidths = baseWidths.map((w) => w * scale).toList();
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Основной контент
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          selectedIndex = null;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Список преподавателей',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                              if (selectedIndex != null) ...[
                                SizedBox(
                                  width: buttonWidths[0],
                                  height: buttonHeights,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showDeleteDialog = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4068EA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Удалить преподавателя',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: buttonWidths[1],
                                  height: buttonHeights,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showEditDialog = true;

                                        final selectedTeacher = widget.teachers[selectedIndex!];

                                        usernameController.text = selectedTeacher.username ?? '';
                                        positionController.text = selectedTeacher.position ?? '';
                                        bioController.text = selectedTeacher.bio ?? '';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4068EA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Редактировать информацию',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: buttonWidths[2],
                                  height: buttonHeights,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showLinkDisciplineDialog = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4068EA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Привязка дисциплины',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '№',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade800,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'ФИО преподавателя',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Список преподавателей
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.teachers.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                                selectedDisciplines = widget.teachers[index].disciplines ?? [];
                                              });
                                          },
                                          child: Container(
                                            height: 55,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(22.0),
                                              border: Border.all(
                                                color: selectedIndex == index
                                                    ? const Color(0xFF4068EA)
                                                    : Colors.grey.shade300,
                                                width: 1.4,
                                              ),
                                              color: Colors.white,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Text(
                                              widget.teachers[index].username,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (showDeleteDialog && selectedIndex != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final dialogMaxWidth = 420.0;
                        final dialogMinWidth = 280.0;
                        final availableWidth = MediaQuery.of(context).size.width - 32 - 80;
                        final dialogWidth = availableWidth < dialogMaxWidth
                            ? availableWidth.clamp(dialogMinWidth, dialogMaxWidth)
                            : dialogMaxWidth;

                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            width: dialogWidth,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Удаление преподавателя",
                                      style: TextStyle(fontSize: 18,),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          showDeleteDialog = false;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4068EA),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  widget.teachers[selectedIndex!].username,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Вы действительно хотите удалить преподавателя?",
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4068EA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (selectedIndex != null) {
                                        final userId = widget.teachers[selectedIndex!].id;
                                        bool success = await userRepository.deleteUser(userId: userId);

                                        if (success) {
                                          await widget.loadTeachers();
                                          setState(() {
                                            showDeleteDialog = false;
                                            selectedIndex = null;
                                          });
                                        }
                                      }
                                    },
                                    child: const Text("Удалить", style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Окно редактирования информации
                if (showEditDialog && selectedIndex != null) ...[
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final media = MediaQuery.of(context).size;
                        final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
                        final double dialogHeight = (media.height - 64).clamp(480, 1100);

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

                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            width: dialogWidth,
                            height: dialogHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Color(0xFF4068EA), width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Информация", style: TextStyle(fontSize: 15, color: Colors.grey.shade700),),
                                            const Spacer(),
                                            SizedBox(
                                              height: 36,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF4068EA),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                                ),
                                                onPressed: () async {
                                                  final success = await userRepository.updateUser(
                                                    userId: widget.teachers[selectedIndex!].id,
                                                    username: usernameController.text,
                                                    position: positionController.text,
                                                    bio: bioController.text,
                                                    photoBytes: _selectedPhotoBytes,
                                                    photoName: _photoName,
                                                  );

                                                  if (success) {
                                                    await widget.loadTeachers();
                                                    setState(() {
                                                      selectedIndex = null;
                                                      showEditDialog = false;
                                                    });
                                                  }
                                                },
                                                child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  showEditDialog = false;
                                                });
                                              },
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF4068EA),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(Icons.close, color: Colors.white, size: 22),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 32),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(14),
                                                    child: _photoPreviewUrl != null
                                                        ? Image.network(_photoPreviewUrl!, fit: BoxFit.cover)
                                                        : (widget.teachers[selectedIndex!].photoUrl != null &&
                                                        widget.teachers[selectedIndex!].photoUrl!.isNotEmpty)
                                                        ? Image.network(widget.teachers[selectedIndex!].photoUrl!, fit: BoxFit.cover)
                                                        : const Icon(Icons.person, size: 54, color: Color(0xFF9CA3AF)),
                                                  ),
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
                                                    child: Icon(Icons.add, color: Colors.white, size: 26),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 32),
                                            Form(
                                              key: _formKey,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ФИО преподавателя*',
                                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  TextFormField(
                                                    controller: usernameController,
                                                    decoration: textInputDecoration('Введите ФИО преподавателя'),
                                                  ),
                                                  const SizedBox(height: 48),
                                                  Text(
                                                    'Пасада',
                                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  TextFormField(
                                                    decoration: textInputDecoration('Введите пасаду'),
                                                    controller: positionController,
                                                  ),
                                                  const SizedBox(height: 48),
                                                  Text(
                                                    'Краткая биография',
                                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  TextFormField(
                                                    decoration: textInputDecoration('Введите краткую биографию'),
                                                    maxLines: 2,
                                                    controller: bioController,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                if (showLinkDisciplineDialog && selectedIndex != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final media = MediaQuery.of(context).size;
                        final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
                        final double dialogHeight = (media.height - 64).clamp(480, 550);

                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            width: dialogWidth,
                            height: dialogHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Color(0xFF4068EA), width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // constraints.maxWidth == dialogWidth, constraints.maxHeight == dialogHeight
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Привязка дисциплины",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey.shade800,
                                                fontSize: 17,
                                              ),
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              height: 36,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF4068EA),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                                ),
                                                  onPressed: () async {
                                                    final currentTeacher = widget.teachers[selectedIndex!];
                                                    final disciplineIds = selectedDisciplines.map((d) => d.id).toList();

                                                    final success = await userRepository.updateTeacherDisciplines(
                                                      teacherId: currentTeacher.id,
                                                      disciplineIds: disciplineIds,
                                                    );

                                                    if (success) {
                                                      await widget.loadDisciplines();

                                                      setState(() {
                                                        showLinkDisciplineDialog = false;
                                                        selectedIndex = null;
                                                      });
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('❌ Не удалось обновить дисциплины')),
                                                      );
                                                    }
                                                  },
                                                  child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  showLinkDisciplineDialog = false;
                                                });
                                              },
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF4068EA),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: constraints.maxHeight * 0.03),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 20),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final selected = await showDialog<List<Discipline>>(
                                                      context: context,
                                                      builder: (_) => MultiSelectDialog(
                                                        items: widget.disciplines,
                                                        initiallySelected: selectedDisciplines,
                                                        itemLabel: (discipline) => discipline.name,
                                                      ),
                                                    );

                                                    if (selected != null) {
                                                      setState(() {
                                                        selectedDisciplines = selected;
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
                                                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5), // чуть ярче при фокусе
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                    ),
                                                    child: Text(
                                                      selectedDisciplines.isEmpty
                                                          ? "Выберите из списка дисциплин"
                                                          : selectedDisciplines.map((s) => s.name).join(', '),
                                                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                if (selectedDisciplines.isNotEmpty)
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    alignment: WrapAlignment.start,
                                                    children: selectedDisciplines.map((discipline) {
                                                      return Chip(
                                                        label: Text(discipline.name),
                                                        side: BorderSide(color: Colors.grey.shade500),
                                                        backgroundColor: Colors.white,
                                                        deleteIcon: Icon(Icons.close, size: 18),
                                                        deleteIconColor: Colors.grey.shade500,
                                                        onDeleted: () {
                                                          setState(() {
                                                            selectedDisciplines.remove(discipline);
                                                          });
                                                        },
                                                      );
                                                    }).toList(),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
