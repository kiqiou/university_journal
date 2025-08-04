import 'package:flutter/cupertino.dart';
import 'package:university_journal/shared/attestation/widgets/attestation_table.dart';

import '../../bloc/services/attestation/model/attestation.dart';

class AttestationContentScreen extends StatelessWidget {
  final List<Attestation> attestations;
  final bool isEditable;
  const AttestationContentScreen({super.key, required this.attestations, required this.isEditable});

  @override
  Widget build(BuildContext context) {
    return AttestationTable(
        attestations: attestations, onUpdate: (int attestationId, int usrIndex, String newGrade) {}, isEditable: isEditable);
  }
}