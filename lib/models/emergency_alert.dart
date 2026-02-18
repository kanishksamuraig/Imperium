enum AlertStatus {
  active,
  acknowledged,
  resolved,
  cancelled,
}

enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

class EmergencyAlert {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final Map<String, dynamic>? location;
  final AlertStatus status;
  final String? responderId;
  final DateTime? responseTime;
  final DateTime? resolutionTime;
  final String? notes;
  final AlertPriority priority;

  // Populated fields
  final String? patientName;
  final String? patientPhone;
  final String? responderName;

  EmergencyAlert({
    required this.id,
    required this.patientId,
    required this.timestamp,
    this.location,
    required this.status,
    this.responderId,
    this.responseTime,
    this.resolutionTime,
    this.notes,
    required this.priority,
    this.patientName,
    this.patientPhone,
    this.responderName,
  });

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    // patientId may be a plain string or a populated Patient object
    String patientId = '';
    String? patientName;
    String? patientPhone;

    final rawPatient = json['patientId'];
    if (rawPatient is String) {
      patientId = rawPatient;
    } else if (rawPatient is Map<String, dynamic>) {
      patientId = rawPatient['_id']?.toString() ?? '';
      // Patient has a nested userId (User object)
      final rawUser = rawPatient['userId'];
      if (rawUser is Map<String, dynamic>) {
        patientName = rawUser['name']?.toString();
        patientPhone = rawUser['phone']?.toString();
      }
    }

    // responderId may be a plain string or a populated User object
    String? responderId;
    String? responderName;
    final rawResponder = json['responderId'];
    if (rawResponder is String) {
      responderId = rawResponder;
    } else if (rawResponder is Map<String, dynamic>) {
      responderId = rawResponder['_id']?.toString();
      responderName = rawResponder['name']?.toString();
    }

    // location may be a Map or null
    Map<String, dynamic>? location;
    final rawLocation = json['location'];
    if (rawLocation is Map) {
      location = Map<String, dynamic>.from(rawLocation);
      if (location.isEmpty) location = null;
    }

    return EmergencyAlert(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      patientId: patientId,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ??
              json['createdAt']?.toString() ??
              '') ??
          DateTime.now(),
      location: location,
      status: _parseStatus(json['status']?.toString()),
      responderId: responderId,
      responseTime: json['responseTime'] != null
          ? DateTime.tryParse(json['responseTime'].toString())
          : null,
      resolutionTime: json['resolutionTime'] != null
          ? DateTime.tryParse(json['resolutionTime'].toString())
          : null,
      notes: json['notes']?.toString(),
      priority: _parsePriority(json['priority']?.toString()),
      patientName: patientName,
      patientPhone: patientPhone,
      responderName: responderName,
    );
  }

  static AlertStatus _parseStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'acknowledged':
        return AlertStatus.acknowledged;
      case 'resolved':
        return AlertStatus.resolved;
      case 'cancelled':
        return AlertStatus.cancelled;
      default:
        return AlertStatus.active;
    }
  }

  static AlertPriority _parsePriority(String? priorityString) {
    switch (priorityString?.toLowerCase()) {
      case 'low':
        return AlertPriority.low;
      case 'medium':
        return AlertPriority.medium;
      case 'critical':
        return AlertPriority.critical;
      default:
        return AlertPriority.high;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'location': location,
      'notes': notes,
      'priority': priority.toString().split('.').last,
    };
  }
}
