import 'package:flutter/material.dart';
import '../../../bloc/services/group/group_repository.dart';

class GroupsList extends StatefulWidget {
  final Future<void> Function() loadGroups;

  const GroupsList({
    super.key,
    required this.loadGroups,
  });

  @override
  State<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  final GroupRepository groupRepository = GroupRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 180,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Подтверждение'),
                  content: const Text('Вы уверены, что хотите перевести группы на следующий курс?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Да'),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;

              try {
                final groups = await groupRepository.getGroupsList();
                if (groups == null) throw Exception('Не удалось получить группы');

                bool allSuccess = true;

                for (final group in groups) {
                  int newCourseId;
                  if (group.courseId >= 1 && group.courseId < 4) {
                    newCourseId = group.courseId + 1;
                  } else if (group.courseId == 4) {
                    newCourseId = 0;
                  } else {
                    newCourseId = group.courseId;
                  }

                  final success = await groupRepository.updateGroup(
                    groupId: group.id,
                    courseId: newCourseId,
                  );

                  if (!success) allSuccess = false;
                }

                if (allSuccess) {
                  await widget.loadGroups();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Все группы переведены на следующий курс')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ошибка при обновлении некоторых групп')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4068EA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Переход на следующий курс',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}