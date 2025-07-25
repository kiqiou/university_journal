import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../components/colors/colors.dart';
import '../../../components/constants/constants.dart';
import '../../../components/widgets/multiselect.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/discipline_repository.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/models/user.dart';

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
  final nameController = TextEditingController();
  final TextEditingController lectureHoursController = TextEditingController();
  final TextEditingController labHoursController = TextEditingController();
  final Map<String, TextEditingController> hoursControllers = {};
  final List<Discipline> disciplines = [];
  List<MyUser> selectedTeachers = [];
  List<Group> selectedGroups = [];
  List<String> selectedTypes = [];
  List<String> selectedLessonTypes = [];
  bool isLoading = true;
  bool? isGroupSplit;
  bool showDeleteDialog = false;
  bool showEditDialog = false;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    widget.loadCourses;
    for (var type in lessonTypeOptions) {
      hoursControllers[type['key']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    lectureHoursController.dispose();
    labHoursController.dispose();
    for (final controller in hoursControllers.values) {
      controller.dispose();
    }
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
                                        nameController.text = widget.disciplines[selectedIndex!].name;
                                        selectedGroups = widget.disciplines[selectedIndex!].groups;
                                        selectedTeachers = widget.disciplines[selectedIndex!].teachers;
                                        isGroupSplit =  widget.disciplines[selectedIndex!].isGroupSplit;
                                        selectedTypes.clear();
                                        hoursControllers.clear();

                                        for (final item in widget.disciplines[selectedIndex!].planItems) {
                                          final type = item.type;
                                          selectedTypes.add(type);
                                          hoursControllers[type] = TextEditingController(text: item.hoursAllocated.toString());
                                        }
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
                                      "Удаление дисциплины",
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
                                        bool success = await disciplineRepository.deleteDiscipline(courseId: courseId);

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
                                    Row(
                                      children: [
                                        Text(
                                          "Редактирование дисциплины",
                                          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                        ),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final planItems = selectedTypes
                                                .where((key) => hoursControllers[key]?.text.isNotEmpty == true)
                                                .map((key) {
                                              final allocatedHours = int.tryParse(hoursControllers[key]!.text) ?? 0;
                                              final hoursPerSession = 2;

                                              return {
                                                'type': key,
                                                'hours_allocated': allocatedHours,
                                                'hours_per_session': hoursPerSession,
                                              };
                                            }).toList();

                                            final currentCourse = widget.disciplines[selectedIndex!];

                                            final name = nameController.text.trim().isEmpty
                                                ? currentCourse.name
                                                : nameController.text.trim();

                                            List<int> teacherIds = selectedTeachers.map((e) => e.id).toList();
                                            List<int> groupIds = selectedGroups.map((e) => e.id).toList();

                                            final disciplineRepository = DisciplineRepository();
                                            final result = await disciplineRepository.updateDiscipline(
                                              courseId: currentCourse.id,
                                              name: name,
                                              teacherIds: teacherIds,
                                              groupIds: groupIds,
                                              planItems: planItems,
                                              appendTeachers: false,
                                              isGroupSplit: isGroupSplit,
                                            );

                                            if (result) {
                                              await widget.loadCourses();
                                              setState(() {
                                                selectedIndex = null;
                                                showEditDialog = false;
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('❌ Не удалось сохранить изменения')),
                                              );
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
                                            minimumSize: const Size(140, 48),
                                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                          child: const Text(
                                            "Сохранить",
                                          ),
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
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4068EA),
                                              borderRadius: BorderRadius.circular(12),
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
                                    Text(
                                      "Название дисциплины*",
                                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        hintText: 'Введите название дисциплины',
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
                                      validator: (value) => value == null || value.isEmpty ? 'Обязательное поле' : null,
                                    ),
                                    const SizedBox(height: 28),
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 2,
                                          child: Checkbox(
                                            value: isGroupSplit,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isGroupSplit = value;
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
                                        Expanded(
                                          child: Text(
                                            'Разделение на подгруппы',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 28),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Выберите вид занятий*",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 18,
                                          runSpacing: 14,
                                          children: lessonTypeOptions.map((type) {
                                            final isSelected =
                                            selectedTypes.contains(type['key']);
                                            return IntrinsicWidth(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    final key = type['key']!;
                                                    if (isSelected) {
                                                      selectedTypes.remove(key);
                                                      hoursControllers.remove(key);
                                                    } else {
                                                      selectedTypes.add(key);
                                                      hoursControllers[key] = TextEditingController();
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  height: 48,
                                                  margin: const EdgeInsets.symmetric(
                                                      vertical: 2),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                    BorderRadius.circular(14),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      AnimatedContainer(
                                                        duration: Duration(
                                                            milliseconds: 150),
                                                        width: 50,
                                                        height: 64,
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? Color(0xFF4068EA)
                                                              : MyColors.blueJournal,
                                                          border: Border.all(
                                                            color: Color(0xFF4068EA),
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                        ),
                                                        child: isSelected
                                                            ? Icon(Icons.check,
                                                            color: Colors.white,
                                                            size: 22)
                                                            : null,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        type['label']!,
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 28),
                                        if (selectedTypes.isNotEmpty)
                                          ...List.generate(
                                            (selectedTypes.length / 2).ceil(),
                                                (rowIndex) {
                                              final start = rowIndex * 2;
                                              final end =
                                              (start + 2 < selectedTypes.length)
                                                  ? start + 2
                                                  : selectedTypes.length;
                                              final rowTypes =
                                              selectedTypes.sublist(start, end);
                                              return Row(
                                                children: rowTypes.map((typeKey) {
                                                  final type =
                                                  lessonTypeOptions.firstWhere(
                                                          (t) => t['key'] == typeKey);

                                                  return Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          right:
                                                          rowTypes.last == typeKey
                                                              ? 0
                                                              : 12,
                                                          bottom: 12),
                                                      padding: EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius.circular(22),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${type['label']}*',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .grey.shade700),
                                                          ),
                                                          SizedBox(height: 8),
                                                          TextFormField(
                                                            controller: hoursControllers[typeKey],
                                                            keyboardType:
                                                            TextInputType.number,
                                                            decoration:
                                                            InputDecoration(
                                                              hintText:
                                                              'Введите часы',
                                                              hintStyle: TextStyle(
                                                                  color: Color(
                                                                      0xFF9CA3AF),
                                                                  fontSize: 15),
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              enabledBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(11),
                                                                borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400,
                                                                    width: 1.5),
                                                              ),
                                                              focusedBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(11),
                                                                borderSide: BorderSide(
                                                                    color: MyColors
                                                                        .blueJournal,
                                                                    width: 1.5),
                                                              ),
                                                              border:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(11),
                                                                borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400,
                                                                    width: 1.5),
                                                              ),
                                                              contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  16,
                                                                  vertical:
                                                                  14),
                                                            ),
                                                            validator: (value) {
                                                              if (selectedTypes
                                                                  .contains(
                                                                  typeKey) &&
                                                                  (value == null ||
                                                                      value
                                                                          .isEmpty)) {
                                                                return 'Обязательное поле';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                    Text(
                                      "Привязать преподавателя",
                                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 18),
                                    GestureDetector(
                                      onTap: () async {
                                        final selected = await showDialog<List<MyUser>>(
                                          context: context,
                                          builder: (_) => MultiSelectDialog(
                                            items: widget.teachers,
                                            initiallySelected: selectedTeachers,
                                            itemLabel: (user) => user.username,
                                          ),
                                        );

                                        if (selected != null) {
                                          setState(() {
                                            selectedTeachers = selected;
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
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400, width: 1.5),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        ),
                                        child: Text(
                                          selectedTeachers.isEmpty
                                              ? "Выберите из списка преподавателей"
                                              : selectedTeachers.map((s) => s.username).join(', '),
                                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    if (selectedTeachers.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: selectedTeachers.map((teacher) {
                                          return Chip(
                                            label: Text(teacher.username),
                                            side: BorderSide(color: Colors.grey.shade500),
                                            backgroundColor: Colors.white,
                                            deleteIcon: Icon(Icons.close, size: 18),
                                            deleteIconColor: Colors.grey.shade500,
                                            onDeleted: () {
                                              setState(() {
                                                selectedTeachers.remove(teacher);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "Привязать группу",
                                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 18),
                                    GestureDetector(
                                      onTap: () async {
                                        final selected = await showDialog<List<Group>>(
                                          context: context,
                                          builder: (_) => MultiSelectDialog(
                                            items: widget.groups,
                                            initiallySelected: selectedGroups,
                                            itemLabel: (group) => group.name,
                                          ),
                                        );

                                        if (selected != null) {
                                          setState(() {
                                            selectedGroups = selected;
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
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400, width: 1.5), // чуть ярче при фокусе
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        ),
                                        child: Text(
                                          selectedGroups.isEmpty
                                              ? "Выберите из списка групп"
                                              : selectedGroups.map((s) => s.name).join(', '),
                                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    if (selectedGroups.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: selectedGroups.map((group) {
                                          return Chip(
                                            label: Text(group.name),
                                            side: BorderSide(color: Colors.grey.shade500),
                                            backgroundColor: Colors.white,
                                            deleteIcon: Icon(Icons.close, size: 18),
                                            deleteIconColor: Colors.grey.shade500,
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
