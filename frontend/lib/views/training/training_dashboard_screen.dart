import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:intl/intl.dart';

class TrainingDashboardScreen extends StatefulWidget {
  const TrainingDashboardScreen({Key? key}) : super(key: key);

  @override
  _TrainingDashboardScreenState createState() => _TrainingDashboardScreenState();
}

class _TrainingDashboardScreenState extends State<TrainingDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('HH:mm');
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
    await trainingProvider.fetchTrainingPrograms();
    await trainingProvider.fetchUpcomingSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capacitaciones'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Próximas Sesiones'),
            Tab(text: 'Programas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, trainingProvider, child) {
          if (trainingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (trainingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${trainingProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingSessionsTab(trainingProvider),
              _buildProgramsTab(trainingProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate based on current tab
          if (_tabController.index == 0) {
            // Create new session
          } else {
            // Create new program
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Nuevo',
      ),
    );
  }

  Widget _buildUpcomingSessionsTab(TrainingProvider trainingProvider) {
    if (trainingProvider.sessions.isEmpty) {
      return const Center(
        child: Text('No hay sesiones programadas próximamente'),
      );
    }

    return ListView.builder(
      itemCount: trainingProvider.sessions.length,
      itemBuilder: (context, index) {
        final session = trainingProvider.sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(TrainingSessionModel session) {
    final sessionDate = dateFormat.format(DateTime.parse(session.sessionDate));
    
    Color statusColor;
    IconData statusIcon;
    
    switch (session.status) {
      case 'SCHEDULED':
        statusColor = Colors.blue;
        statusIcon = Icons.calendar_today;
        break;
      case 'IN_PROGRESS':
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle;
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to session detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          sessionDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      _getStatusName(session.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${timeFormat.format(DateFormat('HH:mm:ss').parse(session.startTime))} - ${timeFormat.format(DateFormat('HH:mm:ss').parse(session.endTime))}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(session.location)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(session.instructorName),
                  const Spacer(),
                  const Icon(Icons.group, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Max: ${session.maxParticipants}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramsTab(TrainingProvider trainingProvider) {
    if (trainingProvider.programs.isEmpty) {
      return const Center(
        child: Text('No hay programas de capacitación disponibles'),
      );
    }

    return ListView.builder(
      itemCount: trainingProvider.programs.length,
      itemBuilder: (context, index) {
        final program = trainingProvider.programs[index];
        return _buildProgramCard(program);
      },
    );
  }

  Widget _buildProgramCard(TrainingProgramModel program) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to program detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          program.trainingTypeName,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: program.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: program.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    child: Text(
                      program.isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: program.isActive ? Colors.green : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                program.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${program.durationHours} horas'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusName(String status) {
    switch (status) {
      case 'SCHEDULED':
        return 'Programado';
      case 'IN_PROGRESS':
        return 'En Progreso';
      case 'COMPLETED':
        return 'Completado';
      case 'CANCELLED':
        return 'Cancelado';
      default:
        return status;
    }
  }
}
