import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/patient.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  Patient? _currentPatient;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  Patient? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Initialize app - check for saved user
  Future<void> initialize() async {
    _isLoading = true;
    // Don't call notifyListeners() here — we're inside initState() and the
    // widget tree hasn't finished building yet. Schedule it for after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    _currentUser = await AuthService.getSavedUser();

    // If user is a patient, load patient data
    if (_currentUser != null && _currentUser!.role == UserRole.patient) {
      await loadPatientData();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.login(email: email, password: password);

      if (result['success']) {
        final userData = result['data']['user'];
        userData['token'] = result['data']['token'];
        _currentUser = User.fromJson(userData);
        await AuthService.saveUser(_currentUser!);

        // If patient, load patient data before navigating to dashboard
        if (_currentUser!.role == UserRole.patient) {
          await loadPatientData();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? condition,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        condition: condition,
      );

      if (result['success']) {
        final userData = result['data']['user'];
        userData['token'] = result['data']['token'];
        _currentUser = User.fromJson(userData);
        await AuthService.saveUser(_currentUser!);

        // If patient, load patient data immediately (awaited so dashboard is ready)
        if (_currentUser!.role == UserRole.patient) {
          await loadPatientData();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load patient data
  Future<void> loadPatientData() async {
    if (_currentUser == null) return;

    try {
      final result = await ApiService.getPatientByUserId(_currentUser!.id);
      if (result['success']) {
        _currentPatient = Patient.fromJson(result['data']);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading patient data: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.clearUser();
    _currentUser = null;
    _currentPatient = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
