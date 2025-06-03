import 'package:flutter/material.dart';
import '../../../../bloc/journal/journal_repository.dart';
import '../../../../bloc/user/user.dart';

class StudentsList extends StatefulWidget {
  final Future<void> Function() loadStudents;
  final List<MyUser> students;

  const StudentsList({
    super.key,
    required this.loadStudents,
    required this.students,
  });

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final journalRepository = JournalRepository();
  int? selectedIndex;
  bool isLoading = true;
  bool showDeleteDialog = false;
  bool showEditDialog = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.loadStudents();
  }

  void _openEditDialog(MyUser student) {
    setState(() {
      selectedIndex = student.id;
      showEditDialog = true;
      nameController.text = student.username;
      bioController.text = student.bio ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Список студентов',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
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
                                child: const Text('Удалить студента', style: TextStyle(color: Colors.white)),
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
                                child: const Text('Редактировать информацию', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.students.length,
                          itemBuilder: (context, index) {
                            final student = widget.students[index];
                            return ListTile(
                              title: Text(student.username),
                              selected: selectedIndex == student.id,
                              onTap: () {
                                setState(() {
                                  selectedIndex = student.id;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
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