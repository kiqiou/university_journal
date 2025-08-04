import 'package:flutter/cupertino.dart';

import '../../bloc/services/attestation/model/attestation.dart';
import 'attestation_bloc_handler.dart';

class AttestationScreen extends StatelessWidget{
  final List<Attestation> attestations;
  final bool isEditable;
  const AttestationScreen({super.key, required this.attestations, required this.isEditable});

  @override
  Widget build(BuildContext context) {
    return AttestationBlocHandler(attestations: attestations, onUpdate: () {}, isEditable: isEditable,);
  }

}