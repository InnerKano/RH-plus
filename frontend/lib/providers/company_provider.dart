import 'package:flutter/foundation.dart';
import 'package:rh_plus/models/company.dart';
import 'package:rh_plus/models/company_user.dart';
import 'package:rh_plus/services/company_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CompanyProvider with ChangeNotifier {
  final CompanyService _companyService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  List<CompanyUser> _userCompanies = [];
  CompanyUser? _activeCompanyUser;
  bool _isLoading = false;
  
  CompanyProvider(this._companyService);
  
  List<CompanyUser> get userCompanies => _userCompanies;
  CompanyUser? get activeCompanyUser => _activeCompanyUser;
  Company? get activeCompany => _activeCompanyUser?.company;
  bool get isLoading => _isLoading;
  
  Future<void> loadUserCompanies() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _userCompanies = await _companyService.getUserCompanies();
      
      // Get active company ID from storage
      final activeCompanyId = await _storage.read(key: 'active_company_id');
      
      if (activeCompanyId != null) {
        // Try to find the company in user's companies
        _activeCompanyUser = _userCompanies.firstWhere(
          (cu) => cu.companyId.toString() == activeCompanyId,
          orElse: () => _userCompanies.firstWhere(
            (cu) => cu.isPrimary,
            orElse: () => _userCompanies.isNotEmpty ? _userCompanies.first : null,
          ),
        );
      } else if (_userCompanies.isNotEmpty) {
        // If no active company is stored, get the primary or first one
        _activeCompanyUser = _userCompanies.firstWhere(
          (cu) => cu.isPrimary,
          orElse: () => _userCompanies.first,
        );
      }
      
      // Save active company ID
      if (_activeCompanyUser != null) {
        await _storage.write(
          key: 'active_company_id', 
          value: _activeCompanyUser!.companyId.toString()
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user companies: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> switchCompany(int companyId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _companyService.switchCompany(companyId);
      
      // Update active company user
      _activeCompanyUser = _userCompanies.firstWhere(
        (cu) => cu.companyId == companyId,
        orElse: () => null,
      );
      
      // Save active company ID
      if (_activeCompanyUser != null) {
        await _storage.write(
          key: 'active_company_id', 
          value: _activeCompanyUser!.companyId.toString()
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error switching company: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Company>> getActiveCompanies() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final companies = await _companyService.getActiveCompanies();
      return companies;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting active companies: $e');
      }
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Company>> getPendingCompanies() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final companies = await _companyService.getPendingCompanies();
      return companies;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending companies: $e');
      }
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Methods for company administration
  Future<void> approveCompany(int companyId) async {
    await _companyService.approveCompany(companyId);
  }
  
  Future<void> rejectCompany(int companyId) async {
    await _companyService.rejectCompany(companyId);
  }
  
  Future<void> approveCompanyUser(int companyUserId) async {
    await _companyService.approveCompanyUser(companyUserId);
  }
  
  Future<void> rejectCompanyUser(int companyUserId) async {
    await _companyService.rejectCompanyUser(companyUserId);
  }
  
  Future<void> updateUserRoles(int companyUserId, List<int> roleIds) async {
    await _companyService.updateUserRoles(companyUserId, roleIds);
  }
  
  // Check if user has a specific role in active company
  bool hasRole(String roleName) {
    if (_activeCompanyUser == null) return false;
    return _activeCompanyUser!.hasRole(roleName);
  }
  
  void clear() {
    _userCompanies = [];
    _activeCompanyUser = null;
    notifyListeners();
  }
}
