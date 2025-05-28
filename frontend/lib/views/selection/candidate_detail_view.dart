import 'package:flutter/material.dart';
import '../../models/selection_models.dart';
import '../../utils/constants.dart';

class CandidateDetailView extends StatefulWidget {
  final CandidateModel candidate;
  
  const CandidateDetailView({
    Key? key,
    required this.candidate,
  }) : super(key: key);

  @override
  State<CandidateDetailView> createState() => _CandidateDetailViewState();
}

class _CandidateDetailViewState extends State<CandidateDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.candidate.fullName,
          style: const TextStyle(color: Colors.white),
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
              'Detalle de Candidato',
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