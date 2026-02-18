import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/patient.dart';
import '../models/symptom_log.dart';
import '../models/emergency_alert.dart';

class ApiService {
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ============ AUTH ENDPOINTS ============

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? condition,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.authEndpoint}/register'),
            headers: _getHeaders(includeAuth: false),
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
              'phone': phone,
              if (condition != null) 'condition': condition,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.authEndpoint}/login'),
            headers: _getHeaders(includeAuth: false),
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final token = data['data']['token'];
        setAuthToken(token);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============ PATIENT ENDPOINTS ============

  static Future<Map<String, dynamic>> getPatientByUserId(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.patientsEndpoint}/user/$userId'),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get patient'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAllPatients() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.patientsEndpoint),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get patients'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> reviewSymptom({
    required String symptomId,
    required String doctorNotes,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.symptomsEndpoint}/$symptomId/review'),
            headers: _getHeaders(),
            body: jsonEncode({'doctorNotes': doctorNotes}),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save doctor notes'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============ SYMPTOM ENDPOINTS ============

  static Future<Map<String, dynamic>> logSymptoms({
    required String patientId,
    required Map<String, dynamic> symptoms,
    String? severity,
    String? notes,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.symptomsEndpoint}/log'),
            headers: _getHeaders(),
            body: jsonEncode({
              'patientId': patientId,
              'symptoms': symptoms,
              'severity': severity,
              'notes': notes,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to log symptoms'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSymptomHistory(String patientId,
      {int limit = 30}) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConfig.symptomsEndpoint}/patient/$patientId?limit=$limit'),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get symptom history'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFlaggedSymptoms() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.symptomsEndpoint}/flagged'),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.connectionTimeout);

      debugPrint('getFlaggedSymptoms status: ${response.statusCode}');
      debugPrint(
          'getFlaggedSymptoms body: ${response.body.substring(0, response.body.length.clamp(0, 300))}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final list = data['data'] as List;
        debugPrint('getFlaggedSymptoms count: ${list.length}');
        return {'success': true, 'data': list};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get flagged symptoms'
        };
      }
    } catch (e) {
      debugPrint('getFlaggedSymptoms error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============ EMERGENCY ALERT ENDPOINTS ============

  static Future<Map<String, dynamic>> triggerEmergencyAlert({
    required String patientId,
    Map<String, dynamic>? location,
    String? notes,
    String? priority,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.alertsEndpoint}/emergency'),
            headers: _getHeaders(),
            body: jsonEncode({
              'patientId': patientId,
              'location': location,
              'notes': notes,
              'priority': priority ?? 'high',
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send alert'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getActiveAlerts() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.alertsEndpoint}/active'),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get alerts'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> acknowledgeAlert(String alertId) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.alertsEndpoint}/$alertId/acknowledge'),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to acknowledge alert'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resolveAlert(String alertId,
      {String? notes}) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.alertsEndpoint}/$alertId/resolve'),
            headers: _getHeaders(),
            body: jsonEncode({'notes': notes}),
          )
          .timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resolve alert'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
