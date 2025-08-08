import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/attestation/attestation_bloc.dart';
import '../../bloc/services/attestation/model/attestation.dart';
import 'attestation_content_screen.dart';

class AttestationBlocHandler extends StatelessWidget {
  final bool isEditable;
  final int? selectedColumnIndex;
  final String attestationType;
  final Function(int?)? onColumnSelected;
  final Function(int)? onDeleteUSR;
  final Function(int, double?, String?)? onAttestationUpdate;
  final Function(int, int)? onUSRUpdate;
  final VoidCallback? onAddUSR;

  const AttestationBlocHandler({
    super.key,
    required this.isEditable,
    this.selectedColumnIndex,
    this.onColumnSelected,
    this.onDeleteUSR,
    this.onAddUSR,
    this.onAttestationUpdate,
    this.onUSRUpdate, required this.attestationType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttestationBloc, AttestationState>(
      builder: (context, state) {
        if (state is AttestationLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is AttestationError) {
          return Center(child: Text('Ошибка: ${state.message}'));
        }

        if (state is AttestationLoaded) {
          final attestations = state.attestations;

          return AttestationContentScreen(
            attestations: attestations,
            attestationType: attestationType,
            isEditable: isEditable,
            selectedColumnIndex: selectedColumnIndex,
            onAddUSR: onAddUSR,
            onColumnSelected: onColumnSelected,
            onDeleteUSR: onDeleteUSR,
            onAttestationUpdate: onAttestationUpdate,
            onUSRUpdate: onUSRUpdate,
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
