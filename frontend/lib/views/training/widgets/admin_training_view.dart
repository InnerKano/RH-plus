import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/views/training/widgets/training_stats_card.dart';
import 'package:rh_plus/views/training/widgets/program_card.dart';
import 'package:rh_plus/views/training/widgets/session_card.dart';

class AdminTrainingView extends StatefulWidget {
  const AdminTrainingView({Key? key}) : super(key: key);

  @override
  State<AdminTrainingView> createState() => _AdminTrainingViewState();
}

class _AdminTrainingViewState extends State<AdminTrainingView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        // Admin control panel with tabs
        Container(
          color: AppColors.surfaceColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.greyDark,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(
                icon: Icon(Icons.dashboard),
                text: 'Dashboard',
              ),
              Tab(
                icon: Icon(Icons.library_books),
                text: 'Programas',
              ),
              Tab(
                icon: Icon(Icons.event),
                text: 'Sesiones',
              ),
              Tab(
                icon: Icon(Icons.analytics),
                text: 'Reportes',
              ),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(),
              _buildProgramsTab(),
              _buildSessionsTab(),
              _buildReportsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      title: 'Próximas Sesiones',
                      value: trainingProvider.sessions.length.toString(),
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
                      title: 'Total Asistencias',
                      value: trainingProvider.attendances.length.toString(),
                      icon: Icons.people,
                      color: AppColors.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TrainingStatsCard(
                      title: 'Programas Completados',
                      value: '0', // TODO: Calculate from sessions
                      icon: Icons.check_circle,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Quick actions
              _buildQuickActionsSection(),
              
              const SizedBox(height: 24),
              
              // Recent activity
              _buildRecentActivitySection(trainingProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Nuevo Programa',
                Icons.add_circle,
                AppColors.infoColor,
                () => _navigateToCreateProgram(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Nueva Sesión',
                Icons.event_note,
                AppColors.warningColor,
                () => _navigateToCreateSession(),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
          Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Gestionar Tipos',
                Icons.category,
                AppColors.secondaryColor,
                () => _navigateToManageTypes(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Ver Reportes',
                Icons.analytics,
                AppColors.successColor,
                () => _tabController.animateTo(3),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Gestionar Asistencias',
                Icons.how_to_reg,
                AppColors.primaryColor,
                () => _showSessionSelectionDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container()), // Empty space for alignment
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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

  Widget _buildRecentActivitySection(TrainingProvider trainingProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (trainingProvider.sessions.isNotEmpty) ...[
                  ...trainingProvider.sessions.take(3).map((session) => 
                    _buildActivityItem(
                      'Sesión programada: ${session.programName}',
                      session.sessionDate,
                      Icons.event,
                      AppColors.infoColor,
                    ),
                  ),
                ] else
                  _buildActivityItem(
                    'No hay actividad reciente',
                    DateTime.now().toString(),
                    Icons.info,
                    AppColors.greyMedium,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dateFormat.format(DateTime.parse(date)),
                  style: TextStyle(
                    color: AppColors.greyDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                        fillColor: AppColors.surfaceColor,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                        fillColor: AppColors.surfaceColor,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reportes y Estadísticas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, RouteNames.trainingReports),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.analytics, size: 48, color: AppColors.primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      'Ver Reportes Completos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acceder a reportes detallados y estadísticas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  void _navigateToManageTypes() {
    // Navigate to training reports screen for now, as type management can be part of reports
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
  void _navigateToAttendanceManagement(TrainingSessionModel session) {
    Navigator.pushNamed(
      context,
      RouteNames.trainingAttendanceManagement,
      arguments: {
        'session': session,
      },
    );
  }

  void _showSessionSelectionDialog() {
    final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
    
    if (trainingProvider.sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sesiones disponibles')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Sesión'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: trainingProvider.sessions.length,
            itemBuilder: (context, index) {
              final session = trainingProvider.sessions[index];
              return ListTile(
                title: Text(session.programName),
                subtitle: Text('${session.sessionDate} - ${session.startTime}'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAttendanceManagement(session);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
