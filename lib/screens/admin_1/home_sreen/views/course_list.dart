import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../../../bloc/discipline/discipline.dart';
import '../../../../bloc/discipline/discipline_repository.dart';
import '../../../../bloc/group/group.dart';
import '../../../../bloc/user/user.dart';

class CoursesList extends StatefulWidget {
  final Future<void> Function() loadCourses;
  final List<Discipline> courses;
  final List<Group> groups;
  final List<MyUser> teachers;

  const CoursesList({
    super.key,
    required this.loadCourses,
    required this.courses,
    required this.groups,
    required this.teachers,
  });

  @override
  State<CoursesList> createState() => _CoursesList();
}

class _CoursesList extends State<CoursesList> {
  final disciplineRepository = DisciplineRepository();
  final usernameController = TextEditingController();
  final positionController = TextEditingController();
  final bioController = TextEditingController();
  bool isLoading = true;
  bool showDeleteDialog = false;
  bool showEditDialog = false;
  int? selectedIndex;

  final List<Discipline> disciplines = [];
  List<MyUser> selectedTeachers = [];
  List<Group> selectedGroups = [];

  @override
  void initState() {
    super.initState();
    widget.loadCourses;
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.courses;
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
                              'Список дисциплин',
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
                                  child: const Text('Удалить дисциплину',
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
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4068EA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Привязка дисциплины и группы',
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
                                    'Дисциплины',
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
                            itemCount: courses.length,
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
                                            courses[index].name,
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
                                      "Удаление дисциплины",
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
                                  courses[selectedIndex!].name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Вы действительно хотите удалить дисциплину?",
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
                                        final courseId = widget.courses[selectedIndex!].id;
                                        bool success = await disciplineRepository.deleteCourse(courseId: courseId);

                                        if (success) {
                                          await widget.loadCourses();
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
                                                  // final currentCourse = widget.courses.firstWhere((c) => c.id == selectedIndex);
                                                  //
                                                  // final name = usernameController.text.trim().isEmpty
                                                  //     ? currentCourse.name
                                                  //     : usernameController.text.trim();
                                                  //
                                                  // final teacherIds = selectedTeachers.isEmpty
                                                  //     ? currentCourse.teachers
                                                  //     : selectedTeachers.map((e) => e.id).toList();
                                                  //
                                                  // final groupIds = selectedGroups.isEmpty
                                                  //     ? currentCourse.groups
                                                  //     : selectedGroups.map((e) => e.id).toList();
                                                  //
                                                  // final result = await journalRepository.addCourse(
                                                  //   courseId: selectedIndex, // <-- Передаём id для обновления
                                                  //   name: name,
                                                  //   teacherIds: teacherIds,
                                                  //   groupIds: groupIds,
                                                  // );
                                                  //
                                                  // if (result) {
                                                  //   await widget.loadCourses(); // Обновить список
                                                  //   setState(() => showEditDialog = false);
                                                  // } else {
                                                  //   ScaffoldMessenger.of(context).showSnackBar(
                                                  //     const SnackBar(content: Text('❌ Не удалось сохранить изменения')),
                                                  //   );
                                                  // }
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
                                                  SizedBox(
                                                    height: constraints.maxHeight * 0.07,
                                                    child: TextField(
                                                      controller: usernameController,
                                                      decoration: const InputDecoration(
                                                        labelText: "Название дисциплины*",
                                                        hintText: "Введите название дисциплины",
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.03),
                                                  MultiSelectDialogField<MyUser>(
                                                    items: widget.teachers
                                                        .map((teacher) =>
                                                            MultiSelectItem<MyUser>(teacher, teacher.username))
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
                                                    validator: (values) => (values == null || values.isEmpty)
                                                        ? 'Выберите хотя бы одного преподавателя'
                                                        : null,
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
                                                    validator: (values) => (values == null || values.isEmpty)
                                                        ? 'Выберите хотя бы одну группу'
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
