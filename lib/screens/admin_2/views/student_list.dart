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
    required this.groups,
    required List allGroups,
  }) : super(key: key);

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList>
    with AutomaticKeepAliveClientMixin<StudentsList> {
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
    selectedCourses   = Set.from(_savedCourses);
    selectedGroupIds  = Set.from(_savedGroupIds);
    isFilteringActive = _savedFilteringActive;

    widget.loadStudents().then((_) => _populateLocalData());
  }

  @override
  void didUpdateWidget(covariant StudentsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students ||
        oldWidget.groups   != widget.groups) {
      _populateLocalData();
    }
  }

  void _populateLocalData() {
    allStudents = widget.students.toList();
    allGroups   = widget.groups.toList();

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

    if (isFilteringActive && _canApply) {
      _applyFilters(noSetState: true);
    } else {
      filteredStudents = allStudents;
    }

    setState(() {});
  }

  bool get _canApply =>
      selectedFaculties.isNotEmpty ||
          selectedCourses.isNotEmpty   ||
          selectedGroupIds.isNotEmpty;

  void _applyFilters({bool noSetState = false}) {
    final newList = allStudents.where((u) {
      final grpMatch = allGroups.where((g) => g.id == u.groupId);
      if (grpMatch.isEmpty) return false;
      final grp = grpMatch.first;

      final facOk = selectedFaculties.isEmpty ||
          selectedFaculties.contains(grp.facultyName);
      final couOk = selectedCourses.isEmpty ||
          selectedCourses.contains(grp.courseId);
      final grpOk = selectedGroupIds.isEmpty ||
          selectedGroupIds.contains(grp.id);

      return facOk && couOk && grpOk;
    }).toList();

    if (noSetState) {
      filteredStudents = newList;
      return;
    }

    setState(() {
      isFilteringActive       = true;
      filteredStudents        = newList;
      _savedFaculties         = Set.from(selectedFaculties);
      _savedCourses           = Set.from(selectedCourses);
      _savedGroupIds          = Set.from(selectedGroupIds);
      _savedFilteringActive   = true;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedFaculties = {};
      selectedCourses   = {};
      selectedGroupIds  = {};
      isFilteringActive = false;
      filteredStudents  = allStudents;
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
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              icon: const Icon(Icons.filter_list),
              label: const Text('Изменить фильтры'),
              onPressed: () => setState(() => showFilterDialog = true),
            ),
          ),

          if (selectedIndex != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4068EA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Редактировать'),
                onPressed: _onEditPressed,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                icon: const Icon(Icons.delete, size: 20),
                label: const Text('Удалить'),
                onPressed: () => setState(() => showDeleteDialog = true),
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

          if (showFilterDialog)
            Center(child: _buildFilterDialog(context)),

          if (showDeleteDialog && selectedIndex != null)
            Positioned(
              top: 16,
              right: 16,
              child: _buildDeleteDialog(btnH),
            ),

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
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
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
    final w = (MediaQuery.of(context).size.width * 0.6).clamp(300.0, 600.0);
    final h = (MediaQuery.of(context).size.height * 0.7).clamp(400.0, 600.0);

    final sortedFaculties = List<String>.from(allFaculties)..sort();
    final sortedCourses    = List<int>.from(allCourses)..sort();

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
                sortedFaculties,
                selectedFaculties,
                'Все факультеты',
                    (f) => f,
                    (sel) => setState(() => selectedFaculties = sel),
              ),
              const SizedBox(height: 16),

              multiDropdown<int>(
                'Курс',
                sortedCourses,
                selectedCourses,
                'Все курсы',
                    (c) => '$c курс',
                    (sel) => setState(() => selectedCourses = sel),
              ),
              const SizedBox(height: 16),

              Text('Группы', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final availableGroups = allGroups
                      .where((g) {
                    final facOk = selectedFaculties.isEmpty ||
                        selectedFaculties.contains(g.facultyName);
                    final couOk = selectedCourses.isEmpty ||
                        selectedCourses.contains(g.courseId);
                    return facOk && couOk;
                  })
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));

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
                    setState(() {
                      selectedGroupIds = picked.map((g) => g.id).toSet();
                    });
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
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
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
                'Удаление студента',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => showDeleteDialog = false),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4068EA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            st.username,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Вы действительно хотите удалить студента?'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: btnH,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
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
                  const Text(
                    'Редактировать студента',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                onChanged: (v) =>
                    setState(() => selectedGroupIds = v != null ? {v.id} : {}),
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
                      groupId: selectedGroupIds.isEmpty
                          ? null
                          : selectedGroupIds.first,
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