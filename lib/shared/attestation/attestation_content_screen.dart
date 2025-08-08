import 'package:flutter/cupertino.dart';
import 'package:university_journal/shared/attestation/widgets/attestation_header.dart';
import 'package:university_journal/shared/attestation/widgets/attestation_table.dart';

import '../../bloc/services/attestation/model/attestation.dart';

class AttestationContentScreen extends StatefulWidget {
  final List<Attestation> attestations;
  final bool isEditable;
  final int? selectedColumnIndex;
  final Function(int?)? onColumnSelected;
  final Function(int, double?, String?)? onAttestationUpdate;
  final Function(int, int)? onUSRUpdate;
  final Function(int)? onDeleteUSR;
  final VoidCallback? onAddUSR;

  const AttestationContentScreen(
      {super.key,
      required this.attestations,
      required this.isEditable,
      this.selectedColumnIndex,
      this.onColumnSelected,
      this.onDeleteUSR,
      this.onAddUSR,
      this.onAttestationUpdate,
      this.onUSRUpdate});

  @override
  State<AttestationContentScreen> createState() =>
      _AttestationContentScreenState();
}

class _AttestationContentScreenState extends State<AttestationContentScreen> {
  int? selectedColumnIndex;

  @override
  void initState() {
    super.initState();
    selectedColumnIndex = widget.selectedColumnIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.isEditable && widget.onColumnSelected != null) {
          setState(() {
            selectedColumnIndex = null;
          });
          widget.onColumnSelected!(null);
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 40),
          AttestationHeader(
            selectedColumnIndex: selectedColumnIndex,
            getSelectedUSR: () => selectedColumnIndex,
            onDeleteUSR: widget.onDeleteUSR,
            onAddUSR: widget.onAddUSR,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: AttestationTable(
              attestations: widget.attestations,
              selectedColumnIndex: selectedColumnIndex,
              onUSRUpdate: widget.onUSRUpdate,
              onAttestationUpdate: widget.onAttestationUpdate,
              onColumnSelected: (index) {
                setState(() {
                  selectedColumnIndex = index;
                });
                if (widget.onColumnSelected != null) {
                  widget.onColumnSelected!(index);
                }
              },
              isEditable: widget.isEditable,
            ),
          ),
        ],
      ),
    );
  }
}
