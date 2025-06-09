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
  final List<Discipline> disciplines;
  final List<Group> groups;
  final List<MyUser> teachers;

  const CoursesList({
    super.key,
    required this.loadCourses,
    required this.disciplines,
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
  final TextEditingController lectureHoursController = TextEditingController();
  final TextEditingController labHoursController = TextEditingController();
  bool isLoading = true;
  bool showDeleteDialog = false;
  bool showEditDialog = false;
  int? selectedIndex;

  final List<Discipline> disciplines = [];
  List<MyUser> selectedTeachers = [];
  List<Group> selectedGroups = [];
  List<MyUser> selectedTeachers2 = [];
  List<String> selectedTypes = [];
  List<String> selectedLessonTypes = [];

  bool nameError = false;
  bool teacherError = false;
  bool groupError = false;
  bool lecturesError = false;


  @override
  void initState() {
    super.initState();
    widget.loadCourses;
  }
  void dispose() {
    lectureHoursController.dispose();
    labHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.disciplines;
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
                                            selectedIndex = index; // ✅ id дисциплины
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
                                        final courseId = widget.disciplines[selectedIndex!].id;
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
                if (showEditDialog)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double dialogWidth = 600;
                        double dialogMaxHeight = constraints.maxHeight - 48;
                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            width: dialogWidth,
                            constraints: BoxConstraints(
                              maxHeight: dialogMaxHeight,
                              minHeight: 200,
                            ),
                            margin: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 32,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Верхняя панель
                                    Row(
                                      children: [
                                        const Text(
                                          "Редактирование дисциплины",
                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                                        ),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: () async {
                                            setState(() {
                                              nameError = usernameController.text.trim().isEmpty;
                                              //lecturesError = lecturesController.text.trim().isEmpty;
                                              teacherError = selectedTeachers.length != 1;
                                              groupError = selectedGroups.length != 1;
                                            });
                                            if (!nameError && !lecturesError && !teacherError && !groupError) {
                                              // TODO: Сохранить изменения
                                              setState(() {
                                                showEditDialog = false;
                                              });
                                            }
                                            final currentCourse = widget.disciplines.firstWhere((c) => c.id == selectedIndex);

                                            final name = usernameController.text.trim().isEmpty
                                                ? currentCourse.name
                                                : usernameController.text.trim();

                                            List<int> teacherIds = selectedTeachers.map((e) => e.id).toList();
                                            List<int> groupIds = selectedGroups.map((e) => e.id).toList();

                                            final disciplineRepository = DisciplineRepository();
                                            final result = await disciplineRepository.updateCourse(
                                              courseId: selectedIndex,
                                              name: name,
                                              teacherIds: teacherIds,
                                              groupIds: groupIds,
                                              appendTeachers: false,
                                            );

                                            if (result) {
                                              await widget.loadCourses();
                                              setState(() => showEditDialog = false);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('❌ Не удалось сохранить изменения')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF4068EA),
                                            minimumSize: const Size(130, 52),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text("Сохранить", style: TextStyle(fontSize: 19, color: Colors.white)),
                                        ),
                                        const SizedBox(width: 16),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              showEditDialog = false;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            width: 54,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4068EA),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),

                                    // Название дисциплины
                                    const Text("Название дисциплины*"),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: usernameController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: nameError ? Colors.red : Colors.grey,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                        errorText: nameError ? 'Обязательное поле' : null,
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // Виды занятий
                                    const Text("Выберите вид занятий*"),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 18,
                                      runSpacing: 14,
                                      children: [
                                        ...[
                                          {'key': 'lecture', 'label': 'Лекции'},
                                          {'key': 'seminar', 'label': 'Семинар'},
                                          {'key': 'practice', 'label': 'Практика'},
                                          {'key': 'lab', 'label': 'Лабораторные'},
                                          {'key': 'current', 'label': 'Текущая аттестация'},
                                          {'key': 'final', 'label': 'Промежуточная аттестация'},
                                        ].map((type) {
                                          final isSelected = selectedTypes.contains(type['key']);
                                          return IntrinsicWidth(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    selectedTypes.remove(type['key']);
                                                  } else {
                                                    selectedTypes.add(type['key']!);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                height: 48,
                                                margin: const EdgeInsets.symmetric(vertical: 2),
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? const Color(0xFF4068EA) : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected ? const Color(0xFF4068EA) : Colors.grey.shade300,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (isSelected)
                                                      const Icon(Icons.check, color: Colors.white, size: 22),
                                                    if (isSelected) const SizedBox(width: 6),
                                                    Text(
                                                      type['label']!,
                                                      style: TextStyle(
                                                        color: isSelected ? Colors.white : Colors.black87,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                      ],
                                    ),
                                    const SizedBox(height: 28),

                                    // Часы
                                    // Часы
                                    if (selectedTypes.contains('lecture') || selectedTypes.contains('lab'))
                                      Row(
                                        children: [
                                          if (selectedTypes.contains('lecture'))
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(right: 12),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(22),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Лекции*', style: TextStyle(fontWeight: FontWeight.w500)),
                                                    const SizedBox(height: 8),
                                                    TextFormField(
                                                      controller: lectureHoursController,
                                                      keyboardType: TextInputType.number,
                                                      decoration: InputDecoration(
                                                        hintText: 'Введите часы',
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                          borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
                                                        ),
                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      validator: (value) {
                                                        if (selectedTypes.contains('lecture') && (value == null || value.isEmpty)) {
                                                          return 'Обязательное поле';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          if (selectedTypes.contains('lab'))
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(left: 12),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(22),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Лабораторные*', style: TextStyle(fontWeight: FontWeight.w500)),
                                                    const SizedBox(height: 8),
                                                    TextFormField(
                                                      controller: labHoursController,
                                                      keyboardType: TextInputType.number,
                                                      decoration: InputDecoration(
                                                        hintText: 'Введите часы',
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                          borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
                                                        ),
                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      validator: (value) {
                                                        if (selectedTypes.contains('lab') && (value == null || value.isEmpty)) {
                                                          return 'Обязательное поле';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                    // Преподаватель 1
                                    const Text("Привязать преподавателя"),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Выберите одного преподавателя и выберите одну группу",
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<MyUser>(
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: teacherError ? Colors.red : Colors.grey,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        errorText: teacherError ? 'Обязательное поле. Выберите хотя бы одного преподавателя.' : null,
                                      ),
                                      hint: const Text("Выберите из списка преподавателя"),
                                      value: selectedTeachers.isNotEmpty ? selectedTeachers.first : null,
                                      items: widget.teachers
                                          .map((t) => DropdownMenuItem<MyUser>(
                                        value: t,
                                        child: Text(t.username),
                                      ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedTeachers = val != null ? [val] : [];
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    if (selectedTeachers.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        children: selectedTeachers.map((teacher) {
                                          return Chip(
                                            label: Text(teacher.username),
                                            onDeleted: () {
                                              setState(() {
                                                selectedTeachers.remove(teacher);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    const SizedBox(height: 20),

                                    // Группа
                                    const Text("Привязать группу"),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<Group>(
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: groupError ? Colors.red : Colors.grey,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        errorText: groupError ? 'Обязательное поле. Выберите хотя бы одну группу.' : null,
                                      ),
                                      hint: const Text("Выберите из списка группу"),
                                      value: selectedGroups.isNotEmpty ? selectedGroups.first : null,
                                      items: widget.groups
                                          .map((g) => DropdownMenuItem<Group>(
                                        value: g,
                                        child: Text(g.name),
                                      ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedGroups = val != null ? [val] : [];
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    if (selectedGroups.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: selectedGroups.map((group) {
                                          return Chip(
                                            label: Text(group.name),
                                            onDeleted: () {
                                              setState(() {
                                                selectedGroups.remove(group);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
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
