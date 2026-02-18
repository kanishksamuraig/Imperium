enum Severity {
  normal,
  warning,
  critical,
}

class SymptomLog {
  final String id;
  final String patientId;
  final String? patientName;
  final String? patientPhone;
  final DateTime date;
  final String condition;
  final Map<String, dynamic> symptoms;
  final Severity severity;
  final String? notes;
  final bool flaggedBySystem;
  final bool reviewedByDoctor;
  final String? doctorNotes;

  SymptomLog({
    required this.id,
    required this.patientId,
    this.patientName,
    this.patientPhone,
    required this.date,
    required this.condition,
    required this.symptoms,
    required this.severity,
    this.notes,
    required this.flaggedBySystem,
    required this.reviewedByDoctor,
    this.doctorNotes,
  });

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    // patientId may be a plain string ID or a populated Patient object
    String patientId = '';
    String? patientName;
    String? patientPhone;

    final rawPatient = json['patientId'];
    if (rawPatient is String) {
      patientId = rawPatient;
    } else if (rawPatient is Map<String, dynamic>) {
      patientId = rawPatient['_id']?.toString() ?? '';
      // The Patient object has a nested userId (User object)
      final rawUser = rawPatient['userId'];
      if (rawUser is Map<String, dynamic>) {
        patientName = rawUser['name']?.toString();
        patientPhone = rawUser['phone']?.toString();
      }
    }

    // symptoms field — filter to only displayable scalar values
    // (MongoDB returns all schema fields including empty arrays like withdrawalSymptoms:[])
    Map<String, dynamic> symptoms = {};
    final rawSymptoms = json['symptoms'];
    if (rawSymptoms is Map) {
      rawSymptoms.forEach((key, value) {
        // Only include non-null, non-empty-list values
        if (value != null) {
          if (value is List) {
            if (value.isNotEmpty) symptoms[key.toString()] = value;
          } else {
            symptoms[key.toString()] = value;
          }
        }
      });
    }

    return SymptomLog(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      date: DateTime.tryParse(json['date']?.toString() ??
              json['createdAt']?.toString() ??
              '') ??
          DateTime.now(),
      condition: json['condition']?.toString() ?? '',
      symptoms: symptoms,
      severity: _parseSeverity(json['severity']?.toString()),
      notes: json['notes']?.toString(),
      flaggedBySystem: json['flaggedBySystem'] == true,
      reviewedByDoctor: json['reviewedByDoctor'] == true,
      doctorNotes: (json['doctorNotes']?.toString().isNotEmpty == true)
          ? json['doctorNotes'].toString()
          : null,
    );
  }

  static Severity _parseSeverity(String? severityString) {
    switch (severityString?.toLowerCase()) {
      case 'warning':
        return Severity.warning;
      case 'critical':
        return Severity.critical;
      default:
        return Severity.normal;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'symptoms': symptoms,
      'severity': severity.toString().split('.').last,
      'notes': notes,
    };
  }
}
