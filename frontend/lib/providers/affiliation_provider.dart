import 'package:flutter/foundation.dart';
import 'package:rh_plus/models/affiliation_models.dart';
import 'package:rh_plus/models/user_model.dart';
import 'package:rh_plus/services/affiliation_service.dart';
import 'package:rh_plus/services/user_service.dart';

class AffiliationProvider with ChangeNotifier {
  final AffiliationService _affiliationService;
  final UserService _userService;
  
  List<AffiliationType> _affiliationTypes = [];
  List<InsuranceProvider> _providers = [];
  List<Affiliation> _affiliations = [];
  List<User> _employeeUsers = [];
  
  AffiliationType? _selectedType;
  InsuranceProvider? _selectedProvider;
  Affiliation? _selectedAffiliation;
  User? _selectedUser;
  
  bool _isLoading = false;
  String? _error;

  AffiliationProvider({required String token})
      : _affiliationService = AffiliationService(token: token),
        _userService = UserService(token: token);

  // Getters
  List<AffiliationType> get affiliationTypes => _affiliationTypes;
  List<InsuranceProvider> get providers => _providers;
  List<Affiliation> get affiliations => _affiliations;
  List<User> get employeeUsers => _employeeUsers;
  
  AffiliationType? get selectedType => _selectedType;
  InsuranceProvider? get selectedProvider => _selectedProvider;
  Affiliation? get selectedAffiliation => _selectedAffiliation;
  User? get selectedUser => _selectedUser;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Data fetching methods
  Future<void> fetchAffiliationTypes() async {
    _setLoading(true);
    _setError(null);

    try {
      _affiliationTypes = await _affiliationService.getAffiliationTypes();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchProviders({int? typeId}) async {
    _setLoading(true);
    _setError(null);

    try {
      if (typeId != null) {
        _providers = await _affiliationService.getProvidersByType(typeId);
      } else {
        _providers = await _affiliationService.getProviders();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchAffiliations({int? employeeId}) async {
    _setLoading(true);
    _setError(null);

    try {
      if (employeeId != null) {
        _affiliations = await _affiliationService.getAffiliationsByEmployee(employeeId);
      } else {
        _affiliations = await _affiliationService.getAffiliations();
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchEmployeeUsers() async {
    _setLoading(true);
    _setError(null);

    try {
      _employeeUsers = await _userService.getEmployeeUsers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Selection methods
  void setSelectedType(AffiliationType? type) {
    _selectedType = type;
    if (type != null) {
      fetchProviders(typeId: type.id);
    }
    notifyListeners();
  }

  void setSelectedProvider(InsuranceProvider? provider) {
    _selectedProvider = provider;
    notifyListeners();
  }

  void setSelectedAffiliation(Affiliation? affiliation) {
    _selectedAffiliation = affiliation;
    notifyListeners();
  }

  void setSelectedUser(User? user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearUserSelection() {
    _selectedUser = null;
    notifyListeners();
  }

  // Override clearSelections to include user
  void clearSelections() {
    _selectedType = null;
    _selectedProvider = null;
    _selectedAffiliation = null;
    _selectedUser = null;
    notifyListeners();
  }

  // Filtering methods
  List<InsuranceProvider> getProvidersByType(int typeId) {
    return _providers.where((p) => p.affiliationType == typeId).toList();
  }

  List<Affiliation> getActiveAffiliations() {
    return _affiliations.where((a) => a.isActive).toList();
  }

  // Create and update methods
  Future<void> createAffiliation(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);

    try {
      await _affiliationService.createAffiliation(data);
      await fetchAffiliations(); // Refresh the list after creating
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateAffiliation(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);

    try {
      await _affiliationService.updateAffiliation(id, data);
      await fetchAffiliations(); // Refresh the list after updating
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }
}
