class TrainingProgramModel {
  final int id;
  final String name;
  final String description;
  final int trainingTypeId;
  final String trainingTypeName;
  final double durationHours;
  final String? materials;
  final String objectives;
  final bool isActive;

  TrainingProgramModel({
    required this.id,
    required this.name,
    required this.description,
    required this.trainingTypeId,
    required this.trainingTypeName,
    required this.durationHours,
    this.materials,
    required this.objectives,
    required this.isActive,
  });

  factory TrainingProgramModel.fromJson(Map<String, dynamic> json) {
    return TrainingProgramModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      trainingTypeId: json['training_type'],
      trainingTypeName: json['training_type_name'] ?? '',
      durationHours: json['duration_hours']?.toDouble() ?? 0.0,
      materials: json['materials'],
      objectives: json['objectives'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class TrainingSessionModel {
  final int id;
  final int programId;
  final String programName;
  final String sessionDate;
  final String startTime;
  final String endTime;
  final String location;
  final int instructorId;
  final String instructorName;
  final int maxParticipants;
  final String status;
  final String? notes;

  TrainingSessionModel({
    required this.id,
    required this.programId,
    required this.programName,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.instructorId,
    required this.instructorName,
    required this.maxParticipants,
    required this.status,
    this.notes,
  });

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) {
    return TrainingSessionModel(
      id: json['id'],
      programId: json['program'],
      programName: json['program_name'] ?? '',
      sessionDate: json['session_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'],
      instructorId: json['instructor'],
      instructorName: json['instructor_name'] ?? '',
      maxParticipants: json['max_participants'],
      status: json['status'],
      notes: json['notes'],
    );
  }
}

class TrainingAttendanceModel {
  final int id;
  final int sessionId;
  final String sessionDate;
  final String programName;
  final int employeeId;
  final String employeeName;
  final String status;
  final double? evaluationScore;
  final String? comments;

  TrainingAttendanceModel({
    required this.id,
    required this.sessionId,
    required this.sessionDate,
    required this.programName,
    required this.employeeId,
    required this.employeeName,
    required this.status,
    this.evaluationScore,
    this.comments,
  });

  factory TrainingAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TrainingAttendanceModel(
      id: json['id'],
      sessionId: json['session'],
      sessionDate: json['session_date'] ?? '',
      programName: json['program_name'] ?? '',
      employeeId: json['employee'],
      employeeName: json['employee_name'] ?? '',
      status: json['status'],
      evaluationScore: json['evaluation_score']?.toDouble(),
      comments: json['comments'],
    );
  }
}
