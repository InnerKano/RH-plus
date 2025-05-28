import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/training_models.dart';
import '../../../providers/training_provider.dart';
import 'session_card.dart';

class UserTrainingView extends StatefulWidget {
  const UserTrainingView({Key? key}) : super(key: key);

  @override
  State<UserTrainingView> createState() => _UserTrainingViewState();
}

class _UserTrainingViewState extends State<UserTrainingView> {
  late TrainingProvider _trainingProvider;
  List<TrainingSessionModel> _availableSessions = [];
  List<TrainingProgramModel> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      // Get the provider instance from context
      _trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
      
      await _trainingProvider.fetchTrainingPrograms();
      await _trainingProvider.fetchUpcomingSessions();
      
      _programs = _trainingProvider.programs;
      _availableSessions = _trainingProvider.sessions.where((session) => 
        session.status == 'scheduled' && 
        DateTime.parse(session.sessionDate).isAfter(DateTime.now())
      ).toList();
      
    } catch (e) {
      debugPrint('Error loading user training data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Formación',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'Vista de solo lectura',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Programs Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Programas de Formación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_programs.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 48,
                          color: AppColors.textSecondaryColor,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No hay programas disponibles',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._programs.map((program) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                program.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(program.isActive ? 'active' : 'inactive').withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatusText(program.isActive ? 'active' : 'inactive'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getStatusColor(program.isActive ? 'active' : 'inactive'),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (program.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            program.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${program.durationHours}h',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Todo el año',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Available Sessions Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Próximas Sesiones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_availableSessions.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 48,
                          color: AppColors.textSecondaryColor,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No hay sesiones programadas',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._availableSessions.take(5).map((session) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: SessionCard(
                      session: session,
                      onTap: () => _viewSessionInfo(session),
                      showActions: false,
                      isReadOnly: true,
                    ),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.infoColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.infoColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acceso Limitado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Esta es una vista de solo lectura. Para inscribirte en sesiones o acceder a funciones adicionales, contacta a tu supervisor o al departamento de RH.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.successColor;
      case 'draft':
        return AppColors.warningColor;
      case 'archived':
        return AppColors.textSecondaryColor;
      default:
        return AppColors.infoColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'draft':
        return 'Borrador';
      case 'archived':
        return 'Archivado';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _viewSessionInfo(TrainingSessionModel session) {
    // Show session information dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.programName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.notes ?? 'Sin detalles adicionales'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(_formatDate(session.sessionDate)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text('${session.startTime} - ${session.endTime}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Text(session.location),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
