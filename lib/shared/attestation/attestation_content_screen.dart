import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:university_journal/shared/attestation/widgets/attestation_header.dart';
import 'package:university_journal/shared/attestation/widgets/attestation_table.dart';

import '../../bloc/services/attestation/model/attestation.dart';
import '../../bloc/services/journal/models/session.dart';

class AttestationContentScreen extends StatefulWidget {
  final List<Attestation> attestations;
  final bool isEditable;
  final int? selectedColumnIndex;
  final String attestationType;
  final Function(int?)? onColumnSelected;
  final Function(int, double?, String?)? onAttestationUpdate;
  final Function(int, int)? onUSRUpdate;
  final Function(int)? onDeleteUSR;
  final VoidCallback? onAddUSR;
  final List<Session>? sessions;

  const AttestationContentScreen(
      {super.key,
      required this.attestations,
      required this.isEditable,
      this.selectedColumnIndex,
      this.onColumnSelected,
      this.onDeleteUSR,
      this.onAddUSR,
      this.onAttestationUpdate,
      this.onUSRUpdate, required this.attestationType, this.sessions});

  @override
  State<AttestationContentScreen> createState() =>
      _AttestationContentScreenState();
}

class _AttestationContentScreenState extends State<AttestationContentScreen> {
  final _tableKey = GlobalKey<AttestationTableState>();
  int? selectedColumnIndex;

  @override
  void initState() {
    super.initState();
    selectedColumnIndex = widget.selectedColumnIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        AttestationHeader(
          attestationType: widget.attestationType,
          isEditable: widget.isEditable,
          attestations: widget.attestations,
          selectedColumnIndex: selectedColumnIndex,
          getSelectedUSR: () => selectedColumnIndex,
          onDeleteUSR: widget.onDeleteUSR,
          onAddUSR: widget.onAddUSR,
          onAttestationUpdate: (id, avg, result) {
            widget.onAttestationUpdate?.call(id, avg, result);

            if (avg != null) {
              final i = widget.attestations.indexWhere((a) => a.id == id);
              if (i != -1) {
                widget.attestations[i].averageScore = avg;
                _tableKey.currentState?.updateAverageScore(id, avg);
              }
            }
          },
          sessions: widget.sessions,
        ),
        const SizedBox(height: 40),
        Expanded(
          child: AttestationTable(
            key: _tableKey,
            attestations: widget.attestations,
            selectedColumnIndex: selectedColumnIndex,
            onUSRUpdate: widget.onUSRUpdate,
            onAttestationUpdate: widget.onAttestationUpdate,
            onColumnSelected: (index) {
              setState(() => selectedColumnIndex = index);
              widget.onColumnSelected?.call(index);
            },
            isEditable: widget.isEditable,
          ),
        ),
      ],
    );
  }
}

