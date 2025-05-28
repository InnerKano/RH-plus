import 'package:flutter/foundation.dart';
import 'package:rh_plus/models/training_models.dart';
import 'package:rh_plus/services/training_service.dart';

class TrainingProvider with ChangeNotifier {
  final TrainingService _trainingService;
  
  List<TrainingProgramModel> _programs = [];
  List<TrainingSessionModel> _sessions = [];
  List<TrainingAttendanceModel> _attendances = [];
  
  TrainingProgramModel? _selectedProgram;
  TrainingSessionModel? _selectedSession;
  Map<String, dynamic>? _attendanceStats;
  
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  
  // Getters
  List<TrainingProgramModel> get programs => _programs;
  List<TrainingSessionModel> get sessions => _sessions;
  List<TrainingAttendanceModel> get attendances => _attendances;
  TrainingProgramModel? get selectedProgram => _selectedProgram;
  TrainingSessionModel? get selectedSession => _selectedSession;
  Map<String, dynamic>? get attendanceStats => _attendanceStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  TrainingProvider({required String token})
      : _trainingService = TrainingService(token: token);
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
  
  Future<void> refresh() async {
    _error = null;
    await fetchTrainingPrograms();
  }
  
  Future<void> fetchTrainingPrograms() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      _programs = await _trainingService.getTrainingPrograms();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Training sessions
  Future<void> fetchUpcomingSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _trainingService.getUpcomingSessions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSessionsByProgram(int programId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _trainingService.getSessionsByProgram(programId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Attendance
  Future<void> fetchAttendanceBySession(int sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _trainingService.getAttendanceBySession(sessionId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceByEmployee(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _trainingService.getAttendanceByEmployee(employeeId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceStats(int sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceStats = await _trainingService.getAttendanceStats(sessionId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Selection methods
  void setSelectedProgram(TrainingProgramModel program) {
    _selectedProgram = program;
    notifyListeners();
  }

  void setSelectedSession(TrainingSessionModel session) {
    _selectedSession = session;
    notifyListeners();
  }

  void clearSelectedProgram() {
    _selectedProgram = null;
    notifyListeners();
  }

  void clearSelectedSession() {
    _selectedSession = null;
    notifyListeners();
  }

  void clearAttendanceStats() {
    _attendanceStats = null;
    notifyListeners();
  }

  // Program CRUD operations
  Future<void> createProgram(Map<String, dynamic> programData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _trainingService.createProgram(programData);
      _programs.add(TrainingProgramModel.fromJson(response));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e; // Re-throw para manejo en la UI
    }
  }

  Future<void> updateProgram(Map<String, dynamic> programData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _trainingService.updateProgram(
        programData['id'],
        programData,
      );
      
      final index = _programs.indexWhere((p) => p.id == programData['id']);
      if (index != -1) {
        _programs[index] = TrainingProgramModel.fromJson(response);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteProgram(int programId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _trainingService.deleteProgram(programId);
      _programs.removeWhere((p) => p.id == programId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}
