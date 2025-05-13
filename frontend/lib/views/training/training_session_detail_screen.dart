import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:intl/intl.dart';

class TrainingSessionDetailScreen extends StatefulWidget {
  final int sessionId;

  const TrainingSessionDetailScreen({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  _TrainingSessionDetailScreenState createState() => _TrainingSessionDetailScreenState();
}

class _TrainingSessionDetailScreenState extends State<TrainingSessionDetailScreen> with SingleTickerProviderStateMixin {
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
    
    // Find the session in the loaded sessions
    final session = trainingProvider.sessions.firstWhere(
      (s) => s.id == widget.sessionId,
      orElse: () => TrainingSessionModel(
        id: -1,
        programId: -1,
        programName: '',
        sessionDate: '',
        startTime: '',
        endTime: '',
        location: '',
        instructorId: -1,
        instructorName: '',
        maxParticipants: 0,
        status: '',
      ),
    );
    
    if (session.id != -1) {
      trainingProvider.setSelectedSession(session);
      await trainingProvider.fetchAttendanceBySession(session.id);
      await trainingProvider.fetchAttendanceStats(session.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Sesión'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Información'),
            Tab(text: 'Asistentes'),
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

          final session = trainingProvider.selectedSession;
          
          if (session == null) {
            return const Center(
              child: Text('Sesión no encontrada'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(trainingProvider, session),
              _buildAttendanceTab(trainingProvider),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<TrainingProvider>(
        builder: (context, trainingProvider, child) {
          final session = trainingProvider.selectedSession;
          
          if (session == null) {
            return const SizedBox.shrink();
          }
          
          // Only show action buttons based on session status
          if (session.status == 'SCHEDULED' || session.status == 'IN_PROGRESS') {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (session.status == 'SCHEDULED')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Start session logic
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar Sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  if (session.status == 'IN_PROGRESS')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Complete session logic
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Completar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Register attendance logic
                      },
                      icon: const Icon(Icons.playlist_add_check),
                      label: const Text('Registrar Asistencia'),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoTab(TrainingProvider trainingProvider, TrainingSessionModel session) {
    final sessionDate = dateFormat.format(DateTime.parse(session.sessionDate));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(session),
          const SizedBox(height: 24),
          _buildSessionInfoCard(session, sessionDate),
          const SizedBox(height: 24),
          _buildStatisticsCard(trainingProvider),
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildNotesCard(session),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(TrainingSessionModel session) {
    Color statusColor;
    String statusText;
    
    switch (session.status) {
      case 'SCHEDULED':
        statusColor = Colors.blue;
        statusText = 'Programado';
        break;
      case 'IN_PROGRESS':
        statusColor = Colors.orange;
        statusText = 'En Progreso';
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusText = 'Completado';
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusText = 'Cancelado';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(session.status),
            color: statusColor,
            size: 28,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.programName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Estado: $statusText',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard(TrainingSessionModel session, String sessionDate) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Fecha', sessionDate),
            _buildInfoRow('Horario', '${timeFormat.format(DateFormat('HH:mm:ss').parse(session.startTime))} - ${timeFormat.format(DateFormat('HH:mm:ss').parse(session.endTime))}'),
            _buildInfoRow('Ubicación', session.location),
            _buildInfoRow('Instructor', session.instructorName),
            _buildInfoRow('Capacidad', '${session.maxParticipants} participantes'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(TrainingProvider trainingProvider) {
    final stats = trainingProvider.attendanceStats;
    
    if (stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No hay estadísticas disponibles'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas de Asistencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Registrados',
                  stats['total_registered'] ?? 0,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Asistieron',
                  stats['total_attended'] ?? 0,
                  Colors.green,
                ),
                _buildStatItem(
                  'Ausentes',
                  stats['total_missed'] ?? 0,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats['attendance_rate'] != null)
              LinearProgressIndicator(
                value: (stats['attendance_rate'] as double) / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            const SizedBox(height: 8),
            if (stats['attendance_rate'] != null)
              Text(
                'Tasa de Asistencia: ${stats['attendance_rate']}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(TrainingSessionModel session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(session.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab(TrainingProvider trainingProvider) {
    if (trainingProvider.attendances.isEmpty) {
      return const Center(
        child: Text('No hay registros de asistencia para esta sesión'),
      );
    }

    // Group attendances by status
    final attendedList = trainingProvider.attendances
        .where((a) => a.status == 'ATTENDED')
        .toList();
    
    final registeredList = trainingProvider.attendances
        .where((a) => a.status == 'REGISTERED')
        .toList();
    
    final absentList = trainingProvider.attendances
        .where((a) => a.status == 'MISSED')
        .toList();
    
    final excusedList = trainingProvider.attendances
        .where((a) => a.status == 'EXCUSED')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (attendedList.isNotEmpty) ...[
          _buildAttendanceGroup('Asistieron', attendedList, Colors.green),
          const SizedBox(height: 16),
        ],
        if (registeredList.isNotEmpty) ...[
          _buildAttendanceGroup('Registrados', registeredList, Colors.blue),
          const SizedBox(height: 16),
        ],
        if (absentList.isNotEmpty) ...[
          _buildAttendanceGroup('No Asistieron', absentList, Colors.red),
          const SizedBox(height: 16),
        ],
        if (excusedList.isNotEmpty) ...[
          _buildAttendanceGroup('Excusados', excusedList, Colors.orange),
        ],
      ],
    );
  }

  Widget _buildAttendanceGroup(String title, List<TrainingAttendanceModel> attendances, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$title (${attendances.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Card(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: attendances.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final attendance = attendances[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(attendance.employeeName),
                subtitle: attendance.comments != null && attendance.comments!.isNotEmpty
                    ? Text(attendance.comments!)
                    : null,
                trailing: attendance.evaluationScore != null
                    ? Chip(
                        label: Text(
                          attendance.evaluationScore.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getScoreColor(attendance.evaluationScore!),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'SCHEDULED':
        return Icons.calendar_today;
      case 'IN_PROGRESS':
        return Icons.play_circle;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
