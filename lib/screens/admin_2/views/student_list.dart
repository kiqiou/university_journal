import 'package:flutter/material.dart';
import '../../../components/widgets/multiselect.dart';
import '../../../bloc/services/group/models/group.dart';
import '../../../bloc/services/user/models/user.dart';
import '../../../bloc/services/user/user_repository.dart';

class StudentsList extends StatefulWidget {
  final Future<void> Function() loadStudents;
  final List<MyUser> students;
  final List<Group> groups;

  const StudentsList({
    Key? key,
    required this.loadStudents,
    required this.students,
    required this.groups, required List allGroups,
  }) : super(key: key);

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  late List<MyUser> allStudents      = [];
  late List<MyUser> filteredStudents = [];
  late List<Group> allGroups         = [];

  late List<int>    allCourses;
  late List<String> allFaculties;

  Set<String> selectedFaculties = {};
  Set<int>    selectedCourses   = {};
  Set<int>    selectedGroupIds  = {};

  bool isFilteringActive = false;
  int? selectedIndex;

  bool showFilterDialog = false;
  bool showDeleteDialog = false;
  bool showEditDialog   = false;

  final nameController = TextEditingController();
  bool? isHeadman;

  @override
  void initState() {
    super.initState();
    widget.loadStudents().then((_) {
      allStudents      = widget.students.toList();
      filteredStudents = allStudents;
      allGroups        = widget.groups.toList();

      allCourses = allGroups
          .map((g) => g.courseId)
          .toSet()
          .toList()
        ..sort();
      allFaculties = allGroups
          .map((g) => g.facultyName)
          .where((f) => f.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {});
    });
  }

  bool get _canApply =>
      selectedFaculties.isNotEmpty ||
          selectedCourses.isNotEmpty ||
          selectedGroupIds.isNotEmpty;

  void _applyFilters() {
    setState(() {
      isFilteringActive = true;
      filteredStudents = allStudents.where((u) {
        // получить все группы с нужным id
        final matches = allGroups.where((g) => g.id == u.groupId);
        if (matches.isEmpty) return false;
        final grp = matches.first;

        final facOk = selectedFaculties.isEmpty ||
            selectedFaculties.contains(grp.facultyName);
        final couOk = selectedCourses.isEmpty ||
            selectedCourses.contains(grp.courseId);
        final grpOk = selectedGroupIds.isEmpty ||
            selectedGroupIds.contains(grp.id);

        return facOk && couOk && grpOk;
      }).toList();
    });
  }


  void _resetFilters() {
    setState(() {
      selectedFaculties.clear();
      selectedCourses.clear();
      selectedGroupIds.clear();
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
    const btnH = 40.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список студентов'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4068EA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.filter_list),
              label: const Text('Изменить фильтры'),
              onPressed: () => setState(() => showFilterDialog = true),
            ),
          ),
          if (selectedIndex != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4068EA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(btnH, btnH),
                  padding: EdgeInsets.zero,
                ),
                onPressed: _onEditPressed,
                child: const Icon(Icons.edit, size: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(btnH, btnH),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => setState(() => showDeleteDialog = true),
                child: const Icon(Icons.delete, size: 20),
              ),
            ),
          ]
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: isFilteringActive
                ? _buildStudentList()
                : const Center(
              child: Text(
                'Пожалуйста, настройте фильтры',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
          if (showFilterDialog) Center(child: _buildFilterDialog(context)),
          if (showDeleteDialog && selectedIndex != null)
            Center(child: _buildDeleteDialog(btnH)),
          if (showEditDialog && selectedIndex != null)
            Center(child: _buildEditDialog(context, btnH)),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (selectedGroupIds.isNotEmpty) {
      final groups = allGroups
          .where((g) => selectedGroupIds.contains(g.id))
          .where((g) => filteredStudents.any((u) => u.groupId == g.id))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return ListView(
        children: groups.expand((g) {
          final studs = filteredStudents.where((u) => u.groupId == g.id);
          return [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                '${g.name} — ${g.courseId} курс',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...studs.map((st) {
              final idx = filteredStudents.indexOf(st);
              return _buildStudentItem(
                st,
                selectedIndex == idx,
                idx,
              );
            }),
          ];
        }).toList(),
      );
    }

    return ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (_, i) {
        final st = filteredStudents[i];
        return _buildStudentItem(st, selectedIndex == i, i);
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDialog(BuildContext context) {
    final w = (MediaQuery.of(context).size.width * 0.6).clamp(300.0, 600.0);
    final h = (MediaQuery.of(context).size.height * 0.7).clamp(400.0, 600.0);

    Widget multiDropdown<T>(
        String label,
        List<T> items,
        Set<T> selectedValues,
        String hint,
        String Function(T) itemLabel,
        void Function(Set<T>) onChanged,
        ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDialog<List<T>>(
                context: context,
                builder: (_) => MultiSelectDialog<T>(
                  items: items,
                  initiallySelected: selectedValues.toList(),
                  itemLabel: itemLabel,
                ),
              );
              if (picked != null) onChanged(picked.toSet());
            },
            child: InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              isEmpty: selectedValues.isEmpty,
              child: Text(
                selectedValues.isEmpty
                    ? hint
                    : selectedValues.map(itemLabel).join(', '),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Colors.black26,
      child: Center(
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade300, width: 2),
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
              const Text(
                'Настройка фильтров',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              multiDropdown<String>(
                'Факультет',
                allFaculties,
                selectedFaculties,
                'Все факультеты',
                    (f) => f,
                    (sel) => setState(() => selectedFaculties = sel),
              ),
              const SizedBox(height: 16),

              // Курсы: мультивыбор, но визуал «дропдауна»
              multiDropdown<int>(
                'Курс',
                allCourses,
                selectedCourses,
                'Все курсы',
                    (c) => '$c курс',
                    (sel) => setState(() => selectedCourses = sel),
              ),
              const SizedBox(height: 16),

              // Группы
              Text('Группы', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final availableGroups = allGroups.where((g) {
                    final facOk = selectedFaculties.isEmpty ||
                        selectedFaculties.contains(g.facultyName);
                    final couOk = selectedCourses.isEmpty ||
                        selectedCourses.contains(g.courseId);
                    return facOk && couOk;
                  }).toList();

                  final picked = await showDialog<List<Group>>(
                    context: context,
                    builder: (_) => MultiSelectDialog<Group>(
                      items: availableGroups,
                      initiallySelected: availableGroups
                          .where((g) => selectedGroupIds.contains(g.id))
                          .toList(),
                      itemLabel: (g) => g.name,
                    ),
                  );
                  if (picked != null) {
                    setState(() =>
                    selectedGroupIds = picked.map((g) => g.id).toSet());
                  }
                },
                child: Text(
                  selectedGroupIds.isEmpty
                      ? 'Выбрать группы'
                      : allGroups
                      .where((g) => selectedGroupIds.contains(g.id))
                      .map((g) => g.name)
                      .join(', '),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _resetFilters, child: const Text('Сбросить')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _canApply
                        ? () {
                      _applyFilters();
                      setState(() => showFilterDialog = false);
                    }
                        : null,
                    child: const Text('Применить'),
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
    return Material(
      color: Colors.black26,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Удалить студента',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 12),
              Text(st.username,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Вы уверены?'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: btnH,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600),
                        onPressed: () async {
                          final ok = await UserRepository().deleteUser(
                            userId: st.id,
                          );
                          if (ok) {
                            await widget.loadStudents();
                            setState(() {
                              showDeleteDialog = false;
                              isFilteringActive = false;
                            });
                          }
                        },
                        child: const Text('Удалить'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: btnH,
                      child: OutlinedButton(
                        onPressed: () => setState(() => showDeleteDialog = false),
                        child: const Text('Отмена'),
                      ),
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

  Widget _buildEditDialog(BuildContext context, double btnH) {
    final st = filteredStudents[selectedIndex!];
    final w  = MediaQuery.of(context).size.width * 0.7;
    final h  = MediaQuery.of(context).size.height * 0.6;
    return Material(
      color: Colors.black26,
      child: Center(
        child: Container(
          width: w.clamp(300.0, 600.0),
          height: h.clamp(350.0, 550.0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Редактировать студента',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  InkWell(
                    onTap: () => setState(() => showEditDialog = false),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('ФИО', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Группа', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Group>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                value: allGroups.firstWhere(
                      (g) => g.id == st.groupId,
                  orElse: () => allGroups.first,
                ),
                items: allGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedGroupIds = v != null ? {v.id} : {}),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Сделать старостой'),
                value: isHeadman ?? false,
                activeColor: const Color(0xFF4068EA),
                onChanged: (v) => setState(() => isHeadman = v),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: btnH,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await UserRepository().updateUser(
                      userId: st.id,
                      groupId: selectedGroupIds.isEmpty ? null : selectedGroupIds.first,
                      username: nameController.text,
                      isHeadman: isHeadman,
                    );
                    if (ok) {
                      await widget.loadStudents();
                      setState(() {
                        showEditDialog = false;
                        isFilteringActive = false;
                      });
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
