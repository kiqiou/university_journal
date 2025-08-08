import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';

class AttestationHeader extends StatelessWidget {
  final int? selectedColumnIndex;
  final bool isEditable;
  final int? Function()? getSelectedUSR;
  final Function(int)? onDeleteUSR;
  final VoidCallback? onAddUSR;
  final String attestationType;

  const AttestationHeader({
    super.key,
    required this.selectedColumnIndex,
    required this.getSelectedUSR,
    required this.onDeleteUSR,
    required this.onAddUSR,
    required this.attestationType,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Аттестация',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              attestationType,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        if (isEditable) ...[
          Row(
            children: [
              if (selectedColumnIndex != null)
                SessionButton(
                  onChange: () {
                    final position = getSelectedUSR!();
                    if (position != null) onDeleteUSR!(position);
                  },
                  buttonName: 'Удалить УСР',
                ),
              SessionButton(
                onChange: onAddUSR!,
                buttonName: 'Добавить УСР',
              ),
            ],
          ),
        ]
      ],
    );
  }
}
