import 'package:flutter/material.dart';
import '../../../../components/colors/colors.dart';
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
  }) : super(key: key);

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final userRepository = UserRepository();

  late List<MyUser> allStudents = [];
  late List<MyUser> filteredStudents = [];

  int? selectedCourse;
  Group? selectedGroup;
  List<int> courses = [];

  int? selectedIndex;
  bool showDeleteDialog = false;
  bool showEditDialog = false;
  bool? isHeadman;
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.loadStudents().then((_) {
      setState(() {
        allStudents = List.from(widget.students);
        _setupFilterValues();
        _applyFilters();
      });
    });
  }

  int? getStudentCourse(MyUser u) {
    try {
      final g = widget.groups.firstWhere((g) => g.id == u.groupId);
      return (g.courseId >= 1 && g.courseId <= 4) ? g.courseId : null;
    } catch (_) {
      return null;
    }
  }

  void _setupFilterValues() {
    courses = allStudents
        .map(getStudentCourse)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
  }

  void _applyFilters() {
    filteredStudents = allStudents.where((u) {
      final cMatch = selectedCourse == null ||
          getStudentCourse(u) == selectedCourse;
      final gMatch = selectedGroup == null ||
          u.groupId == selectedGroup!.id;
      return cMatch && gMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    const baseWidth = 1920.0;
    final scale = media.width / baseWidth;
    final btnHeight = 40.0 * scale;
    final btnWidths = [260.0, 290.0].map((w) => w * scale).toList();

    return Scaffold(
      body: Stack(
        children: [
          _buildMainContent(btnHeight, btnWidths),
          if (showDeleteDialog && selectedIndex != null)
            Center(child: _buildDeleteDialog(btnWidths, btnHeight)),
          if (showEditDialog && selectedIndex != null)
            Center(child: _buildEditDialog(media)),
        ],
      ),
    );
  }

  Widget _buildMainContent(double btnHeight, List<double> btnWidths) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Панель фильтров
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Фильтры',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  DropdownButton<int>(
                    hint: const Text('Курс'),
                    value: selectedCourse,
                    isExpanded: true,
                    items: courses
                        .map((c) =>
                        DropdownMenuItem(value: c, child: Text('$c курс')))
                        .toList(),
                    onChanged: (v) => setState(() {
                      selectedCourse = v;
                      _applyFilters();
                    }),
                  ),

                  const SizedBox(height: 12),

                  DropdownButton<Group>(
                    hint: const Text('Группа'),
                    value: selectedGroup,
                    isExpanded: true,
                    items: widget.groups
                        .map((g) =>
                        DropdownMenuItem(value: g, child: Text(g.name)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      selectedGroup = v;
                      _applyFilters();
                    }),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() {
                        selectedCourse = null;
                        selectedGroup = null;
                        _applyFilters();
                      }),
                      child: const Text('Сбросить'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Заголовок и кнопки
          Row(
            children: [
              const Text('Список студентов',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const Spacer(),
              if (selectedIndex != null) ...[
                SizedBox(
                  width: btnWidths[0],
                  height: btnHeight,
                  child: ElevatedButton(
                    onPressed: () => setState(() => showDeleteDialog = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4068EA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Удалить студента',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: btnWidths[1],
                  height: btnHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      final st = filteredStudents[selectedIndex!];
                      nameController.text = st.username;
                      selectedGroup = st.groupId == null
                          ? null
                          : widget.groups
                          .firstWhere((g) => g.id == st.groupId);
                      isHeadman = st.isHeadman;
                      setState(() => showEditDialog = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4068EA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Редактировать студента',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Список студентов
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, i) {
                final st = filteredStudents[i];
                final courseText = getStudentCourse(st)?.toString() ?? '-';
                final groupText = st.groupName ?? '-';

                return ListTile(
                  title: Row(
                    children: [
                      Text(st.username),
                      if (st.isHeadman == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: student.isHeadman! ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                student.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Отмечен как староста',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ) : Text(
                            student.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),

                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('Курс: $courseText, Группа: $groupText'),
                  selected: selectedIndex == i,
                  onTap: () => setState(() => selectedIndex = i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteDialog(List<double> btnW, double btnH) {
    final stu = filteredStudents[selectedIndex!];
    return Material(
      color: Colors.black26,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Удаление студента',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            Text(stu.username,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Вы действительно хотите удалить студента?'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: btnH,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok =
                        await userRepository.deleteUser(userId: stu.id);
                        if (ok) {
                          await widget.loadStudents();
                          setState(() {
                            showDeleteDialog = false;
                            selectedIndex = null;
                            allStudents = List.from(widget.students);
                            _applyFilters();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4068EA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Удалить'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: btnH,
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => showDeleteDialog = false),
                      child: const Text('Отмена'),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditDialog(Size media) {
    final stu = filteredStudents[selectedIndex!];
    final dialogW = (media.width * 0.8).clamp(320.0, 600.0);
    final dialogH = (media.height * 0.8).clamp(480.0, 600.0);

    return Material(
      color: Colors.black26,
      child: Container(
        width: dialogW,
        height: dialogH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4068EA), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Редактирование студента',
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade700)),
                  const Spacer(),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4068EA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      onPressed: () async {
                        final ok = await userRepository.updateUser(
                          userId: stu.id,
                          groupId: selectedGroup?.id,
                          username: nameController.text,
                          isHeadman: isHeadman,
                        );
                        if (ok) {
                          await widget.loadStudents();
                          setState(() {
                            showEditDialog = false;
                            selectedIndex = null;
                            allStudents =
                                List.from(widget.students);
                            _applyFilters();
                          });
                        }
                      },
                      child: const Text('Сохранить',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () =>
                        setState(() => showEditDialog = false),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: const Color(0xFF4068EA),
                          borderRadius: BorderRadius.circular(8)),
                      child:
                      const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text('ФИО студента',
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Введите ФИО',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: MyColors.blueJournal, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text('Привязка группы',
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Group>(
                value: selectedGroup,
                items: widget.groups
                    .map((g) => DropdownMenuItem(
                  value: g,
                  child: Text(g.name),
                ))
                    .toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: MyColors.blueJournal,
                        width: 1.5),
                  ),
                ),
                onChanged: (v) => setState(() => selectedGroup = v),
              ),

              const SizedBox(height: 24),

              const Text('Отметить как старосту',
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Сделать старостой'),
                value: isHeadman ?? false,
                activeColor: MyColors.blueJournal,
                onChanged: (v) => setState(() => isHeadman = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}