import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/utils/constants.dart';

class SessionCard extends StatelessWidget {
  final TrainingSessionModel session;
  final VoidCallback onTap;
  final bool showActions;
  final String? actionText;
  final IconData? actionIcon;
  final bool isReadOnly;

  const SessionCard({
    Key? key,
    required this.session,
    required this.onTap,
    this.showActions = false,
    this.actionText,
    this.actionIcon,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (session.status) {
      case 'SCHEDULED':
        statusColor = AppColors.infoColor;
        statusIcon = Icons.calendar_today;
        statusText = 'Programado';
        break;
      case 'IN_PROGRESS':
        statusColor = AppColors.warningColor;
        statusIcon = Icons.play_circle;
        statusText = 'En Progreso';
        break;
      case 'COMPLETED':
        statusColor = AppColors.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'Completado';
        break;
      case 'CANCELLED':
        statusColor = AppColors.errorColor;
        statusIcon = Icons.cancel;
        statusText = 'Cancelado';
        break;
      default:
        statusColor = AppColors.greyMedium;
        statusIcon = Icons.help;
        statusText = 'Desconocido';
    }

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
                          session.programName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.instructorName,
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
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(DateTime.parse(session.sessionDate)),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.startTime} - ${session.endTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      session.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyDark,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.people,
                    size: 16,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Max: ${session.maxParticipants}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
                if (showActions && !isReadOnly) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (actionText == null) ...[
                      TextButton.icon(
                        onPressed: () => _showAttendanceDialog(context),
                        icon: const Icon(Icons.people_alt, size: 16),
                        label: const Text('Asistencia'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.infoColor,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Ver más'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ] else ...[
                      TextButton.icon(
                        onPressed: onTap,
                        icon: Icon(actionIcon ?? Icons.add, size: 16),
                        label: Text(actionText!),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ver asistencia: ${session.programName}')),
    );
  }
}
