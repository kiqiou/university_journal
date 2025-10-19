import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';
import 'package:university_journal/components/widgets/cancel_button.dart';
import 'package:university_journal/components/widgets/input_decoration.dart';
import 'dart:math';

import '../../../../components/colors/colors.dart';
import '../../../components/constants/constants.dart';
import '../../../components/widgets/multiselect.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/discipline/discipline_repository.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/models/user.dart';

class AddCourseDialog extends StatefulWidget {
  final VoidCallback onCourseAdded;
  final List<Group> groups;
  final List<MyUser> teachers;

  const AddCourseDialog({
    super.key,
    required this.onCourseAdded,
    required this.groups,
    required this.teachers,
  });

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lectureHoursController = TextEditingController();
  final TextEditingController labHoursController = TextEditingController();
  final Map<String, TextEditingController> hoursControllers = {};
  final List<Discipline> disciplines = [];
  List<MyUser> selectedTeachers = [];
  List<Group> selectedGroups = [];
  List<MyUser> selectedTeachers2 = [];
  List<String> selectedTypes = [];
  List<String> selectedLessonTypes = [];
  String? selectedLessonType;
  MyUser? selectedTeacher;
  Group? selectedGroup;
  String? _selectedAttestationType;
  bool isGroupSplit = false;

  @override
  void initState() {
    super.initState();
    for (var type in lessonTypeOptions) {
      hoursControllers[type['key']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in hoursControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const double minWidth = 380;
    const double maxWidth = 600;
    final double dialogWidth = min(maxWidth, max(minWidth, screenWidth * 0.45));
    final double dialogHeight = min(screenHeight * 0.95, screenHeight - 40);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(right: 30),
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogHeight,
            ),
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
                      children: [
                        Expanded(
                          child: Text(
                            'Создание дисциплины',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade700),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              MyButton(
                                  onChange: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final planItems = selectedTypes
                                          .where((key) =>
                                              hoursControllers[key]
                                                  ?.text
                                                  .isNotEmpty ==
                                              true)
                                          .map((key) {
                                        final allocatedHours = int.tryParse(
                                                hoursControllers[key]!.text) ??
                                            0;
                                        final hoursPerSession = 2;

                                        return {
                                          'type': key,
                                          'hours_allocated': allocatedHours,
                                          'hours_per_session': hoursPerSession,
                                        };
                                      }).toList();

                                      List<int> teacherIds = selectedTeachers
                                          .map((e) => e.id)
                                          .toList();
                                      List<int> groupIds = selectedGroups
                                          .map((e) => e.id)
                                          .toList();

                                      bool result = await DisciplineRepository()
                                          .addDiscipline(
                                        name: nameController.text,
                                        teacherIds: teacherIds,
                                        groupIds: groupIds,
                                        planItems: planItems,
                                        isGroupSplit: isGroupSplit,
                                        attestationType:
                                            _selectedAttestationType!,
                                      );

                                      if (result) {
                                        widget.onCourseAdded();
                                        Navigator.of(context).pop();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  '❌ Не удалось добавить дисциплину')),
                                        );
                                      }
                                    }
                                  },
                                  buttonName: 'Сохранить'),
                              const SizedBox(width: 12),
                              CancelButton(
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
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
                                'Название дисциплины*',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: nameController,
                                decoration: textInputDecoration('Введите название дисциплины'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Обязательное поле'
                                        : null,
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
                                          isGroupSplit = value ?? false;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      activeColor: MyColors.blueJournal,
                                      side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
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
                                              if (isSelected) {
                                                selectedTypes
                                                    .remove(type['key']);
                                              } else {
                                                selectedTypes.add(type['key']!);
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
                                                      controller:
                                                          hoursControllers[
                                                              typeKey],
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
                                                    const SizedBox(height: 15),
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
                              Text("Привязать преподавателя",
                                  style: TextStyle(
                                      color: Color(0xFF6B7280), fontSize: 15)),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () async {
                                  final selected =
                                      await showDialog<List<MyUser>>(
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
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  child: Text(
                                    selectedTeachers.isEmpty
                                        ? "Выберите из списка преподавателей"
                                        : selectedTeachers
                                            .map((s) => s.username)
                                            .join(', '),
                                    style: TextStyle(
                                        color: Color(0xFF9CA3AF), fontSize: 15),
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
                                      side: BorderSide(
                                          color: Colors.grey.shade500),
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
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              GestureDetector(
                                onTap: () async {
                                  final selected =
                                      await showDialog<List<Group>>(
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
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5), // чуть ярче при фокусе
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                  ),
                                  child: Text(
                                    selectedGroups.isEmpty
                                        ? "Выберите из списка групп"
                                        : selectedGroups
                                            .map((s) => s.name)
                                            .join(', '),
                                    style: TextStyle(
                                        color: Color(0xFF9CA3AF), fontSize: 15),
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
                                      side: BorderSide(
                                          color: Colors.grey.shade500),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Выберите тип аттестации',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ChipTheme(
                                    data: ChipTheme.of(context).copyWith(
                                      selectedColor: MyColors.blueJournal,
                                      backgroundColor: Colors.white,
                                      checkmarkColor: Colors.white,
                                      secondarySelectedColor:
                                          MyColors.blueJournal,
                                    ),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children:
                                          attestationOptions.map((option) {
                                        final isSelected =
                                            _selectedAttestationType == option;
                                        return ChoiceChip(
                                          label: Text(
                                            option,
                                            style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade700),
                                          ),
                                          side: BorderSide(
                                              color: Colors.grey.shade500),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              _selectedAttestationType =
                                                  selected
                                                      ? option as String?
                                                      : null;
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
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
