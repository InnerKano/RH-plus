import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/selection_models.dart';
import '../utils/constants.dart';

class SelectionService {
  final String _token;
  final String _baseUrl = ApiConstants.baseUrl;

  SelectionService({required String token}) : _token = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Map<String, String> get _multipartHeaders => {
    'Authorization': 'Bearer $_token',
  };

  // Candidates CRUD Operations
  Future<List<CandidateModel>> getCandidates({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    int? positionId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (positionId != null) 'position_id': positionId.toString(),
      };

      final uri = Uri.parse('$_baseUrl/api/selection/candidates/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);
      print('response: ${response.body}');
      print('response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (response.body == '[]' || response.body.isEmpty) {
          return [];
        }
        else{
          final data = json.decode(response.body);
          final results = data['results'] as List<dynamic>? ?? data as List<dynamic>;
          return results.map((json) => CandidateModel.fromJson(json)).toList();
        }
      } else {
        throw Exception('Error al cargar candidatos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CandidateModel> getCandidateById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/selection/candidates/$id/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return CandidateModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar candidato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CandidateModel> createCandidate(Map<String, dynamic> candidateData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/selection/candidates/'),
        headers: _headers,
        body: json.encode(candidateData),
      );

      if (response.statusCode == 201) {
        return CandidateModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al crear candidato: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CandidateModel> updateCandidate(int id, Map<String, dynamic> candidateData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/selection/candidates/$id/'),
        headers: _headers,
        body: json.encode(candidateData),
      );

      if (response.statusCode == 200) {
        return CandidateModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al actualizar candidato: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteCandidate(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/selection/candidates/$id/'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar candidato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Resume upload
  Future<CandidateModel> uploadCandidateResume(int candidateId, File resumeFile) async {
    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl/api/selection/candidates/$candidateId/'),
      );

      request.headers.addAll(_multipartHeaders);
      request.files.add(await http.MultipartFile.fromPath('resume', resumeFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return CandidateModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al subir curriculum: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Stages CRUD Operations
  Future<List<StageModel>> getStages() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/selection/stages/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? data as List<dynamic>;
        return results.map((json) => StageModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar etapas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<StageModel> createStage(Map<String, dynamic> stageData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/selection/stages/'),
        headers: _headers,
        body: json.encode(stageData),
      );

      if (response.statusCode == 201) {
        return StageModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al crear etapa: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<StageModel> updateStage(int id, Map<String, dynamic> stageData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/selection/stages/$id/'),
        headers: _headers,
        body: json.encode(stageData),
      );

      if (response.statusCode == 200) {
        return StageModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al actualizar etapa: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteStage(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/selection/stages/$id/'),
        headers: _headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar etapa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Candidate Stages Operations
  Future<List<CandidateStageModel>> getCandidateStages(int candidateId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/selection/candidate-stages/?candidate_id=$candidateId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? data as List<dynamic>;
        return results.map((json) => CandidateStageModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar etapas del candidato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CandidateStageModel> updateCandidateStage(int id, Map<String, dynamic> stageData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/selection/candidate-stages/$id/'),
        headers: _headers,
        body: json.encode(stageData),
      );

      if (response.statusCode == 200) {
        return CandidateStageModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al actualizar etapa: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<CandidateStageModel> createCandidateStage(Map<String, dynamic> stageData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/selection/candidate-stages/'),
        headers: _headers,
        body: json.encode(stageData),
      );

      if (response.statusCode == 201) {
        return CandidateStageModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al crear etapa del candidato: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Positions Operations
  Future<List<PositionModel>> getPositions({
    String? status,
    String? department,
  }) async {
    try {
      final queryParams = <String, String>{
        if (status != null && status.isNotEmpty) 'status': status,
        if (department != null && department.isNotEmpty) 'department': department,
      };

      final uri = Uri.parse('$_baseUrl/selection/positions/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? data as List<dynamic>;
        return results.map((json) => PositionModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar posiciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PositionModel> createPosition(Map<String, dynamic> positionData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/selection/positions/'),
        headers: _headers,
        body: json.encode(positionData),
      );

      if (response.statusCode == 201) {
        return PositionModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al crear posición: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PositionModel> updatePosition(int id, Map<String, dynamic> positionData) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/selection/positions/$id/'),
        headers: _headers,
        body: json.encode(positionData),
      );

      if (response.statusCode == 200) {
        return PositionModel.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al actualizar posición: ${errorData['detail'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Analytics and Reports
  Future<Map<String, dynamic>> getSelectionAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
      };

      final uri = Uri.parse('$_baseUrl/api/selection/analytics/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar analíticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}