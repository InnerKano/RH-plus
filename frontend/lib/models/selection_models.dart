// Helper function to safely convert dynamic values to double
double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

class StageModel {
  final int id;
  final String name;
  final String? description;
  final int order;

  StageModel({
    required this.id,
    required this.name,
    this.description,
    required this.order,
  });

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'order': order,
    };
  }

  StageModel copyWith({
    int? id,
    String? name,
    String? description,
    int? order,
  }) {
    return StageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }
}

class CandidateStageModel {
  final int id;
  final int candidateId;
  final int stageId;
  final String stageName;
  final String status;
  final String? notes;
  final double? score;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? evaluatedBy;

  CandidateStageModel({
    required this.id,
    required this.candidateId,
    required this.stageId,
    required this.stageName,
    required this.status,
    this.notes,
    this.score,
    this.scheduledDate,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
    this.evaluatedBy,
  });

  factory CandidateStageModel.fromJson(Map<String, dynamic> json) {
    return CandidateStageModel(
      id: json['id'],
      candidateId: json['candidate_id'] ?? json['candidate'],
      stageId: json['stage_id'] ?? json['stage']?['id'] ?? 0,
      stageName: json['stage_name'] ?? json['stage']?['name'] ?? 'Sin etapa',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      score: _toDoubleNullable(json['score']),
      scheduledDate: json['scheduled_date'] != null 
          ? DateTime.parse(json['scheduled_date']) 
          : null,
      completedDate: json['completed_date'] != null 
          ? DateTime.parse(json['completed_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      evaluatedBy: json['evaluated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidate_id': candidateId,
      'stage_id': stageId,
      'status': status,
      'notes': notes,
      'score': score,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'evaluated_by': evaluatedBy,
    };
  }

  CandidateStageModel copyWith({
    int? id,
    int? candidateId,
    int? stageId,
    String? stageName,
    String? status,
    String? notes,
    double? score,
    DateTime? scheduledDate,
    DateTime? completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? evaluatedBy,
  }) {
    return CandidateStageModel(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      score: score ?? this.score,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      evaluatedBy: evaluatedBy ?? this.evaluatedBy,
    );
  }
}

class PositionModel {
  final int id;
  final String title;
  final String? description;
  final String department;
  final String? requirements;
  final String status;
  final DateTime? closingDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int candidatesCount;

  PositionModel({
    required this.id,
    required this.title,
    this.description,
    required this.department,
    this.requirements,
    required this.status,
    this.closingDate,
    required this.createdAt,
    required this.updatedAt,
    this.candidatesCount = 0,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      department: json['department'] ?? '',
      requirements: json['requirements'],
      status: json['status'] ?? 'open',
      closingDate: json['closing_date'] != null 
          ? DateTime.parse(json['closing_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      candidatesCount: json['candidates_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'department': department,
      'requirements': requirements,
      'status': status,
      'closing_date': closingDate?.toIso8601String(),
    };
  }

  PositionModel copyWith({
    int? id,
    String? title,
    String? description,
    String? department,
    String? requirements,
    String? status,
    DateTime? closingDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? candidatesCount,
  }) {
    return PositionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      department: department ?? this.department,
      requirements: requirements ?? this.requirements,
      status: status ?? this.status,
      closingDate: closingDate ?? this.closingDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      candidatesCount: candidatesCount ?? this.candidatesCount,
    );
  }
}

// Enums and Constants for Selection Module
class SelectionStatus {
  static const String applied = 'applied';
  static const String inProgress = 'in_progress';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String hired = 'hired';
  static const String withdrawn = 'withdrawn';

  static const Map<String, String> displayNames = {
    applied: 'Aplicado',
    inProgress: 'En Proceso',
    approved: 'Aprobado',
    rejected: 'Rechazado',
    hired: 'Contratado',
    withdrawn: 'Retirado',
  };

  static const Map<String, String> colors = {
    applied: '#2196F3',      // Blue
    inProgress: '#FF9800',   // Orange
    approved: '#4CAF50',     // Green
    rejected: '#F44336',     // Red
    hired: '#9C27B0',        // Purple
    withdrawn: '#757575',    // Grey
  };
}

class StageStatus {
  static const String pending = 'pending';
  static const String scheduled = 'scheduled';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String passed = 'passed';
  static const String failed = 'failed';
  static const String noShow = 'no_show';

  static const Map<String, String> displayNames = {
    pending: 'Pendiente',
    scheduled: 'Programado',
    inProgress: 'En Proceso',
    completed: 'Completado',
    passed: 'Aprobado',
    failed: 'Reprobado',
    noShow: 'No se presentó',
  };
}

class PositionStatus {
  static const String open = 'open';
  static const String closed = 'closed';
  static const String onHold = 'on_hold';
  static const String filled = 'filled';

  static const Map<String, String> displayNames = {
    open: 'Abierta',
    closed: 'Cerrada',
    onHold: 'En Pausa',
    filled: 'Cubierta',
  };
}