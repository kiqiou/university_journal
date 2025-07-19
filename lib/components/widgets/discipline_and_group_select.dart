import 'package:flutter/material.dart';
import '../../bloc/services/discipline/models/discipline.dart';
import '../../bloc/services/user/models/user.dart';
import 'input_decoration.dart';

class GroupSelectDialog extends StatelessWidget {
  final bool show;
  final bool showGroupSelect;
  final bool showTeacherSelect;
  final List<MyUser>? teachers;
  final List<Discipline> disciplines;
  final int? selectedDisciplineIndex;
  final int? selectedGroupId;
  final int? selectedTeacherIndex;
  final GlobalKey<FormState> formKey;
  final void Function(int?) onDisciplineChanged;
  final void Function(int?)? onGroupChanged;
  final void Function(int?)? onTeacherChanged;
  final void Function() onClose;
  final Future<void> Function(int groupId) onSubmit;

  const GroupSelectDialog({
    super.key,
    required this.show,
    this.selectedGroupId,
    this.onGroupChanged,
    required this.disciplines,
    required this.selectedDisciplineIndex,
    required this.formKey,
    required this.onDisciplineChanged,
    required this.onClose,
    required this.onSubmit,
    required this.showGroupSelect,
    required this.showTeacherSelect, this.selectedTeacherIndex, this.teachers, this.onTeacherChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    final media = MediaQuery.of(context).size;
    final double dialogWidth =
        (media.width - 32 - 80).clamp(320, 600).toDouble();
    final double screenWidth = media.width;
    final double screenHeight = media.height;

    if (screenWidth < 500 || screenHeight < 500) {
      return const SizedBox.shrink();
    }

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
                          Expanded(
                            child: Text(
                              'Выберите дисциплину и группу',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                size: 28, color: Colors.black54),
                            splashRadius: 24,
                            onPressed: onClose,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(showTeacherSelect)...[
                              Text(
                                'Преподавателя*',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 18),
                            DropdownButtonFormField<int>(
                              value: selectedTeacherIndex,
                              decoration:
                              inputDecoration('Выберите преподавателя'),
                              items: List.generate(teachers!.length, (index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    teachers![index].username,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                );
                              }),
                              onChanged: onTeacherChanged,
                              validator: (value) =>
                              value == null ? 'Выберите дисциплину' : null,
                            ),
                            SizedBox(height: 18,),
                            ],
                            if(selectedTeacherIndex != null || !showTeacherSelect)...[
                            Text(
                              'Выберите дисциплину*',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<int>(
                              value: selectedDisciplineIndex,
                              decoration:
                                  inputDecoration('Выберите дисциплину'),
                              items: List.generate(selectedTeacherIndex != null
                                  ? teachers![selectedTeacherIndex!].disciplines.length
                                  : disciplines.length, (index) {
                                final discipline = selectedTeacherIndex != null
                                    ? teachers![selectedTeacherIndex!].disciplines[index]
                                    : disciplines[index];
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    discipline.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                );
                              }),
                              onChanged: onDisciplineChanged,
                              validator: (value) =>
                                  value == null ? 'Выберите дисциплину' : null,
                            ),
                            ],
                            const SizedBox(height: 18),
                            if (selectedDisciplineIndex != null &&
                                showGroupSelect)...[
                              Text(
                                'Выберите группу*',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            const SizedBox(height: 18),
                              DropdownButtonFormField<int>(
                                value: selectedGroupId,
                                decoration: inputDecoration('Выберите группу'),
                                items: disciplines[selectedDisciplineIndex!]
                                    .groups
                                    .map((group) {
                                  return DropdownMenuItem<int>(
                                    value: group.id,
                                    child: Text(group.name),
                                  );
                                }).toList(),
                                onChanged: onGroupChanged,
                                validator: (value) =>
                                    value == null ? 'Выберите группу' : null,
                              ),
                            ],
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                if (selectedGroupId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Группа не выбрана')),
                                  );
                                  return;
                                }

                                try {
                                  await onSubmit(selectedGroupId!);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Ошибка при загрузке данных: $e')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4068EA),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 12),
                                minimumSize: const Size.fromHeight(55),
                              ),
                              child: const Text('Подтвердить',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
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
