enum Condition {
  diabetes,
  renalFailure,
  tb,
  thyroid,
  substanceAbuse,
}

class Patient {
  final String id;
  final String userId;
  final Condition condition;
  final DateTime registrationDate;
  final String assignedDoctorId;
  final String? assignedNurseId;
  final Map<String, dynamic> baseline;
  final Map<String, dynamic> medicalHistory;
  
  // Populated fields
  final String? patientName;
  final String? patientEmail;
  final String? patientPhone;
  final String? doctorName;
  final String? nurseName;

  Patient({
    required this.id,
    required this.userId,
    required this.condition,
    required this.registrationDate,
    required this.assignedDoctorId,
    this.assignedNurseId,
    required this.baseline,
    required this.medicalHistory,
    this.patientName,
    this.patientEmail,
    this.patientPhone,
    this.doctorName,
    this.nurseName,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is String ? json['userId'] : json['userId']?['_id'] ?? '',
      condition: _parseCondition(json['condition']),
      registrationDate: DateTime.parse(json['registrationDate'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      assignedDoctorId: json['assignedDoctor'] is String ? json['assignedDoctor'] : json['assignedDoctor']?['_id'] ?? '',
      assignedNurseId: json['assignedNurse'] is String ? json['assignedNurse'] : json['assignedNurse']?['_id'],
      baseline: json['baseline'] ?? {},
      medicalHistory: json['medicalHistory'] ?? {},
      patientName: json['userId'] is Map ? json['userId']['name'] : null,
      patientEmail: json['userId'] is Map ? json['userId']['email'] : null,
      patientPhone: json['userId'] is Map ? json['userId']['phone'] : null,
      doctorName: json['assignedDoctor'] is Map ? json['assignedDoctor']['name'] : null,
      nurseName: json['assignedNurse'] is Map ? json['assignedNurse']['name'] : null,
    );
  }

  static Condition _parseCondition(String? conditionString) {
    switch (conditionString?.toLowerCase()) {
      case 'diabetes':
        return Condition.diabetes;
      case 'renal_failure':
        return Condition.renalFailure;
      case 'tb':
        return Condition.tb;
      case 'thyroid':
        return Condition.thyroid;
      case 'substance_abuse':
        return Condition.substanceAbuse;
      default:
        return Condition.diabetes;
    }
  }

  String get conditionString => condition.toString().split('.').last;
  
  String get conditionDisplayName {
    switch (condition) {
      case Condition.diabetes:
        return 'Diabetes';
      case Condition.renalFailure:
        return 'Renal Failure';
      case Condition.tb:
        return 'Tuberculosis';
      case Condition.thyroid:
        return 'Thyroid';
      case Condition.substanceAbuse:
        return 'Substance Abuse Rehabilitation';
    }
  }
}
