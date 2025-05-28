import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/training_models.dart';
import '../../../providers/training_provider.dart';
import '../widgets/training_stats_card.dart';

class TrainingReportsScreen extends StatefulWidget {
  const TrainingReportsScreen({super.key});

  @override
  State<TrainingReportsScreen> createState() => _TrainingReportsScreenState();
}

class _TrainingReportsScreenState extends State<TrainingReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TrainingProvider _trainingProvider;
  
  // Report data
  Map<String, dynamic> _overviewStats = {};
  List<Map<String, dynamic>> _programStats = [];
  List<Map<String, dynamic>> _departmentStats = [];
  List<Map<String, dynamic>> _attendanceStats = [];
  
  bool _isLoading = true;
  String _selectedPeriod = 'last_30_days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReportData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      // Get the provider from context
      _trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
      
      // Load all training data
      await _trainingProvider.fetchTrainingPrograms();
      await _trainingProvider.fetchUpcomingSessions();
      
      _generateOverviewStats();
      _generateProgramStats();
      _generateDepartmentStats();
      _generateAttendanceStats();
      
    } catch (e) {
      debugPrint('Error loading report data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }  void _generateOverviewStats() {
    final programs = _trainingProvider.programs;
    final sessions = _trainingProvider.sessions;
    
    final activePrograms = programs.where((p) => p.isActive).length;
    final completedSessions = sessions.where((s) => s.status == 'completed').length;
    
    // Calculate total hours based on session durations
    final totalHours = sessions.fold<double>(0, (sum, session) {
      // Find the program for this session
      final program = programs.firstWhere(
        (p) => p.id == session.programId,
        orElse: () => TrainingProgramModel(
          id: -1, 
          name: '', 
          description: '', 
          trainingTypeId: -1, 
          trainingTypeName: '',
          durationHours: 0,
          objectives: '',
          isActive: false
        ),
      );
      return sum + program.durationHours;
    });
    
    final avgAttendance = _calculateAverageAttendance();
    
    _overviewStats = {
      'activePrograms': activePrograms,
      'totalSessions': sessions.length,
      'completedSessions': completedSessions,
      'totalHours': totalHours,
      'averageAttendance': avgAttendance,
    };
  }
  void _generateProgramStats() {
    final programs = _trainingProvider.programs;
    final sessions = _trainingProvider.sessions;
    
    _programStats = programs.map((program) {
      final programSessions = sessions.where((s) => s.programId == program.id).toList();
      final completedSessions = programSessions.where((s) => s.status == 'completed').length;
      final totalParticipants = programSessions.fold<int>(0, (sum, s) => sum + s.maxParticipants);
      
      return {
        'program': program,
        'totalSessions': programSessions.length,
        'completedSessions': completedSessions,
        'totalParticipants': totalParticipants,
        'completionRate': programSessions.isNotEmpty ? (completedSessions / programSessions.length * 100) : 0.0,
      };
    }).toList();
  }

  void _generateDepartmentStats() {
    // This would typically use actual department data from the backend
    final mockDepartments = ['Recursos Humanos', 'Tecnología', 'Ventas', 'Marketing', 'Finanzas'];
    
    _departmentStats = mockDepartments.map((dept) {
      final participations = (10 + (dept.hashCode % 50)).abs(); // Mock data
      final completions = (participations * (0.7 + (dept.hashCode % 30) / 100)).round();
      
      return {
        'department': dept,
        'participations': participations,
        'completions': completions,
        'completionRate': participations > 0 ? (completions / participations * 100) : 0.0,
      };
    }).toList();
  }
  void _generateAttendanceStats() {
    final sessions = _trainingProvider.sessions;
    
    _attendanceStats = sessions.map((session) {
      final totalInvited = session.maxParticipants;
      final actualAttendees = _trainingProvider.attendances
          .where((a) => a.sessionId == session.id)
          .length;
      final attendanceRate = totalInvited > 0 ? (actualAttendees / totalInvited * 100) : 0.0;
      
      return {
        'session': session,
        'totalInvited': totalInvited,
        'actualAttendees': actualAttendees,
        'attendanceRate': attendanceRate,
      };
    }).toList();
  }
  double _calculateAverageAttendance() {
    final sessions = _trainingProvider.sessions.where((s) => s.status == 'completed');
    if (sessions.isEmpty) return 0.0;
    
    double totalRate = 0.0;
    int count = 0;
    
    for (final session in sessions) {
      final maxParticipants = session.maxParticipants;
      final attendees = _trainingProvider.attendances
          .where((a) => a.sessionId == session.id)
          .length;
      if (maxParticipants > 0) {
        totalRate += (attendees / maxParticipants * 100);
        count++;
      }
    }
    
    return count > 0 ? totalRate / count : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Reportes de Formación',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadReportData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'last_7_days',
                child: Text('Últimos 7 días'),
              ),
              const PopupMenuItem(
                value: 'last_30_days',
                child: Text('Últimos 30 días'),
              ),
              const PopupMenuItem(
                value: 'last_3_months',
                child: Text('Últimos 3 meses'),
              ),
              const PopupMenuItem(
                value: 'last_year',
                child: Text('Último año'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          )
        : Column(
            children: [
              // Tab Bar
              Container(
                margin: const EdgeInsets.all(16),
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
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Resumen'),
                    Tab(text: 'Programas'),
                    Tab(text: 'Departamentos'),
                    Tab(text: 'Asistencia'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildProgramsTab(),
                    _buildDepartmentsTab(),
                    _buildAttendanceTab(),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          Row(
            children: [
              Expanded(
                child: TrainingStatsCard(
                  title: 'Programas Activos',
                  value: _overviewStats['activePrograms']?.toString() ?? '0',
                  icon: Icons.school,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TrainingStatsCard(
                  title: 'Sesiones Totales',
                  value: _overviewStats['totalSessions']?.toString() ?? '0',
                  icon: Icons.event,
                  color: AppColors.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TrainingStatsCard(
                  title: 'Sesiones Completadas',
                  value: _overviewStats['completedSessions']?.toString() ?? '0',
                  icon: Icons.check_circle,
                  color: AppColors.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TrainingStatsCard(
                  title: 'Horas Totales',
                  value: '${(_overviewStats['totalHours'] ?? 0).toStringAsFixed(1)}h',
                  icon: Icons.access_time,
                  color: AppColors.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TrainingStatsCard(
            title: 'Promedio de Asistencia',
            value: '${(_overviewStats['averageAttendance'] ?? 0).toStringAsFixed(1)}%',
            icon: Icons.people,
            color: AppColors.successColor,
          ),
          
          const SizedBox(height: 24),
          
          // Period Summary
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildProgramsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_programStats.isEmpty)
            const Center(
              child: Text(
                'No hay datos de programas disponibles',
                style: TextStyle(color: AppColors.textSecondaryColor),
              ),
            )
          else
            ..._programStats.map((stat) => _buildProgramCard(stat)),
        ],
      ),
    );
  }

  Widget _buildDepartmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_departmentStats.isEmpty)
            const Center(
              child: Text(
                'No hay datos de departamentos disponibles',
                style: TextStyle(color: AppColors.textSecondaryColor),
              ),
            )
          else
            ..._departmentStats.map((stat) => _buildDepartmentCard(stat)),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_attendanceStats.isEmpty)
            const Center(
              child: Text(
                'No hay datos de asistencia disponibles',
                style: TextStyle(color: AppColors.textSecondaryColor),
              ),
            )
          else
            ..._attendanceStats.map((stat) => _buildAttendanceCard(stat)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
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
                Icons.summarize,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Resumen del Período',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getPeriodDescription(),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            'Tasa de Finalización',
            _calculateCompletionRate(),
            AppColors.successColor,
          ),
          const SizedBox(height: 8),
          _buildProgressBar(
            'Participación',
            _calculateParticipationRate(),
            AppColors.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> stat) {
    final program = stat['program'] as TrainingProgramModel;
    final completionRate = stat['completionRate'] as double;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Expanded(
                child: Text(
                  program.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCompletionColor(completionRate).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${completionRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCompletionColor(completionRate),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Sesiones', stat['totalSessions'].toString()),
              _buildStatItem('Completadas', stat['completedSessions'].toString()),
              _buildStatItem('Participantes', stat['totalParticipants'].toString()),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar('Completación', completionRate, _getCompletionColor(completionRate)),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> stat) {
    final department = stat['department'] as String;
    final completionRate = stat['completionRate'] as double;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                Icons.business,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  department,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Participaciones', stat['participations'].toString()),
              _buildStatItem('Completadas', stat['completions'].toString()),
              _buildStatItem('Tasa', '${completionRate.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar('Progreso', completionRate, _getCompletionColor(completionRate)),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> stat) {
    final session = stat['session'] as TrainingSessionModel;
    final attendanceRate = stat['attendanceRate'] as double;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [          Text(
            session.programName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session.programName,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Invitados', stat['totalInvited'].toString()),
              _buildStatItem('Asistieron', stat['actualAttendees'].toString()),
              _buildStatItem('Asistencia', '${attendanceRate.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar('Asistencia', attendanceRate, _getAttendanceColor(attendanceRate)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryColor,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: AppColors.borderColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 80) return AppColors.successColor;
    if (rate >= 60) return AppColors.warningColor;
    return AppColors.errorColor;
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return AppColors.successColor;
    if (rate >= 70) return AppColors.warningColor;
    return AppColors.errorColor;
  }

  String _getPeriodDescription() {
    switch (_selectedPeriod) {
      case 'last_7_days':
        return 'Datos de los últimos 7 días';
      case 'last_30_days':
        return 'Datos de los últimos 30 días';
      case 'last_3_months':
        return 'Datos de los últimos 3 meses';
      case 'last_year':
        return 'Datos del último año';
      default:
        return 'Período seleccionado';
    }
  }

  double _calculateCompletionRate() {
    final total = _overviewStats['totalSessions'] ?? 0;
    final completed = _overviewStats['completedSessions'] ?? 0;
    return total > 0 ? (completed / total * 100) : 0.0;
  }

  double _calculateParticipationRate() {
    // Mock calculation - in real app this would use actual participation data
    return 75.0;
  }
}
