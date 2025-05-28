import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/views/training/widgets/training_stats_card.dart';
import 'package:rh_plus/views/training/widgets/program_card.dart';
import 'package:rh_plus/views/training/widgets/session_card.dart';

class HRTrainingView extends StatefulWidget {
  const HRTrainingView({Key? key}) : super(key: key);

  @override
  State<HRTrainingView> createState() => _HRTrainingViewState();
}

class _HRTrainingViewState extends State<HRTrainingView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HR control panel with tabs
        Container(
          color: AppColors.surfaceColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.greyDark,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(
                icon: Icon(Icons.dashboard),
                text: 'Resumen',
              ),
              Tab(
                icon: Icon(Icons.library_books),
                text: 'Programas',
              ),
              Tab(
                icon: Icon(Icons.event),
                text: 'Sesiones',
              ),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(),
              _buildProgramsTab(),
              _buildSessionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HR Statistics
              Text(
                'Panel de Recursos Humanos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Statistics row
              Row(
                children: [
                  Expanded(
                    child: TrainingStatsCard(
                      title: 'Programas Activos',
                      value: trainingProvider.programs.where((p) => p.isActive).length.toString(),
                      icon: Icons.library_books,
                      color: AppColors.infoColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TrainingStatsCard(
                      title: 'Sesiones del Mes',
                      value: _getMonthlySessionsCount(trainingProvider).toString(),
                      icon: Icons.event,
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
                      title: 'Participantes',
                      value: trainingProvider.attendances.length.toString(),
                      icon: Icons.people,
                      color: AppColors.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TrainingStatsCard(
                      title: 'Tasa Asistencia',
                      value: '${_calculateAttendanceRate(trainingProvider)}%',
                      icon: Icons.trending_up,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // HR Actions
              _buildHRActionsSection(),
              
              const SizedBox(height: 24),
              
              // Upcoming sessions preview
              _buildUpcomingSessionsPreview(trainingProvider),
              
              const SizedBox(height: 24),
              
              // Recent programs
              _buildRecentProgramsPreview(trainingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHRActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Capacitación',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Crear Programa',
              Icons.add_circle,
              AppColors.infoColor,
              () => _navigateToCreateProgram(),
            ),
            _buildActionCard(
              'Programar Sesión',
              Icons.event_note,
              AppColors.warningColor,
              () => _navigateToCreateSession(),
            ),
            _buildActionCard(
              'Gestionar Asistencias',
              Icons.people_alt,
              AppColors.successColor,
              () => _navigateToManageAttendances(),
            ),
            _buildActionCard(
              'Reportes HR',
              Icons.analytics,
              AppColors.secondaryColor,
              () => _navigateToHRReports(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionsPreview(TrainingProvider trainingProvider) {
    final upcomingSessions = trainingProvider.sessions.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximas Sesiones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (upcomingSessions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No hay sesiones próximas programadas'),
              ),
            ),
          )
        else
          ...upcomingSessions.map((session) => SessionCard(
            session: session,
            onTap: () => _navigateToSessionDetail(session),
            showActions: false,
          )),
      ],
    );
  }

  Widget _buildRecentProgramsPreview(TrainingProvider trainingProvider) {
    final recentPrograms = trainingProvider.programs.where((p) => p.isActive).take(2).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Programas Activos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (recentPrograms.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No hay programas activos'),
              ),
            ),
          )
        else
          ...recentPrograms.map((program) => ProgramCard(
            program: program,
            onTap: () => _navigateToProgramDetail(program),
            showActions: false,
          )),
      ],
    );
  }

  Widget _buildProgramsTab() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        if (trainingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // HR Programs header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar programas...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateProgram,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Programs list
            Expanded(
              child: trainingProvider.programs.isEmpty
                  ? const Center(
                      child: Text('No hay programas de capacitación registrados'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: trainingProvider.programs.length,
                      itemBuilder: (context, index) {
                        final program = trainingProvider.programs[index];
                        return ProgramCard(
                          program: program,
                          onTap: () => _navigateToProgramDetail(program),
                          showActions: true,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        if (trainingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // HR Sessions header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar sesiones...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateSession,
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Sessions list
            Expanded(
              child: trainingProvider.sessions.isEmpty
                  ? const Center(
                      child: Text('No hay sesiones programadas'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: trainingProvider.sessions.length,
                      itemBuilder: (context, index) {
                        final session = trainingProvider.sessions[index];
                        return SessionCard(
                          session: session,
                          onTap: () => _navigateToSessionDetail(session),
                          showActions: true,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // Helper methods
  int _getMonthlySessionsCount(TrainingProvider trainingProvider) {
    final now = DateTime.now();
    return trainingProvider.sessions.where((session) {
      final sessionDate = DateTime.parse(session.sessionDate);
      return sessionDate.month == now.month && sessionDate.year == now.year;
    }).length;
  }

  int _calculateAttendanceRate(TrainingProvider trainingProvider) {
    if (trainingProvider.attendances.isEmpty) return 0;
    
    final attended = trainingProvider.attendances.where((attendance) => 
        attendance.status == 'ATTENDED').length;
    return ((attended / trainingProvider.attendances.length) * 100).round();
  }
  // Navigation methods
  void _navigateToCreateProgram() {
    Navigator.pushNamed(
      context,
      RouteNames.trainingProgramForm,
      arguments: {
        'program': null,
        'isEditing': false,
      },
    );
  }

  void _navigateToCreateSession() {
    Navigator.pushNamed(
      context,
      RouteNames.trainingSessionForm,
      arguments: {
        'session': null,
        'isEditing': false,
      },
    );
  }

  void _navigateToManageAttendances() {
    Navigator.pushNamed(context, RouteNames.trainingReports);
  }

  void _navigateToHRReports() {
    Navigator.pushNamed(context, RouteNames.trainingReports);
  }
  void _navigateToProgramDetail(TrainingProgramModel program) {
    Navigator.pushNamed(
      context,
      RouteNames.trainingProgramForm,
      arguments: {
        'program': program,
        'isEditing': true,
      },
    );
  }

  void _navigateToSessionDetail(TrainingSessionModel session) {
    Navigator.pushNamed(
      context,
      RouteNames.trainingSessionForm,
      arguments: {
        'session': session,
        'isEditing': true,
      },
    );
  }
}
