import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/views/training/widgets/training_stats_card.dart';
import 'package:rh_plus/views/training/widgets/session_card.dart';

class SupervisorTrainingView extends StatefulWidget {
  const SupervisorTrainingView({Key? key}) : super(key: key);

  @override
  State<SupervisorTrainingView> createState() => _SupervisorTrainingViewState();
}

class _SupervisorTrainingViewState extends State<SupervisorTrainingView> with SingleTickerProviderStateMixin {
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
        // Supervisor header
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de Supervisor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gestión de capacitación para tu equipo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        
        // Supervisor tabs
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
                text: 'Mi Equipo',
              ),
              Tab(
                icon: Icon(Icons.event),
                text: 'Sesiones',
              ),
              Tab(
                icon: Icon(Icons.people),
                text: 'Inscribir',
              ),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTeamTab(),
              _buildSessionsTab(),
              _buildEnrollTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamTab() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team statistics
              Row(
                children: [
                  Expanded(
                    child: TrainingStatsCard(
                      title: 'Miembros Equipo',
                      value: '8', // TODO: Get from actual team data
                      icon: Icons.people,
                      color: AppColors.infoColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TrainingStatsCard(
                      title: 'En Capacitación',
                      value: '3', // TODO: Calculate from attendances
                      icon: Icons.school,
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
                      title: 'Completadas',
                      value: '12', // TODO: Calculate from completed sessions
                      icon: Icons.check_circle,
                      color: AppColors.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TrainingStatsCard(
                      title: 'Pendientes',
                      value: '5', // TODO: Calculate from pending sessions
                      icon: Icons.pending,
                      color: AppColors.errorColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Team training progress
              _buildTeamProgressSection(),
              
              const SizedBox(height: 24),
              
              // Supervisor actions
              _buildSupervisorActionsSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso del Equipo',
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
                // Team member progress items
                _buildTeamMemberProgress('Juan Pérez', 'Inducción General', 85),
                const Divider(),
                _buildTeamMemberProgress('María García', 'Seguridad Industrial', 70),
                const Divider(),
                _buildTeamMemberProgress('Carlos López', 'Atención al Cliente', 95),
                const Divider(),
                _buildTeamMemberProgress('Ana Rodríguez', 'Excel Avanzado', 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMemberProgress(String memberName, String training, int progress) {
    Color progressColor;
    if (progress >= 80) {
      progressColor = AppColors.successColor;
    } else if (progress >= 60) {
      progressColor = AppColors.warningColor;
    } else {
      progressColor = AppColors.errorColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      training,
                      style: TextStyle(
                        color: AppColors.greyDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$progress%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.greyLight,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones de Supervisor',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Inscribir Empleado',
                Icons.person_add,
                AppColors.infoColor,
                () => _tabController.animateTo(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Ver Reportes',
                Icons.assessment,
                AppColors.secondaryColor,
                () => _navigateToTeamReports(),
              ),
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

  Widget _buildSessionsTab() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        if (trainingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Sessions filter
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
                        hintText: 'Buscar sesiones para mi equipo...',
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
                  DropdownButton<String>(
                    value: 'Todas',
                    items: const [
                      DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                      DropdownMenuItem(value: 'Próximas', child: Text('Próximas')),
                      DropdownMenuItem(value: 'En Progreso', child: Text('En Progreso')),
                      DropdownMenuItem(value: 'Completadas', child: Text('Completadas')),
                    ],
                    onChanged: (value) {
                      // TODO: Filter sessions
                    },
                  ),
                ],
              ),
            ),
            
            // Sessions list
            Expanded(
              child: trainingProvider.sessions.isEmpty
                  ? const Center(
                      child: Text('No hay sesiones disponibles'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: trainingProvider.sessions.length,
                      itemBuilder: (context, index) {
                        final session = trainingProvider.sessions[index];
                        return SessionCard(
                          session: session,
                          onTap: () => _navigateToSessionDetail(session),
                          showActions: false,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnrollTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inscribir Empleados a Capacitaciones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona a los miembros de tu equipo para inscribirlos en las capacitaciones disponibles.',
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick enrollment section
          _buildQuickEnrollmentSection(),
          
          const SizedBox(height: 24),
          
          // Available trainings
          _buildAvailableTrainingsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickEnrollmentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inscripción Rápida',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccionar empleado',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Juan Pérez')),
                DropdownMenuItem(value: '2', child: Text('María García')),
                DropdownMenuItem(value: '3', child: Text('Carlos López')),
                DropdownMenuItem(value: '4', child: Text('Ana Rodríguez')),
              ],
              onChanged: (value) {
                // TODO: Handle employee selection
              },
            ),
            
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccionar capacitación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Inducción General')),
                DropdownMenuItem(value: '2', child: Text('Seguridad Industrial')),
                DropdownMenuItem(value: '3', child: Text('Atención al Cliente')),
                DropdownMenuItem(value: '4', child: Text('Excel Avanzado')),
              ],
              onChanged: (value) {
                // TODO: Handle training selection
              },
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enrollEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Inscribir Empleado'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTrainingsSection() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        final availablePrograms = trainingProvider.programs.where((p) => p.isActive).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capacitaciones Disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            
            if (availablePrograms.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No hay capacitaciones disponibles'),
                  ),
                ),
              )
            else
              ...availablePrograms.map((program) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: Icon(
                    Icons.school,
                    color: AppColors.infoColor,
                  ),
                  title: Text(
                    program.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${program.trainingTypeName} • ${program.durationHours} horas',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => _showEnrollDialog(program),
                    tooltip: 'Inscribir empleados',
                  ),
                ),
              )),
          ],
        );
      },
    );
  }

  // Action methods
  void _enrollEmployee() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Empleado inscrito exitosamente')),
    );
  }

  void _showEnrollDialog(TrainingProgramModel program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inscribir a ${program.name}'),
        content: const Text('Selecciona los empleados que deseas inscribir en esta capacitación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Empleados inscritos en ${program.name}')),
              );
            },
            child: const Text('Inscribir'),
          ),
        ],
      ),
    );
  }
  // Navigation methods
  void _navigateToTeamReports() {
    Navigator.pushNamed(context, RouteNames.trainingReports);
  }

  void _navigateToSessionDetail(TrainingSessionModel session) {
    Navigator.pushNamed(
      context,
      RouteNames.trainingAttendanceManagement,
      arguments: {
        'session': session,
      },
    );
  }
}
