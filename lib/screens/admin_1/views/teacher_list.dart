import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:university_journal/components/widgets/cancel_button.dart';
import 'dart:typed_data';
import 'dart:html' as html;

import '../../../components/colors/colors.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/multiselect.dart';
import '../../../bloc/services/discipline/models/discipline.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';
import '../../../components/widgets/input_decoration.dart';
import '../components/add_or_edit_teacher.dart';

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
  final searchController = TextEditingController();
  int? selectedTeacherIndex;
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
    final displayedTeachers = widget.teachers.where((teacher) {
      final searchText = searchController.text.toLowerCase();
      return teacher.username.toLowerCase().contains(searchText);
    }).toList();
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 24),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          selectedTeacherIndex = null;
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
                                  fontSize: 20,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  decoration: textInputDecoration('Поиск..'),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              if (selectedTeacherIndex != null) ...[
                                MyButton(
                                  onChange: () {
                                    setState(() {
                                      showDeleteDialog = true;
                                    });
                                  },
                                  buttonName: 'Удалить преподавателя',
                                ),
                                const SizedBox(width: 16),
                                MyButton(
                                  onChange: () {
                                    setState(() {
                                      showEditDialog = true;
                                      showDialog(
                                        context: context,
                                        builder: (_) => AddAndEditTeacherDialog(
                                          isEdit: true,
                                          teacher: widget.teachers[selectedTeacherIndex!],
                                          onSuccess: widget.loadTeachers,
                                        ),
                                      );
                                    });
                                  },
                                  buttonName: 'Редактировать информацию',
                                ),
                                const SizedBox(width: 16),
                                MyButton(
                                    onChange: () {
                                      setState(() {
                                        showLinkDisciplineDialog = true;
                                        selectedDisciplines = widget
                                            .teachers[selectedTeacherIndex!]
                                            .disciplines;
                                      });
                                    },
                                    buttonName: 'Привязка дисциплины'),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
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
                          Expanded(
                            child: ListView.builder(
                              itemCount: displayedTeachers.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 6.0),
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
                                              selectedTeacherIndex = index;
                                              selectedDisciplines = widget
                                                      .teachers[index]
                                                      .disciplines;
                                            });
                                          },
                                          child: Container(
                                            height: 55,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22.0),
                                              border: Border.all(
                                                color: selectedTeacherIndex ==
                                                        index
                                                    ? const Color(0xFF4068EA)
                                                    : Colors.grey.shade300,
                                                width: 1.4,
                                              ),
                                              color: Colors.white,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(
                                              '${displayedTeachers[index].lastName ?? ''} '
                                                  '${displayedTeachers[index].firstName ?? ''} '
                                                  '${displayedTeachers[index].middleName ?? ''}',
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
                if (showDeleteDialog && selectedTeacherIndex != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final dialogMaxWidth = 420.0;
                        final dialogMinWidth = 280.0;
                        final availableWidth =
                            MediaQuery.of(context).size.width - 32 - 80;
                        final dialogWidth = availableWidth < dialogMaxWidth
                            ? availableWidth.clamp(
                                dialogMinWidth, dialogMaxWidth)
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
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Spacer(),
                                    CancelButton(
                                      onPressed: () {
                                        setState(() {
                                          showDeleteDialog = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  widget
                                      .teachers[selectedTeacherIndex!].username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Вы действительно хотите удалить преподавателя?",
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4068EA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (selectedTeacherIndex != null) {
                                        final userId = widget
                                            .teachers[selectedTeacherIndex!].id;
                                        bool success = await userRepository
                                            .deleteUser(userId: userId);

                                        if (success) {
                                          await widget.loadTeachers();
                                          setState(() {
                                            showDeleteDialog = false;
                                            selectedTeacherIndex = null;
                                          });
                                        }
                                      }
                                    },
                                    child: const Text("Удалить",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (showLinkDisciplineDialog && selectedTeacherIndex != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final media = MediaQuery.of(context).size;
                        final double dialogWidth =
                            (media.width - 32 - 80).clamp(320, 600);
                        final double dialogHeight =
                            (media.height - 64).clamp(480, 550);

                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            width: dialogWidth,
                            height: dialogHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Color(0xFF4068EA), width: 2),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            MyButton(
                                                onChange: () async {
                                                  final currentTeacher = widget
                                                          .teachers[
                                                      selectedTeacherIndex!];
                                                  final disciplineIds =
                                                      selectedDisciplines
                                                          .map((d) => d.id)
                                                          .toList();

                                                  final success =
                                                      await userRepository
                                                          .updateTeacherDisciplines(
                                                    teacherId:
                                                        currentTeacher.id,
                                                    disciplineIds:
                                                        disciplineIds,
                                                  );

                                                  if (success) {
                                                    await widget
                                                        .loadDisciplines();

                                                    setState(() {
                                                      showLinkDisciplineDialog =
                                                          false;
                                                      selectedTeacherIndex =
                                                          null;
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              '❌ Не удалось обновить дисциплины')),
                                                    );
                                                  }
                                                },
                                                buttonName: 'Сохранить'),
                                            const SizedBox(width: 12),
                                            CancelButton(
                                              onPressed: () {
                                                setState(() {
                                                  showLinkDisciplineDialog =
                                                      false;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height:
                                                constraints.maxHeight * 0.03),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 20),
                                            GestureDetector(
                                              onTap: () async {
                                                final selected =
                                                    await showDialog<
                                                        List<Discipline>>(
                                                  context: context,
                                                  builder: (_) =>
                                                      MultiSelectDialog(
                                                    items: widget.disciplines,
                                                    initiallySelected:
                                                        selectedDisciplines,
                                                    itemLabel: (discipline) =>
                                                        discipline.name,
                                                  ),
                                                );

                                                if (selected != null) {
                                                  setState(() {
                                                    selectedDisciplines =
                                                        selected;
                                                  });
                                                }
                                              },
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade400,
                                                        width: 1.5),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade400,
                                                        width: 1.5),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade400,
                                                        width:
                                                            1.5),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 14,
                                                          vertical: 12),
                                                ),
                                                child: Text(
                                                  selectedDisciplines.isEmpty
                                                      ? "Выберите из списка дисциплин"
                                                      : selectedDisciplines
                                                          .map((s) => s.name)
                                                          .join(', '),
                                                  style: TextStyle(
                                                      color: Color(0xFF9CA3AF),
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            if (selectedDisciplines.isNotEmpty)
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                alignment: WrapAlignment.start,
                                                children: selectedDisciplines
                                                    .map((discipline) {
                                                  return Chip(
                                                    label:
                                                        Text(discipline.name),
                                                    side: BorderSide(
                                                        color: Colors
                                                            .grey.shade500),
                                                    backgroundColor:
                                                        Colors.white,
                                                    deleteIcon: Icon(
                                                        Icons.close,
                                                        size: 18),
                                                    deleteIconColor:
                                                        Colors.grey.shade500,
                                                    onDeleted: () {
                                                      setState(() {
                                                        selectedDisciplines
                                                            .remove(discipline);
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
