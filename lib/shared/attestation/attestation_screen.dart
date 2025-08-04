import 'package:flutter/cupertino.dart';

import '../../bloc/services/attestation/model/attestation.dart';
import 'attestation_bloc_handler.dart';

class AttestationScreen extends StatelessWidget{
  final bool isEditable;
  const AttestationScreen({super.key, required this.isEditable});

  @override
  Widget build(BuildContext context) {
    return AttestationBlocHandler(onUpdate: () {}, isEditable: isEditable,);
  }

}