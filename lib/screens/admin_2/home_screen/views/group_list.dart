import 'package:flutter/material.dart';
import '../../../../bloc/journal/group.dart';
import '../../../../bloc/journal/journal_repository.dart';

class GroupsList extends StatefulWidget {
  final Future<void> Function() loadGroups;
  final List<Group> groups;

  const GroupsList({Key? key, required this.loadGroups, required this.groups}) : super(key: key);

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  final journalRepository = JournalRepository();
  int? selectedIndex;
  bool isLoading = true;
  bool showDeleteDialog = false;
  bool showEditDialog = false;

  final TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.loadGroups();
  }

  void _openEditDialog(Group group) {
    setState(() {
      selectedIndex = group.id;
      showEditDialog = true;
      groupNameController.text = group.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
    final screenWidth = MediaQuery.of(context).size.width;
    const baseScreenWidth = 1920.0;
    const baseButtonHeight = 40.0;
    const baseWidths = [260.0, 290.0];
    final scale = screenWidth / baseScreenWidth;
    final buttonHeights = baseButtonHeight * scale;
    final buttonWidths = baseWidths.map((w) => w * scale).toList();

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Список групп',
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
                      child: const Text('Удалить группу', style: TextStyle(color: Colors.white)),
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
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return ListTile(
                    title: Text(group.name),
                    selected: selectedIndex == group.id,
                    onTap: () {
                      setState(() {
                        selectedIndex = group.id;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}