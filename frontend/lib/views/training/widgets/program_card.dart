import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/utils/constants.dart';

class ProgramCard extends StatelessWidget {
  final TrainingProgramModel program;
  final VoidCallback onTap;
  final bool showActions;

  const ProgramCard({
    Key? key,
    required this.program,
    required this.onTap,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          program.trainingTypeName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: program.isActive ? AppColors.successColor : AppColors.greyMedium,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      program.isActive ? 'Activo' : 'Inactivo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                program.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.greyDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${program.durationHours} horas',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyDark,
                    ),
                  ),
                  const Spacer(),
                  if (showActions) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(context),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 20),
                      onPressed: onTap,
                      tooltip: 'Ver detalles',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar programa: ${program.name}')),
    );
  }
}
