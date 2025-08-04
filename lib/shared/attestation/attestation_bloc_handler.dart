import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/attestation/attestation_bloc.dart';
import '../../bloc/services/attestation/model/attestation.dart';
import 'attestation_content_screen.dart';

class AttestationBlocHandler extends StatelessWidget {
  final List<Attestation> attestations;
  final VoidCallback onUpdate;
  final bool isEditable;

  const AttestationBlocHandler({
    super.key,
    required this.isEditable,
    required this.attestations,
    required this.onUpdate,
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
            isEditable: isEditable,
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
