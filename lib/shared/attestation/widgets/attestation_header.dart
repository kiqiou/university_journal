import 'package:flutter/material.dart';
import 'package:university_journal/components/widgets/button.dart';

class AttestationHeader extends StatelessWidget {
  final int? selectedColumnIndex;
  final int? Function()? getSelectedUSR;
  final Function(int)? onDeleteUSR;
  final VoidCallback? onAddUSR;

  const AttestationHeader({
    super.key,
    required this.selectedColumnIndex,
    required this.getSelectedUSR,
    required this.onDeleteUSR,
    required this.onAddUSR,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Аттестация',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade700),),
        if (selectedColumnIndex != null) ...[
          SessionButton(
            onChange: () {
              final position = getSelectedUSR!();
              if (position != null) onDeleteUSR!(position);
            },
            buttonName: 'Удалить УСР',
          ),
        ],
        SessionButton(
          onChange: onAddUSR!,
          buttonName: 'Добавить УСР',
        ),
      ],
    );
  }
}
