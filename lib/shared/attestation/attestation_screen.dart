import 'package:flutter/cupertino.dart';

import '../../bloc/services/attestation/model/attestation.dart';
import 'attestation_bloc_handler.dart';

class AttestationScreen extends StatefulWidget {
  final bool isEditable;
  final Function(int?)? onColumnSelected;
  final Function(int)? onDeleteUSR;
  final VoidCallback? onAddUSR;

  const AttestationScreen({
    super.key,
    required this.isEditable,
    this.onColumnSelected,
    this.onDeleteUSR,
    this.onAddUSR,
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
      onAddUSR: widget.onAddUSR,
      onDeleteUSR: widget.onDeleteUSR,
      selectedColumnIndex: selectedColumnIndex,
      onColumnSelected: _handleColumnSelected,
      onUpdate: () {},
    );
  }
}
