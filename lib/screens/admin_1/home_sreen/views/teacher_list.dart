import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../../../bloc/discipline/discipline.dart';
import '../../../../bloc/discipline/discipline_repository.dart';
import '../../../../bloc/user/user.dart';
import '../../../../bloc/user/user_repository.dart';

class TeachersList extends StatefulWidget{
  final Future<void> Function() loadTeachers;
  final Future<void> Function() loadDisciplines;
  final List<MyUser> teachers;
  final List<Discipline> disciplines;
  const TeachersList({super.key, required this.loadTeachers,required this.teachers, required this.disciplines, required this.loadDisciplines,});


  @override
  State<TeachersList> createState() => _TeachersList();
}

class _TeachersList extends State<TeachersList>{
  final userRepository = UserRepository();
  int? selectedIndex;
  bool isLoading = true;
  bool showDeleteDialog = false;
  bool showEditDialog = false;
  bool showLinkDisciplineDialog = false;
  List<Discipline> selectedDisciplines = [];

  final usernameController = TextEditingController();
  final positionController = TextEditingController();
  final bioController = TextEditingController();

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
                                  child: const Text('Удалить преподавателя', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4068EA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Редактировать информацию', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                  child:
                                  const Text('Привязка дисциплины и группы', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                // Окно удаления преподавателя
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
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                if (showEditDialog && selectedIndex != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final media = MediaQuery.of(context).size;
                        final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
                        final double dialogHeight = (media.height - 64).clamp(480, 1100);

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
                                            const Text(
                                              "Информация",
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                                                  final success = await userRepository.updateUser(
                                                    userId: widget.teachers[selectedIndex!].id,
                                                    username: usernameController.text,
                                                    position: positionController.text,
                                                    bio: bioController.text,
                                                  );

                                                  if (success) {
                                                    setState(() async {
                                                      await widget.loadTeachers();
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
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Аватар
                                            Column(
                                              children: [
                                                Container(
                                                  width: constraints.maxWidth * 0.15,
                                                  height: constraints.maxWidth * 0.19,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(Icons.person, size: 48, color: Colors.grey),
                                                ),
                                                SizedBox(height: constraints.maxHeight * 0.01 + 4),
                                                InkWell(
                                                  onTap: () {},
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF4068EA),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: constraints.maxWidth * 0.07),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: constraints.maxHeight * 0.07,
                                                    child: TextField(
                                                      controller: usernameController,
                                                      decoration: const InputDecoration(
                                                        labelText: "ФИО преподавателя*",
                                                        hintText: "Введите ФИО преподавателя",
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.03),
                                                  SizedBox(
                                                    height: constraints.maxHeight * 0.07,
                                                    child: TextField(
                                                      controller: positionController,
                                                      decoration: const InputDecoration(
                                                        labelText: "Должность",
                                                        hintText: "Введите должность",
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.03),
                                                  SizedBox(
                                                    height: constraints.maxHeight * 0.11,
                                                    child: TextField(
                                                      controller: bioController,
                                                      maxLines: 2,
                                                      inputFormatters: [LengthLimitingTextInputFormatter(250),],
                                                      decoration: const InputDecoration(
                                                        labelText: "Краткая биография",
                                                        hintText: "Введите краткую биографию",
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
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
                if (showLinkDisciplineDialog && selectedIndex != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final media = MediaQuery.of(context).size;
                        final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
                        final double dialogHeight = (media.height - 64).clamp(480, 1100);

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
                                              "Информация",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey.shade800,
                                                fontSize: 16,
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
                                                  debugPrint("selectedIndex: $selectedIndex");
                                                  debugPrint("widget.teachers ids: ${widget.teachers.map((t) => t.id).toList()}");

                                                  final disciplineRepository = DisciplineRepository();
                                                  final currentTeacher = (selectedIndex! < widget.teachers.length)
                                                      ? widget.teachers[selectedIndex!]
                                                      : null;

                                                  final disciplinesIds = selectedDisciplines.isEmpty
                                                      ? currentTeacher?.disciplines.map((d) => d.id).toList()
                                                      : selectedDisciplines.map((e) => e.id).toList();

                                                  bool allSuccess = true;
                                                  for (final disciplineId in disciplinesIds!) {
                                                    final result = await disciplineRepository.updateCourse(
                                                      courseId: disciplineId,
                                                      teacherIds: [currentTeacher!.id],
                                                      appendTeachers: true,
                                                    );
                                                    if (!result) {
                                                      allSuccess = false;
                                                    }
                                                  }

                                                  if (allSuccess) {
                                                    await widget.loadDisciplines();

                                                    setState(() {
                                                      showLinkDisciplineDialog = false;
                                                      selectedIndex = null;
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('❌ Некоторые дисциплины не удалось привязать')),
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
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  MultiSelectDialogField<Discipline>(
                                                    items: widget.disciplines
                                                        .map((discipline) =>
                                                        MultiSelectItem<Discipline>(discipline, discipline.name))
                                                        .toList(),
                                                    title: Text("Дисциплины", style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                    ),),
                                                    selectedColor: Colors.blue,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF3F4F6),
                                                      borderRadius: BorderRadius.circular(11),
                                                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                                                    ),
                                                    buttonIcon: const Icon(Icons.group_add),
                                                    buttonText: const Text("Дисциплины"),
                                                    onConfirm: (values) {
                                                      selectedDisciplines = values;
                                                    },
                                                    validator: (values) => (values == null || values.isEmpty)
                                                        ? 'Выберите хотя бы одну дисциплину'
                                                        : null,
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
            ),
          ),
        ],
      ),
    );
  }
}