import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/training_models.dart';
import '../../../providers/training_provider.dart';
import 'training_stats_card.dart';
import 'session_card.dart';

class EmployeeTrainingView extends StatefulWidget {
  const EmployeeTrainingView({Key? key}) : super(key: key);

  @override
  State<EmployeeTrainingView> createState() => _EmployeeTrainingViewState();
}

class _EmployeeTrainingViewState extends State<EmployeeTrainingView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TrainingProvider _trainingProvider;
  List<TrainingSessionModel> _mySessions = [];
  List<TrainingSessionModel> _upcomingSessions = [];
  bool _isLoading = true;

  // Add calculation methods
  double _calculateTotalHours(List<TrainingSessionModel> sessions) {
    return sessions.fold<double>(0, (sum, session) => sum + (session.endTime.isNotEmpty && session.startTime.isNotEmpty ? 
      _calculateSessionDuration(session.startTime, session.endTime) : 0));
  }
  
  double _calculateSessionDuration(String startTime, String endTime) {
    try {
      final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]), 
        minute: int.parse(startTime.split(':')[1])
      );
      final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]), 
        minute: int.parse(endTime.split(':')[1])
      );
      
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      
      return (endMinutes - startMinutes) / 60.0;
    } catch (e) {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Defer initialization until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmployeeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeData() async {
    setState(() => _isLoading = true);
    try {
      // Get the provider instance from context
      _trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
      
      // Load employee's training data using the correct method
      await _trainingProvider.fetchUpcomingSessions();
      final allSessions = _trainingProvider.sessions;
      
      // Filter sessions for current employee
      // Since we don't have attendees field, we'll just use all sessions for now
      _mySessions = allSessions;
      
      // Filter for upcoming sessions based on sessionDate
      _upcomingSessions = allSessions.where((session) => 
        session.status == 'scheduled' && 
        DateTime.parse(session.sessionDate).isAfter(DateTime.now())
      ).toList();
      
    } catch (e) {
      debugPrint('Error loading employee training data: $e');
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

    return Column(
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
                Icons.school,
                color: AppColors.primaryColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mi Formación',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  Text(
                    'Gestiona tu desarrollo profesional',
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
        const SizedBox(height: 16),
        
        // Tab Bar
        Container(
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
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondaryColor,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Resumen'),
              Tab(text: 'Mis Sesiones'),
              Tab(text: 'Disponibles'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildMySessionsTab(),
              _buildAvailableSessionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final completedSessions = _mySessions.where((s) => s.status == 'completed').length;
    final inProgressSessions = _mySessions.where((s) => s.status == 'in_progress').length;
    final totalHours = _calculateTotalHours(_mySessions);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: TrainingStatsCard(
                  title: 'Sesiones Completadas',
                  value: completedSessions.toString(),
                  icon: Icons.check_circle,
                  color: AppColors.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TrainingStatsCard(
                  title: 'En Progreso',
                  value: inProgressSessions.toString(),
                  icon: Icons.pending,
                  color: AppColors.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TrainingStatsCard(
                  title: 'Horas Totales',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  icon: Icons.access_time,
                  color: AppColors.infoColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TrainingStatsCard(
                  title: 'Próximas Sesiones',
                  value: _upcomingSessions.length.toString(),
                  icon: Icons.event,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Progress
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
                      Icons.trending_up,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mi Progreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_mySessions.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: AppColors.textSecondaryColor,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No hay sesiones registradas',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._mySessions.take(3).map((session) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(session.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.programName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                              Text(
                                _formatDate(session.sessionDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(session.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(session.status),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatusColor(session.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySessionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_mySessions.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes sesiones asignadas',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Consulta la pestaña "Disponibles" para inscribirte',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._mySessions.map((session) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: SessionCard(
                session: session,
                onTap: () => _viewSessionDetails(session),
                showActions: false,
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildAvailableSessionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_upcomingSessions.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay sesiones disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Consulta próximamente para nuevas sesiones',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._upcomingSessions.map((session) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: SessionCard(
                session: session,
                onTap: () => _enrollInSession(session),
                showActions: true,
                actionText: 'Inscribirse',
                actionIcon: Icons.person_add,
              ),
            )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.successColor;
      case 'in_progress':
        return AppColors.warningColor;
      case 'scheduled':
        return AppColors.infoColor;
      case 'cancelled':
        return AppColors.errorColor;
      default:
        return AppColors.textSecondaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completado';
      case 'in_progress':
        return 'En Progreso';
      case 'scheduled':
        return 'Programado';
      case 'cancelled':
        return 'Cancelado';
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

  void _viewSessionDetails(TrainingSessionModel session) {
    // Navigate to session details
    // This would be implemented with proper navigation
    debugPrint('Viewing session details: ${session.programName}');
  }

  void _enrollInSession(TrainingSessionModel session) {
    // Show enrollment confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inscripción'),
        content: Text(
          '¿Deseas inscribirte en la sesión "${session.programName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performEnrollment(session);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Inscribirse'),
          ),
        ],
      ),
    );
  }

  void _performEnrollment(TrainingSessionModel session) {
    // Implement enrollment logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te has inscrito en "${session.programName}"'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }
}
