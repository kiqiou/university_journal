import 'package:flutter/cupertino.dart';
import 'package:university_journal/shared/attestation/widgets/attestation_header.dart';
import 'package:university_journal/shared/attestation/widgets/attestation_table.dart';

import '../../bloc/services/attestation/model/attestation.dart';

class AttestationContentScreen extends StatelessWidget {
  final List<Attestation> attestations;
  final bool isEditable;
  final int? selectedColumnIndex;
  final Function(int?)? onColumnSelected;
  final Function(int)? onDeleteUSR;
  final VoidCallback? onAddUSR;

  const AttestationContentScreen(
      {super.key,
      required this.attestations,
      required this.isEditable,
      this.selectedColumnIndex,
      this.onColumnSelected,
      this.onDeleteUSR,
      this.onAddUSR});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEditable && onColumnSelected != null) {
          onColumnSelected!(null);
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 40),
          AttestationHeader(
              selectedColumnIndex: selectedColumnIndex,
              getSelectedUSR: () => selectedColumnIndex,
              onDeleteUSR: onDeleteUSR,
              onAddUSR: onAddUSR),
          SizedBox(
            height: 40,
          ),
          Expanded(
            child: AttestationTable(
                attestations: attestations,
                onUpdate: (int attestationId, int usrIndex, String newGrade) {},
                isEditable: isEditable),
          ),
        ],
      ),
    );
  }
}
