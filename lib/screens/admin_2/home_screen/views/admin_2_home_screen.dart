import 'package:flutter/material.dart';
import 'package:university_journal/screens/admin_2/home_screen/components/admin_2_side_navigation_menu.dart';
import 'package:university_journal/screens/admin_2/home_screen/components/add_student.dart';

class Student {
  final String name;
  Student(this.name);
}

class Group {
  final String name;
  final List<Student> students;
  Group(this.name, [List<Student>? students]) : students = students ?? [];
}

class Course {
  final String name;
  final List<Group> groups;
  Course(this.name, [List<Group>? groups]) : groups = groups ?? [];
}

class Admin2HomeScreen extends StatefulWidget {
  const Admin2HomeScreen({super.key});

  @override
  State<Admin2HomeScreen> createState() => _Admin2HomeScreenState();
}

class _Admin2HomeScreenState extends State<Admin2HomeScreen> {
  List<Course> courses = [];
  int? selectedCourseIndex;
  int? selectedGroupIndex;
  int? selectedStudentIndex;
  bool isLoading = true;
  bool showDeleteDialog = false;
  bool showEditDialog = false;

  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      // Загрузка из репозитория, если нужно
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Ошибка при загрузке студентов: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addCourse() async {
    courseNameController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить курс'),
        content: TextField(
          controller: courseNameController,
          decoration: const InputDecoration(labelText: 'Название курса'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (courseNameController.text.trim().isNotEmpty) {
                setState(() {
                  courses.add(Course(courseNameController.text.trim()));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _addGroup(int courseIndex) async {
    groupNameController.clear();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить группу'),
        content: TextField(
          controller: groupNameController,
          decoration: const InputDecoration(labelText: 'Название группы'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (groupNameController.text.trim().isNotEmpty) {
                setState(() {
                  courses[courseIndex].groups.add(Group(groupNameController.text.trim()));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _addStudent(int courseIndex, int groupIndex) async {
    await showDialog(
      context: context,
      builder: (context) => AddStudentDialog(
        onStudentAdded: () {
          setState(() {});
        },
        onSave: (String fio, String? group, String? bio) {
          // group и bio можно не использовать, если не нужно
          setState(() {
            courses[courseIndex].groups[groupIndex].students.add(Student(fio));
          });
        },
      ),
    );
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
          Admin2SideNavigationMenu(
            onStudentAdded: () async {
              await loadStudents();
            },
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
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
                            if (selectedStudentIndex != null) ...[
                              // Кнопки удаления, редактирования, привязки группы
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _addCourse,
                          child: const Text('Добавить курс'),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                            itemCount: courses.length,
                            itemBuilder: (context, courseIndex) {
                              final course = courses[courseIndex];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        course.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: () => _addGroup(courseIndex),
                                        child: const Text('Добавить группу'),
                                      ),
                                    ],
                                  ),
                                  ...course.groups.asMap().entries.map((groupEntry) {
                                    final groupIndex = groupEntry.key;
                                    final group = groupEntry.value;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              group.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: () => _addStudent(courseIndex, groupIndex),
                                              child: const Text('Добавить студента'),
                                            ),
                                          ],
                                        ),
                                        ...group.students.asMap().entries.map((studentEntry) {
                                          final idx = studentEntry.key + 1;
                                          final student = studentEntry.value;
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 24.0, top: 4.0, bottom: 4.0),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 32,
                                                  child: Text(
                                                    '$idx',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black54,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Container(
                                                    height: 40,
                                                    alignment: Alignment.centerLeft,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                    child: Text(
                                                      student.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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