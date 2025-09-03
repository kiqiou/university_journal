import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';
import '../../../components/colors/colors.dart';
import '../../../components/widgets/multiselect.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';

class StudentsList extends StatefulWidget {
  final Future<void> Function() loadStudents;
  final List<MyUser> students;
  final List<Group> groups;

  const StudentsList({
    super.key,
    required this.loadStudents,
    required this.students,
    required this.groups,
    required List allGroups,
  });

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> with AutomaticKeepAliveClientMixin<StudentsList> {
  static Set<String> _savedFaculties = {};
  static Set<int> _savedCourses = {};
  static Set<int> _savedGroupIds = {};
  static bool _savedFilteringActive = false;

  List<MyUser> allStudents = [];
  List<MyUser> filteredStudents = [];
  List<Group> allGroups = [];

  late List<int> allCourses;
  late List<String> allFaculties;

  Set<String> selectedFaculties = {};
  Set<int> selectedCourses = {};
  Set<int> selectedGroupIds = {};

  bool isFilteringActive = false;
  Group? selectedGroup;
  int? selectedIndex;

  bool showFilterDialog = false;
  bool showDeleteDialog = false;
  bool showEditDialog = false;

  final nameController = TextEditingController();
  bool? isHeadman;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    selectedFaculties = Set.from(_savedFaculties);
    selectedCourses = Set.from(_savedCourses);
    selectedGroupIds = Set.from(_savedGroupIds);
    isFilteringActive = _savedFilteringActive;

    widget.loadStudents().then((_) => _populateLocalData());
  }

  @override
  void didUpdateWidget(covariant StudentsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students ||
        oldWidget.groups != widget.groups) {
      _populateLocalData();
    }
  }

  void _populateLocalData() {
    allStudents = widget.students.toList();
    allGroups = widget.groups.toList();

    allCourses = allGroups.map((g) => g.courseId).toSet().toList()
      ..sort();

    allFaculties = allGroups
        .map((g) => g.facultyName)
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    if (isFilteringActive && _canApply) {
      _applyFilters(noSetState: true);
    } else {
      filteredStudents = allStudents;
    }

    setState(() {});
  }

  bool get _canApply =>
      selectedFaculties.isNotEmpty ||
          selectedCourses.isNotEmpty ||
          selectedGroupIds.isNotEmpty;

  void _applyFilters({bool noSetState = false}) {
    final newList = allStudents.where((u) {
      final grpMatch = allGroups.where((g) => g.id == u.groupId);
      if (grpMatch.isEmpty) return false;
      final grp = grpMatch.first;

      final facOk = selectedFaculties.isEmpty ||
          selectedFaculties.contains(grp.facultyName);
      final couOk =
          selectedCourses.isEmpty || selectedCourses.contains(grp.courseId);
      final grpOk =
          selectedGroupIds.isEmpty || selectedGroupIds.contains(grp.id);

      return facOk && couOk && grpOk;
    }).toList();

    if (noSetState) {
      filteredStudents = newList;
      return;
    }

    setState(() {
      isFilteringActive = true;
      filteredStudents = newList;
      _savedFaculties = Set.from(selectedFaculties);
      _savedCourses = Set.from(selectedCourses);
      _savedGroupIds = Set.from(selectedGroupIds);
      _savedFilteringActive = true;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedFaculties = {};
      selectedCourses = {};
      selectedGroupIds = {};
      isFilteringActive = false;
      filteredStudents = allStudents;
      _savedFaculties.clear();
      _savedCourses.clear();
      _savedGroupIds.clear();
      _savedFilteringActive = false;
    });
  }

  void _onEditPressed() {
    final st = filteredStudents[selectedIndex!];
    nameController.text = st.username;
    isHeadman = st.isHeadman;
    selectedGroupIds = st.groupId != null ? {st.groupId!} : {};
    setState(() => showEditDialog = true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const btnH = 40.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Список студентов',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  MyButton(
                      onChange: () => setState(() => showFilterDialog = true),
                      buttonName: 'Изменить фильтры'),
                  if (selectedIndex != null) ...[
                    const SizedBox(width: 8),
                    MyButton(
                        onChange: _onEditPressed,
                        buttonName: 'Редактировать'),
                    const SizedBox(width: 8),
                    MyButton(
                        onChange: () =>
                            setState(() => showDeleteDialog = true),
                        buttonName: 'Удалить'),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              // Основная часть UI
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: isFilteringActive
                          ? _buildStudentList()
                          : const Center(
                        child: Text(
                          'Пожалуйста, настройте фильтры',
                          style:
                          TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (showFilterDialog)
                      _buildFilterDialog(context),
                    if (showDeleteDialog && selectedIndex != null)
                      _buildDeleteDialog(btnH),
                    if (showEditDialog && selectedIndex != null)
                      _buildEditDialog(context, btnH),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (selectedGroupIds.isNotEmpty) {
      final groups = allGroups
          .where((g) => selectedGroupIds.contains(g.id))
          .where((g) => filteredStudents.any((u) => u.groupId == g.id))
          .toList()
        ..sort((a, b) {
          final c = a.courseId.compareTo(b.courseId);
          if (c != 0) return c;
          return a.name.compareTo(b.name);
        });

      return ListView(
        children: groups.expand((g) {
          final studs = filteredStudents.where((u) => u.groupId == g.id);
          return [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                '${g.name} — ${g.courseId} курс',
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ...studs.map((st) {
              final idx = filteredStudents.indexOf(st);
              return _buildStudentItem(st, selectedIndex == idx, idx);
            }),
          ];
        }).toList(),
      );
    }

    final sortedStudents = filteredStudents.toList()
      ..sort((u1, u2) {
        final g1 = allGroups.firstWhere((g) => g.id == u1.groupId);
        final g2 = allGroups.firstWhere((g) => g.id == u2.groupId);
        final c = g1.courseId.compareTo(g2.courseId);
        if (c != 0) return c;
        return u1.username.compareTo(u2.username);
      });

    return ListView.builder(
      itemCount: sortedStudents.length,
      itemBuilder: (_, i) {
        final st = sortedStudents[i];
        final idx = filteredStudents.indexOf(st);
        return _buildStudentItem(st, selectedIndex == idx, idx);
      },
    );
  }

  Widget _buildStudentItem(MyUser st, bool isSelected, int idx) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = idx),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4068EA) : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Text(
          st.username,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildFilterDialog(BuildContext context) {
    final w = (MediaQuery
        .of(context)
        .size
        .width * 0.6).clamp(300.0, 600.0);
    final h = (MediaQuery
        .of(context)
        .size
        .height * 0.7).clamp(400.0, 600.0);

    final sortedFaculties = List<String>.from(allFaculties)
      ..sort();
    final sortedCourses = List<int>.from(allCourses)
      ..sort();
    Widget multiSelectInputWithChips<T>({
      required String label,
      required List<T> items,
      required Set<T> selectedItems,
      required String Function(T) itemLabel,
      required void Function(Set<T>) onSelectionChanged,
      bool showError = false,
    }) {
      final borderColor = showError ? Colors.red : Colors.grey.shade400;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDialog<List<T>>(
                context: context,
                builder: (_) =>
                    MultiSelectDialog<T>(
                      items: items,
                      initiallySelected: selectedItems.toList(),
                      itemLabel: itemLabel,
                    ),
              );
              if (picked != null) onSelectionChanged(picked.toSet());
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: Text(
                selectedItems.isEmpty
                    ? 'Выберите из списка'
                    : selectedItems.map(itemLabel).join(', '),
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (selectedItems.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedItems.map((item) {
                return Chip(
                  label: Text(itemLabel(item)),
                  side: BorderSide(color: Colors.grey.shade500),
                  backgroundColor: Colors.white,
                  deleteIcon:
                  Icon(Icons.close, size: 18, color: Colors.grey.shade500),
                  onDeleted: () {
                    final newSet = Set<T>.from(selectedItems);
                    newSet.remove(item);
                    onSelectionChanged(newSet);
                  },
                );
              }).toList(),
            ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 30,
                spreadRadius: 2,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Настройка фильтров',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 16),
              multiSelectInputWithChips<String>(
                label: 'Факультеты',
                items: sortedFaculties,
                selectedItems: selectedFaculties,
                itemLabel: (f) => f,
                onSelectionChanged: (sel) =>
                    setState(() => selectedFaculties = sel),
              ),
              const SizedBox(height: 16),
              multiSelectInputWithChips<int>(
                label: 'Курсы',
                items: sortedCourses,
                selectedItems: selectedCourses,
                itemLabel: (c) => '$c курс',
                onSelectionChanged: (sel) =>
                    setState(() => selectedCourses = sel),
              ),
              const SizedBox(height: 16),
              multiSelectInputWithChips<Group>(
                label: 'Группы',
                items: allGroups.where((g) {
                  final facOk = selectedFaculties.isEmpty ||
                      selectedFaculties.contains(g.facultyName);
                  final couOk = selectedCourses.isEmpty ||
                      selectedCourses.contains(g.courseId);
                  return facOk && couOk;
                }).toList(),
                selectedItems: allGroups
                    .where((g) => selectedGroupIds.contains(g.id))
                    .toSet(),
                itemLabel: (g) => g.name,
                onSelectionChanged: (sel) =>
                    setState(() {
                      selectedGroupIds = sel.map((g) => g.id).toSet();
                    }),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _resetFilters,
                      child: const Text(
                        'Сбросить',
                        style: TextStyle(
                            fontSize: 16, color: MyColors.blueJournal),
                      )),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _canApply
                        ? () {
                      _applyFilters();
                      setState(() => showFilterDialog = false);
                    }
                        : null,
                    child: const Text(
                      'Применить',
                      style:
                      TextStyle(fontSize: 16, color: MyColors.blueJournal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteDialog(double btnH) {
    final st = filteredStudents[selectedIndex!];
    return Positioned(
      top: 32,
      right: 32,
      child: Builder(
        builder: (context) {
          final dialogMaxWidth = 420.0;
          final dialogMinWidth = 280.0;
          final availableWidth =
              MediaQuery
                  .of(context)
                  .size
                  .width - 32 - 80;
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
                      Text(
                        "Удаление студента",
                        style: TextStyle(fontSize: 18, color: Colors.grey
                            .shade700),
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
                            color: const Color(0xFF4068EA),
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
                    filteredStudents[selectedIndex!].username,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Вы действительно хотите удалить студента?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
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
                          final userId = filteredStudents[selectedIndex!].id;
                          final userRepository = UserRepository();
                          bool success = await userRepository.deleteUser(
                              userId: userId);
                          if (success) {
                            await widget.loadStudents();
                            setState(() {
                              showDeleteDialog = false;
                              selectedIndex = null;
                            });
                          }
                        }
                      },
                      child: const Text(
                        "Удалить",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditDialog(BuildContext context, double btnH) {
    return Positioned(
      top: 32,
      right: 32,
      child: Builder(
        builder: (context) {
          final media = MediaQuery
              .of(context)
              .size;
          final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
          final double dialogHeight = (media.height - 64).clamp(480, 500);
          return Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4068EA), width: 2),
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
                              Text(
                                "Редактирование студента",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4068EA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                  ),
                                  onPressed: () async {
                                    final userRepository = UserRepository();
                                    final success = await userRepository
                                        .updateUser(
                                      userId: filteredStudents[selectedIndex!]
                                          .id,
                                      groupId: selectedGroup?.id,
                                      username: nameController.text,
                                      isHeadman: isHeadman,
                                    );
                                    if (success) {
                                      await widget.loadStudents();
                                      setState(() {
                                        selectedIndex = null;
                                        showEditDialog = false;
                                      });
                                    }
                                  },
                                  child: const Text(
                                    'Сохранить',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                    color: const Color(0xFF4068EA),
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
                          SizedBox(height: constraints.maxHeight * 0.1),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ФИО студента',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: 'Введите ФИО студента',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(
                                        color: MyColors.blueJournal,
                                        width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Привязка группы',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              DropdownButtonFormField<Group>(
                                items: widget.groups
                                    .map((group) =>
                                    DropdownMenuItem<Group>(
                                      value: group,
                                      child: Text(
                                        group.name,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ))
                                    .toList(),
                                decoration: InputDecoration(
                                  labelText: 'Группа',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: MyColors.blueJournal,
                                        width: 1.5),
                                  ),
                                ),
                                value: selectedGroup,
                                onChanged: (Group? value) {
                                  setState(() {
                                    selectedGroup = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Отметить как старосту',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      value: isHeadman,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          isHeadman = newValue;
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
                                  Text(
                                    isHeadman ?? false ? 'Да' : 'Нет',
                                    style: TextStyle(
                                        color: Color(0xFF9CA3AF), fontSize: 15),
                                  ),
                                ],
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
    );
  }
}