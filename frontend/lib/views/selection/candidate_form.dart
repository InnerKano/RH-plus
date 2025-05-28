import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CandidateForm extends StatefulWidget {
  const CandidateForm({Key? key}) : super(key: key);

  @override
  State<CandidateForm> createState() => _CandidateFormState();
}

class _CandidateFormState extends State<CandidateForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Agregar Candidato',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.textColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.greyDark,
            ),
            SizedBox(height: 16),
            Text(
              'Formulario de Candidato',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'En desarrollo',
              style: TextStyle(
                color: AppColors.greyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}