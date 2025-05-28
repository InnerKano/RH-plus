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
    if (_selectedProgram != null) {
      await fetchSessionsByProgram(_selectedProgram!.id);
    } else {
      await fetchUpcomingSessions();
    }
  }
  
  // Training Programs
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

  Future<void> createProgram(Map<String, dynamic> programData) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _trainingService.createProgram(programData);
      _programs.add(TrainingProgramModel.fromJson(response));
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateProgram(Map<String, dynamic> programData) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _trainingService.updateProgram(
        programData['id'],
        programData,
      );
      
      final index = _programs.indexWhere((p) => p.id == programData['id']);
      if (index != -1) {
        _programs[index] = TrainingProgramModel.fromJson(response);
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteProgram(int programId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _trainingService.deleteProgram(programId);
      _programs.removeWhere((p) => p.id == programId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Training Sessions
  Future<void> fetchUpcomingSessions() async {
    _setLoading(true);
    _setError(null);

    try {
      _sessions = await _trainingService.getUpcomingSessions();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchSessionsByProgram(int programId) async {
    _setLoading(true);
    _setError(null);

    try {
      _sessions = await _trainingService.getSessionsByProgram(programId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Attendance Management
  Future<void> fetchAttendanceBySession(int sessionId) async {
    _setLoading(true);
    _setError(null);

    try {
      _attendances = await _trainingService.getAttendanceBySession(sessionId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchAttendanceByEmployee(int employeeId) async {
    _setLoading(true);
    _setError(null);

    try {
      _attendances = await _trainingService.getAttendanceByEmployee(employeeId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchAttendanceStats(int sessionId) async {
    _setLoading(true);
    _setError(null);

    try {
      _attendanceStats = await _trainingService.getAttendanceStats(sessionId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
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
}
