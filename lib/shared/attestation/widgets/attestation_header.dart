import 'package:flutter/material.dart';
import 'package:university_journal/bloc/services/attestation/model/attestation.dart';
import 'package:university_journal/components/widgets/button.dart';

import '../../../bloc/services/journal/models/session.dart';
import 'average_score_dialog.dart';

class AttestationHeader extends StatelessWidget {
  final int? selectedColumnIndex;
  final bool isEditable;
  final List<Attestation>? attestations;
  final int? Function()? getSelectedUSR;
  final Function(int)? onDeleteUSR;
  final Function(int, double?, String?)? onAttestationUpdate;
  final VoidCallback? onAddUSR;
  final String attestationType;
  final List<Session>? sessions;

  const AttestationHeader({
    super.key,
    required this.selectedColumnIndex,
    required this.getSelectedUSR,
    required this.onDeleteUSR,
    required this.onAddUSR,
    required this.attestationType,
    required this.isEditable, this.onAttestationUpdate, this.attestations, this.sessions,
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
              '($attestationType)',
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
                MyButton(
                  onChange: () {
                    final position = getSelectedUSR!();
                    if (position != null) onDeleteUSR!(position);
                  },
                  buttonName: 'Удалить УСР',
                ),
              MyButton(
                onChange: () {
                  showAverageScoreDialog(context, attestations!, sessions!, onAttestationUpdate!,);
                },
                buttonName: 'Рассчитать средний балл',
              ),
              MyButton(
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
