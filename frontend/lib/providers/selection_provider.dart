import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/selection_models.dart';
import '../services/selection_service.dart';

class SelectionProvider with ChangeNotifier {
  SelectionService? _selectionService;
  
  // State variables
  List<CandidateModel> _candidates = [];
  List<StageModel> _stages = [];
  List<PositionModel> _positions = [];
  List<CandidateStageModel> _candidateStages = [];
  
  CandidateModel? _selectedCandidate;
  StageModel? _selectedStage;
  PositionModel? _selectedPosition;
  
  bool _isLoading = false;
  bool _isLoadingCandidates = false;
  bool _isLoadingStages = false;
  bool _isLoadingPositions = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreCandidates = true;
  
  // Filters
  String? _searchQuery;
  String? _statusFilter;
  int? _positionFilter;
  
  // Analytics
  Map<String, dynamic>? _analytics;

  // Getters
  List<CandidateModel> get candidates => _candidates;
  List<StageModel> get stages => _stages;
  List<PositionModel> get positions => _positions;
  List<CandidateStageModel> get candidateStages => _candidateStages;
  
  CandidateModel? get selectedCandidate => _selectedCandidate;
  StageModel? get selectedStage => _selectedStage;
  PositionModel? get selectedPosition => _selectedPosition;
  
  bool get isLoading => _isLoading;
  bool get isLoadingCandidates => _isLoadingCandidates;
  bool get isLoadingStages => _isLoadingStages;
  bool get isLoadingPositions => _isLoadingPositions;
  String? get error => _error;
  
  int get currentPage => _currentPage;
  bool get hasMoreCandidates => _hasMoreCandidates;
  
  String? get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  int? get positionFilter => _positionFilter;
  
  Map<String, dynamic>? get analytics => _analytics;

  // Initialize service with token
  void initializeService(String token) {
    _selectionService = SelectionService(token: token);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set filters
  void setSearchQuery(String? query) {
    _searchQuery = query;
    _currentPage = 1;
    _hasMoreCandidates = true;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    _currentPage = 1;
    _hasMoreCandidates = true;
    notifyListeners();
  }

  void setPositionFilter(int? positionId) {
    _positionFilter = positionId;
    _currentPage = 1;
    _hasMoreCandidates = true;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _statusFilter = null;
    _positionFilter = null;
    _currentPage = 1;
    _hasMoreCandidates = true;
    notifyListeners();
  }

  // Candidates operations
  Future<void> loadCandidates({bool refresh = false}) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _hasMoreCandidates = true;
      _candidates.clear();
    }

    if (!_hasMoreCandidates && !refresh) return;

    _isLoadingCandidates = true;
    _error = null;
    notifyListeners();

    try {
      final newCandidates = await _selectionService!.getCandidates(
        page: _currentPage,
        search: _searchQuery,
        status: _statusFilter,
        positionId: _positionFilter,
      );
      if (newCandidates == []){
        _hasMoreCandidates = false;
        if (refresh) {
          _candidates.clear();
        }
        return;
      }

      if (refresh) {
        _candidates = newCandidates;
      } else {
        _candidates.addAll(newCandidates);
      }

      _hasMoreCandidates = newCandidates.length >= 20; // Assuming page size is 20
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      print('Error loading candidates: $e');
    } finally {
      _isLoadingCandidates = false;
      notifyListeners();
    }
  }

  Future<void> loadCandidateById(int id) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCandidate = await _selectionService!.getCandidateById(id);
    } catch (e) {
      _error = e.toString();
      print('Error loading candidate: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCandidate(Map<String, dynamic> candidateData) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCandidate = await _selectionService!.createCandidate(candidateData);
      _candidates.insert(0, newCandidate);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error creating candidate: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCandidate(int id, Map<String, dynamic> candidateData) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCandidate = await _selectionService!.updateCandidate(id, candidateData);
      final index = _candidates.indexWhere((c) => c.id == id);
      if (index != -1) {
        _candidates[index] = updatedCandidate;
      }
      if (_selectedCandidate?.id == id) {
        _selectedCandidate = updatedCandidate;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating candidate: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCandidate(int id) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _selectionService!.deleteCandidate(id);
      _candidates.removeWhere((c) => c.id == id);
      if (_selectedCandidate?.id == id) {
        _selectedCandidate = null;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting candidate: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadCandidateResume(int candidateId, File resumeFile) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCandidate = await _selectionService!.uploadCandidateResume(candidateId, resumeFile);
      final index = _candidates.indexWhere((c) => c.id == candidateId);
      if (index != -1) {
        _candidates[index] = updatedCandidate;
      }
      if (_selectedCandidate?.id == candidateId) {
        _selectedCandidate = updatedCandidate;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error uploading resume: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stages operations
  Future<void> loadStages() async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return;
    }

    _isLoadingStages = true;
    _error = null;
    notifyListeners();

    try {
      _stages = await _selectionService!.getStages();
      _stages.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      _error = e.toString();
      print('Error loading stages: $e');
    } finally {
      _isLoadingStages = false;
      notifyListeners();
    }
  }

  Future<bool> createStage(Map<String, dynamic> stageData) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newStage = await _selectionService!.createStage(stageData);
      _stages.add(newStage);
      _stages.sort((a, b) => a.order.compareTo(b.order));
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error creating stage: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStage(int id, Map<String, dynamic> stageData) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedStage = await _selectionService!.updateStage(id, stageData);
      final index = _stages.indexWhere((s) => s.id == id);
      if (index != -1) {
        _stages[index] = updatedStage;
        _stages.sort((a, b) => a.order.compareTo(b.order));
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating stage: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStage(int id) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _selectionService!.deleteStage(id);
      _stages.removeWhere((s) => s.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting stage: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Positions operations
  Future<void> loadPositions() async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return;
    }

    _isLoadingPositions = true;
    _error = null;
    notifyListeners();

    try {
      _positions = await _selectionService!.getPositions();
    } catch (e) {
      _error = e.toString();
      print('Error loading positions: $e');
    } finally {
      _isLoadingPositions = false;
      notifyListeners();
    }
  }

  Future<bool> createPosition(Map<String, dynamic> positionData) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPosition = await _selectionService!.createPosition(positionData);
      _positions.insert(0, newPosition);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error creating position: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Candidate stages operations
  Future<void> loadCandidateStages(int candidateId) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _candidateStages = await _selectionService!.getCandidateStages(candidateId);
    } catch (e) {
      _error = e.toString();
      print('Error loading candidate stages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCandidateStage(int id, Map<String, dynamic> stageData) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedStage = await _selectionService!.updateCandidateStage(id, stageData);
      final index = _candidateStages.indexWhere((s) => s.id == id);
      if (index != -1) {
        _candidateStages[index] = updatedStage;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating candidate stage: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Analytics
  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    if (_selectionService == null) {
      _error = 'Servicio no inicializado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analytics = await _selectionService!.getSelectionAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      print('Error loading analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Selection helpers
  void selectCandidate(CandidateModel? candidate) {
    _selectedCandidate = candidate;
    notifyListeners();
  }

  void selectStage(StageModel? stage) {
    _selectedStage = stage;
    notifyListeners();
  }

  void selectPosition(PositionModel? position) {
    _selectedPosition = position;
    notifyListeners();
  }

  // Load all initial data
  Future<void> loadInitialData() async {
    await Future.wait([
      loadCandidates(refresh: true),
      loadStages(),
      loadPositions(),
    ]);
  }

  // Reset provider state
  void reset() {
    _candidates.clear();
    _stages.clear();
    _positions.clear();
    _candidateStages.clear();
    _selectedCandidate = null;
    _selectedStage = null;
    _selectedPosition = null;
    _analytics = null;
    _currentPage = 1;
    _hasMoreCandidates = true;
    _searchQuery = null;
    _statusFilter = null;
    _positionFilter = null;
    _error = null;
    _isLoading = false;
    _isLoadingCandidates = false;
    _isLoadingStages = false;
    _isLoadingPositions = false;
    notifyListeners();
  }
}