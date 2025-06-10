import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../bloc/group/group.dart';
import '../../../../bloc/group/group_repository.dart';

class GroupsList extends StatefulWidget {
  final Future<void> Function() loadGroups;
  final List<Group> groups;

  const GroupsList({
    super.key,
    required this.loadGroups,
    required this.groups,
  });

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  final GroupRepository groupRepository = GroupRepository();
  final TextEditingController nameController = TextEditingController();
  int? selectedIndex;
  bool showDeleteDialog = false;
  bool showEditDialog = false;

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
                                        final bool isSelected = selectedIndex != null &&
                                            widget.groups[selectedIndex!].id == group.id;
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
                        final double dialogHeight = (media.height - 64).clamp(480, 1100);
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
                                            const Text(
                                              "Информация",
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                                ),
                                                onPressed: () async {
                                                  // Здесь логика сохранения отредактированных данных
                                                },
                                                child: const Text(
                                                  'Сохранить',
                                                  style: TextStyle(color: Colors.white),
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
                                        SizedBox(height: constraints.maxHeight * 0.03),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: constraints.maxWidth * 0.07),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: constraints.maxHeight * 0.07,
                                                    child: TextField(
                                                      controller: nameController,
                                                      decoration: const InputDecoration(
                                                        labelText: "Название группы",
                                                        hintText: "Введите название группы",
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: constraints.maxHeight * 0.03),
                                                ],
                                              ),
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