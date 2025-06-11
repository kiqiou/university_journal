import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../bloc/group/group.dart';
import '../../../../bloc/group/group_repository.dart';
import '../../../../bloc/user/user.dart';
import '../../../../components/multiselect.dart';

class GroupsList extends StatefulWidget {
  final Future<void> Function() loadGroups;
  final List<Group> groups;
  final List<MyUser> students;

  const GroupsList({
    super.key,
    required this.loadGroups,
    required this.groups,
    required this.students,
  });

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  final GroupRepository groupRepository = GroupRepository();
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<MyUser> selectedStudents = [];
  int? selectedCourseIndex;
  int? selectedFacultyIndex;
  int? selectedIndex;
  bool showDeleteDialog = false;
  bool showEditDialog = false;

  final List<String> _courses = ['1 курс', '2 курс', '3 курс', '4 курс'];
  final List<String> _faculties = ['Экономический', 'Юридический'];

  @override
  void initState() {
    super.initState();
    widget.loadGroups().then((_) {
      if (kDebugMode) {
        print('Количество групп: ${widget.groups.length}');
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Map<int, List<Group>> groupByCourse(List<Group> groups) {
    final Map<int, List<Group>> grouped = {};
    for (final group in groups) {
      final int course = group.courseId;
      grouped.putIfAbsent(course, () => []).add(group);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double baseScreenWidth = 1920.0;
    const double baseButtonHeight = 40.0;
    const baseWidths = [260.0, 290.0, 320.0];
    final double scale = screenWidth / baseScreenWidth;
    final double buttonHeights = baseButtonHeight * scale;
    final List<double> buttonWidths = baseWidths.map((w) => w * scale).toList();

    final groupedData = groupByCourse(widget.groups);
    final sortedCourses = groupedData.keys.toList()..sort();

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
                        // Заголовок и кнопки действий
                        Row(
                          children: [
                            Text(
                              'Список групп',
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
                                  child: const Text(
                                    'Удалить группу',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
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
                                  child: const Text(
                                    'Редактировать группу',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Заголовок списка
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Номер группы',
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
                        // Список групп, сгруппированный по курсу
                        Expanded(
                          child: ListView.builder(
                            itemCount: sortedCourses.length,
                            itemBuilder: (context, courseIndex) {
                              final course = sortedCourses[courseIndex];
                              final courseGroups = groupedData[course]!;
                              courseGroups.sort((a, b) => a.name.compareTo(b.name));
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Заголовок курса (например, "1 курс")
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Text(
                                        '$course курс',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Список групп в данном курсе
                                    Column(
                                      children: courseGroups.asMap().entries.map((entry) {
                                        final indexInCourse = entry.key;
                                        final group = entry.value;
                                        final bool isSelected =
                                            selectedIndex != null && widget.groups[selectedIndex!].id == group.id;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = widget.groups.indexWhere((g) => g.id == group.id);
                                              });
                                            },
                                            child: Container(
                                              height: 55,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(22.0),
                                                border: Border.all(
                                                  color: isSelected ? const Color(0xFF4068EA) : Colors.grey.shade300,
                                                  width: 1.4,
                                                ),
                                                color: isSelected ? const Color(0xFFE6EDFF) : Colors.white,
                                              ),
                                              alignment: Alignment.centerLeft,
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Row(
                                                children: [
                                                  // Порядковый номер внутри курса
                                                  SizedBox(
                                                    width: 32,
                                                    child: Text(
                                                      '${indexInCourse + 1}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      group.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
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
                // Диалог редактирования информации о группе
                if (showEditDialog && selectedIndex != null)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: Builder(
                      builder: (context) {
                        final media = MediaQuery.of(context).size;
                        final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
                        (media.height - 64).clamp(480, 1100);
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;

                        if (screenWidth < 500 || screenHeight < 500) return const SizedBox.shrink();

                        return Material(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 60),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: dialogWidth,
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
                                        // --- Заголовок и кнопка закрытия ---
                                        Row(
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'Добавить группу',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, size: 28, color: Colors.black54),
                                              splashRadius: 24,
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 28),
                                        // --- Форма ---
                                        Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Название группы
                                              const Text(
                                                'Введите название группы*',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF6B7280),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              TextFormField(
                                                controller: nameController,
                                                decoration: _inputDecoration('Название группы'),
                                                validator: (value) =>
                                                    value == null || value.isEmpty ? 'Введите название группы' : null,
                                              ),
                                              const SizedBox(height: 48),
                                              // Выбор курса
                                              const Text(
                                                'Выберите курс*',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF6B7280),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              DropdownButtonFormField<int>(
                                                value: selectedCourseIndex,
                                                decoration: _inputDecoration('Выберите курс'),
                                                items: List.generate(_courses.length, (index) {
                                                  return DropdownMenuItem<int>(
                                                    value: index,
                                                    child: Text(
                                                      _courses[index],
                                                      style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedCourseIndex = value;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Выберите курс';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 18),
                                              const Text(
                                                'Выберите факультет*',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF6B7280),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              DropdownButtonFormField<int>(
                                                value: selectedFacultyIndex,
                                                decoration: _inputDecoration('Выберите Факультет'),
                                                items: List.generate(_faculties.length, (index) {
                                                  return DropdownMenuItem<int>(
                                                    value: index,
                                                    child: Text(
                                                      _faculties[index],
                                                      style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedFacultyIndex = value;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Выберите курс';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 18),
                                              GestureDetector(
                                                onTap: () async {
                                                  final selected = await showDialog<List<MyUser>>(
                                                    context: context,
                                                    builder: (_) => MultiSelectDialog(
                                                      items: widget.students,
                                                      initiallySelected: selectedStudents,
                                                      itemLabel: (user) => user.username,
                                                    ),
                                                  );

                                                  if (selected != null) {
                                                    setState(() {
                                                      selectedStudents = selected;
                                                    });
                                                  }
                                                },
                                                child: InputDecorator(
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: BorderSide(
                                                        color: Colors.grey.shade400,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                  ),
                                                  child: Text(
                                                    selectedStudents.isEmpty
                                                        ? "Выберите из списка студента"
                                                        : selectedStudents.map((s) => s.username).join(', '),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              if (selectedStudents.isNotEmpty)
                                                Wrap(
                                                  spacing: 8,
                                                  children: selectedStudents.map((teacher) {
                                                    return Chip(
                                                      label: Text(teacher.username),
                                                      onDeleted: () {
                                                        setState(() {
                                                          selectedStudents.remove(teacher);
                                                        });
                                                      },
                                                    );
                                                  }).toList(),
                                                ),
                                              const SizedBox(height: 48),
                                              // Кнопка "Сохранить"
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      _formKey.currentState!.save();

                                                      List<int> studentIds = selectedStudents.map((e) => e.id).toList();
                                                      int facultyId = selectedFacultyIndex! + 1;
                                                      int courseId = selectedCourseIndex! + 1;

                                                      final groupRepository = GroupRepository();

                                                      final groupId = widget.groups[selectedIndex!].id;
                                                      final result = await groupRepository.updateGroup(
                                                        groupId: groupId,
                                                        name: nameController.text,
                                                        studentIds: studentIds,
                                                        courseId: courseId,
                                                        facultyId: facultyId,
                                                      );

                                                      if (!mounted) return;

                                                      if (result) {
                                                        await widget.loadGroups();
                                                        setState(() {
                                                          selectedIndex = null;
                                                          showEditDialog = false;
                                                        });
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('❌ Не удалось добавить группу')),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF4068EA),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                                  minimumSize: const Size.fromHeight(55),
                                                ),
                                                child: const Text('Сохранить', style: TextStyle(fontSize: 16)),
                                              ),
                                            ],
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

// Оформление полей
InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
    filled: true,
    fillColor: const Color(0xFFF3F4F6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xFF4068EA), width: 1.2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    ),
  );
}
