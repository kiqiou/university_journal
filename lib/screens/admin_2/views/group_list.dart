import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';
import 'package:university_journal/components/widgets/cancel_button.dart';
import 'package:university_journal/components/widgets/input_decoration.dart';
import '../../../bloc/services/group/group_repository.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../components/colors/colors.dart';
import '../../../components/widgets/multiselect.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/user_repository.dart';

class GroupsExpandableList extends StatefulWidget {
  final List<Group> groups;
  final List<MyUser> freeStudents;
  final List<GroupSimple> simpleGroups;
  final Future<void> Function() loadFreeStudents;
  final Future<void> Function({
    Set<String>? faculties,
    Set<int>? courses,
  }) loadGroups;

  const GroupsExpandableList({
    super.key,
    required this.groups,
    required this.loadGroups,
    required this.simpleGroups,
    required this.freeStudents,
    required this.loadFreeStudents,
  });

  @override
  State<GroupsExpandableList> createState() => _GroupsExpandableListState();
}

class _GroupsExpandableListState extends State<GroupsExpandableList> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? selectedGroupIndex;
  int? selectedStudentIndex;
  int? selectedStudentId;
  bool showFilterDialog = false;
  bool showEditGroupDialog = false;
  bool showDeleteGroupDialog = false;
  bool showEditStudentDialog = false;
  bool showDeleteStudentDialog = false;
  bool isFilteringActive = false;
  bool? isHeadman;
  Set<String> selectedFaculties = {};
  Set<int> selectedCourses = {};
  List<Group> filteredGroups = [];
  List<MyUser> selectedStudents = [];
  GroupSimple? selectedGroup;
  int? selectedGroupId;
  int? selectedFacultyIndex;
  int? selectedCourseIndex;
  final List<String> _faculties = ['Экономический', 'Юридический'];
  final List<int> _courses = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    filteredGroups = [];
  }

  @override
  void didUpdateWidget(covariant GroupsExpandableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredGroups = widget.groups;
  }

  bool get _canApply =>
      selectedFaculties.isNotEmpty || selectedCourses.isNotEmpty;

  Future<void> _applyFilters() async {
    setState(() => isFilteringActive = true);
    await widget.loadGroups(
      faculties: selectedFaculties,
      courses: selectedCourses,
    );
  }

  Future<void> _reloadGroupsWithFilters() async {
    await widget.loadGroups(
      faculties: selectedFaculties.isNotEmpty ? selectedFaculties : null,
      courses: selectedCourses.isNotEmpty ? selectedCourses : null,
    );
  }

  void _resetFilters() {
    setState(() {
      selectedFaculties.clear();
      selectedCourses.clear();
      searchController.clear();
      isFilteringActive = false;
      filteredGroups = widget.groups;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedGroups = filteredGroups.where((group) {
      final searchText = searchController.text.toLowerCase();
      return group.name.toLowerCase().contains(searchText);
    }).toList();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Список групп и студентов",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
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
                      MyButton(
                        onChange: () => setState(() => showFilterDialog = true),
                        buttonName: 'Настроить фильтры',
                      ),
                    ],
                  ),
                ),
                if (widget.freeStudents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          surfaceVariant: Colors.transparent,
                        ),
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.transparent,
                        collapsedBackgroundColor: Colors.transparent,
                        title: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Без группы (${widget.freeStudents.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        children: widget.freeStudents.map((student) {
                          return Container(
                            height: 55,
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(color: Colors.grey.shade300, width: 1.4),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Text(student.username),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (student.isHeadman ?? false)
                                    Text(
                                      'Староста',
                                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                    ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: MyColors.blueJournal),
                                    onPressed: () {
                                      setState(() {
                                        selectedStudentId = student.id;
                                        selectedGroup = null;
                                        showEditStudentDialog = true;
                                        usernameController.text = student.username;
                                        isHeadman = student.isHeadman;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: MyColors.blueJournal),
                                    onPressed: () {
                                      setState(() {
                                        selectedStudentId = student.id;
                                        showDeleteStudentDialog = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                Expanded(
                  child: displayedGroups.isEmpty
                      ? const Center(
                          child: Text(
                            "Нет групп по заданным критериям",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedGroups.length,
                          itemBuilder: (context, index) {
                            final group = displayedGroups[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 2),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  colorScheme:
                                      Theme.of(context).colorScheme.copyWith(
                                            surfaceVariant: Colors.transparent,
                                          ),
                                ),
                                child: ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  collapsedBackgroundColor: Colors.transparent,
                                  title: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      '${group.name} — ${group.courseId} курс',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: MyColors.blueJournal),
                                          onPressed: () {
                                            setState(() {
                                              selectedGroupIndex = index;
                                              selectedStudents = List<MyUser>.from(group.students);
                                              nameController.text = group.name ?? '';
                                              selectedCourseIndex = group.courseId - 1;
                                              selectedFacultyIndex = group.facultyId - 1;
                                              showEditGroupDialog = true;
                                            });
                                          },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: MyColors.blueJournal),
                                        onPressed: () {
                                          setState(() {
                                            selectedGroupIndex = index;
                                            showDeleteGroupDialog = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  children: group.students
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final studentIndex = entry.key;
                                    final student = entry.value;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${studentIndex + 1}.',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Container(
                                              height: 55,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(22.0),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1.4,
                                                ),
                                                color: Colors.white,
                                              ),
                                              child: ListTile(
                                                title: Text(student.username),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (student.isHeadman ?? false)
                                                      Text(
                                                        'Отмечен как староста',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.grey.shade700,
                                                        ),
                                                      ),
                                                    const SizedBox(width: 20),
                                                    IconButton(
                                                      icon: const Icon(Icons.edit,
                                                          color: MyColors.blueJournal),
                                                      onPressed: () {
                                                        setState(() {
                                                          selectedGroupIndex = index;
                                                          selectedStudentIndex = studentIndex;
                                                          selectedStudentId = student.id;
                                                          selectedGroup = GroupSimple(
                                                            id: group.id,
                                                            name: group.name,
                                                          );
                                                          showEditStudentDialog = true;
                                                          isHeadman = student.isHeadman;
                                                          usernameController.text = student.username;
                                                        });
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete,
                                                          color: MyColors.blueJournal),
                                                      onPressed: () {
                                                        setState(() {
                                                          selectedGroupIndex = index;
                                                          selectedStudentIndex = studentIndex;
                                                          selectedStudentId = student.id;
                                                          showDeleteStudentDialog = true;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            if (showFilterDialog) _buildFilterDialog(context),
            if (showEditGroupDialog) _buildEditGroupDialog(),
            if (showDeleteGroupDialog) _buildDeleteGroupDialog(),
            if (showDeleteStudentDialog) _buildDeleteStudentDialog(),
            if (showEditStudentDialog) _buildEditStudentDialog(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDialog(BuildContext context) {
    final w = (MediaQuery.of(context).size.width * 0.6).clamp(300.0, 600.0);
    final h = (MediaQuery.of(context).size.height * 0.5).clamp(400.0, 600.0);
    final sortedFaculties = List<String>.from(_faculties)..sort();
    final sortedCourses = List<int>.from(_courses)..sort();
    Widget multiSelectInputWithChips<T>({
      required String label,
      required List<T> items,
      required Set<T> selectedItems,
      required String Function(T) itemLabel,
      required void Function(Set<T>) onSelectionChanged,
      bool showError = false,
    }) {
      final borderColor = showError ? Colors.red : Colors.grey.shade400;
      return Builder(builder: (context) {
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDialog<List<T>>(
                    context: context,
                    builder: (_) => SimpleMultiSelectDialog<T>(
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
                      deleteIcon: Icon(Icons.close,
                          size: 18, color: Colors.grey.shade500),
                      onDeleted: () {
                        final newSet = Set<T>.from(selectedItems);
                        newSet.remove(item);
                        onSelectionChanged(newSet);
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      });
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
              Spacer(),
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
                        ? () async {
                            await _applyFilters();
                            if (!mounted) return;
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

  Future<void> _handleDelete() async {
    if (selectedStudentId != null) {
      final repo = UserRepository();
      await repo.deleteUser(userId: selectedStudentId!);
      await _reloadGroupsWithFilters();
      selectedStudentId = null;
    } else if (selectedGroupIndex != null) {
      final repo = GroupRepository();
      final groupId = widget.groups[selectedGroupIndex!].id;
      final success = await repo.deleteGroup(groupId: groupId);
      if (success) {
        await _reloadGroupsWithFilters();
      }
      selectedGroupIndex = null;
    }
  }

  Widget _buildDeleteStudentDialog() {
    return Positioned(
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
          final student = widget
              .groups[selectedGroupIndex!].students[selectedStudentIndex!];
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
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      CancelButton(
                        onPressed: () {
                          setState(() {
                            showDeleteStudentDialog = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    student.username,
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
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4068EA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedStudentIndex != null) {
                          final userId = selectedStudentId;
                          final userRepository = UserRepository();
                          bool success =
                              await userRepository.deleteUser(userId: userId!);
                          if (success) {
                            await _reloadGroupsWithFilters();
                            setState(() {
                              showDeleteStudentDialog = false;
                              selectedStudentIndex = null;
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

  Widget _buildDeleteGroupDialog() {
    return Positioned(
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
                      Text(
                        "Удаление группы",
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      CancelButton(
                        onPressed: () {
                          setState(() {
                            showDeleteGroupDialog = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.groups[selectedGroupIndex!].name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Вы действительно хотите удалить группу?",
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
                      onPressed: () {
                        _handleDelete();
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

  Widget _buildEditStudentDialog(BuildContext context) {
    return Positioned(
      top: 32,
      right: 32,
      child: Builder(
        builder: (context) {
          final media = MediaQuery.of(context).size;
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
                                    fontSize: 18, color: Colors.grey.shade700),
                              ),
                              const Spacer(),
                              MyButton(
                                  onChange: () async {
                                    final userRepository = UserRepository();
                                    final success =
                                        await userRepository.updateUser(
                                      userId: selectedStudentId!,
                                      groupId: selectedGroup?.id,
                                      username: usernameController.text,
                                      isHeadman: isHeadman,
                                    );
                                    if (success) {
                                      await _reloadGroupsWithFilters();
                                      setState(() {
                                        selectedStudentIndex = null;
                                        showEditStudentDialog = false;
                                      });
                                    }
                                  },
                                  buttonName: 'Сохранить'),
                              const SizedBox(width: 12),
                              CancelButton(
                                onPressed: () {
                                  setState(() {
                                    showEditStudentDialog = false;
                                  });
                                },
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
                                controller: usernameController,
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
                              DropdownButtonFormField<GroupSimple>(
                                items: widget.simpleGroups
                                    .map((group) =>
                                        DropdownMenuItem<GroupSimple>(
                                          value: group,
                                          child: Text(
                                            group.name,
                                            style:
                                                const TextStyle(fontSize: 16),
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
                                onChanged: (GroupSimple? value) {
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
                                      value: isHeadman ?? false,
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

  Widget _buildEditGroupDialog() {
    if (selectedGroupIndex == null) return const SizedBox.shrink();
    final media = MediaQuery.of(context).size;
    final double dialogWidth = (media.width - 32 - 80).clamp(320, 600);
    final group = widget.groups[selectedGroupIndex!];

    return Positioned(
      top: 32,
      right: 32,
      child: Material(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Редактирование группы",
                            style: TextStyle(fontSize: 18),
                          ),
                          const Spacer(),
                          MyButton(
                              onChange: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  final groupRepository = GroupRepository();
                                  final groupId = group.id;

                                  List<int>? studentIds =
                                      selectedStudents.isNotEmpty
                                          ? selectedStudents
                                              .map((e) => e.id)
                                              .toList()
                                          : null;

                                  int? facultyId = selectedFacultyIndex != null
                                      ? selectedFacultyIndex! + 1
                                      : null;

                                  int? courseId = selectedCourseIndex;

                                  final result =
                                      await groupRepository.updateGroup(
                                    groupId: groupId,
                                    name: nameController.text,
                                    studentIds: studentIds,
                                    courseId: courseId,
                                    facultyId: facultyId,
                                  );

                                  if (!mounted) return;

                                  if (result) {
                                    await widget.loadGroups();
                                    await widget.loadFreeStudents();
                                    setState(() {
                                      selectedGroupIndex = null;
                                      showEditGroupDialog = false;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              '❌ Не удалось обновить группу')),
                                    );
                                  }
                                }
                              },
                              buttonName: 'Сохранить'),
                          const SizedBox(width: 12),
                          CancelButton(
                            onPressed: () {
                              setState(() {
                                showEditGroupDialog = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Введите название группы',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700)),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: nameController,
                              decoration: textInputDecoration(
                                'Введите название группы',
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text('Выберите факультет',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700)),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<int>(
                              value: selectedFacultyIndex,
                              decoration: inputDecoration(
                                'Факультет',
                              ),
                              items: List.generate(_faculties.length, (index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(_faculties[index]),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  selectedFacultyIndex = value;
                                });
                              },
                            ),
                            const SizedBox(height: 28),
                            Text('Выберите курс',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700)),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<int>(
                              value: selectedCourseIndex,
                              decoration: inputDecoration('Выберите крус'),
                              items: List.generate(_courses.length, (index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(_courses[index].toString()),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  selectedCourseIndex = value;
                                });
                              },
                            ),
                            const SizedBox(height: 28),
                            Text('Выберите студентов',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700)),
                            const SizedBox(height: 18),
                            GestureDetector(
                              onTap: () async {
                                final allStudents = [
                                  ...group.students,
                                  ...widget.freeStudents,
                                ];
                                final selected = await showDialog<List<MyUser>>(
                                  context: context,
                                  builder: (_) => MultiSelectDialog<MyUser>(
                                    items: allStudents,
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
                                decoration: inputDecoration(''),
                                child: Text(
                                  selectedStudents.isEmpty
                                      ? "Выберите студентов"
                                      : selectedStudents
                                          .map((s) => s.username)
                                          .join(', '),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (selectedStudents.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedStudents.map((student) {
                                  return Chip(
                                    label: Text(student.username),
                                    side:
                                        BorderSide(color: Colors.grey.shade500),
                                    backgroundColor: Colors.white,
                                    deleteIcon: Icon(Icons.close, size: 18),
                                    deleteIconColor: Colors.grey.shade500,
                                    onDeleted: () {
                                      setState(() {
                                        selectedStudents.remove(student);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
