import 'package:flutter/cupertino.dart';

import '../../bloc/services/attestation/model/attestation.dart';
import '../../bloc/services/journal/models/session.dart';
import 'attestation_bloc_handler.dart';

class AttestationScreen extends StatefulWidget {
  final bool isEditable;
  final String attestationType;
  final Function(int?)? onColumnSelected;
  final Function(int)? onDeleteUSR;
  final Function(int, double?, String?)? onAttestationUpdate;
  final Function(int, int)? onUSRUpdate;
  final VoidCallback? onAddUSR;

  const AttestationScreen({
    super.key,
    required this.isEditable,
    this.onColumnSelected,
    this.onDeleteUSR,
    this.onAddUSR, this.onAttestationUpdate, this.onUSRUpdate, required this.attestationType,
  });

  @override
  State<AttestationScreen> createState() => _AttestationScreenState();
}

class _AttestationScreenState extends State<AttestationScreen> {
  int? selectedColumnIndex;

  void _handleColumnSelected(int? index) {
    setState(() {
      selectedColumnIndex = index;
    });
    if (widget.onColumnSelected != null) {
      widget.onColumnSelected!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AttestationBlocHandler(
      isEditable: widget.isEditable,
      attestationType: widget.attestationType,
      onAddUSR: widget.onAddUSR,
      onDeleteUSR: widget.onDeleteUSR,
      onAttestationUpdate: widget.onAttestationUpdate,
      onUSRUpdate: widget.onUSRUpdate,
      selectedColumnIndex: selectedColumnIndex,
      onColumnSelected: _handleColumnSelected,
    );
  }
}
