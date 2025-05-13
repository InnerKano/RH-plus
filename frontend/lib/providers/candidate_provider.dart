import 'package:flutter/foundation.dart';
import 'package:rh_plus/models/candidate_model.dart';
import 'package:rh_plus/services/candidate_service.dart';

class CandidateProvider with ChangeNotifier {
  final CandidateService _candidateService;
  List<CandidateModel> _candidates = [];
  CandidateModel? _selectedCandidate;
  bool _isLoading = false;
  String? _error;

  CandidateProvider({required String token})
      : _candidateService = CandidateService(token: token);

  List<CandidateModel> get candidates => _candidates;
  CandidateModel? get selectedCandidate => _selectedCandidate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCandidates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _candidates = await _candidateService.getCandidates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCandidateById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCandidate = await _candidateService.getCandidateById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createCandidate(Map<String, dynamic> candidateData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCandidate = await _candidateService.createCandidate(candidateData);
      _candidates.add(newCandidate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCandidate(int id, Map<String, dynamic> candidateData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCandidate = await _candidateService.updateCandidate(id, candidateData);
      
      // Update in the list
      final index = _candidates.indexWhere((c) => c.id == id);
      if (index >= 0) {
        _candidates[index] = updatedCandidate;
      }
      
      // Update selected candidate if it's the same
      if (_selectedCandidate?.id == id) {
        _selectedCandidate = updatedCandidate;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void setSelectedCandidate(CandidateModel candidate) {
    _selectedCandidate = candidate;
    notifyListeners();
  }

  void clearSelectedCandidate() {
    _selectedCandidate = null;
    notifyListeners();
  }
}
