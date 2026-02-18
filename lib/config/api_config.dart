class ApiConfig {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:5000/api';
  
  // For Android emulator, use: http://10.0.2.2:5000/api
  // For iOS simulator, use: http://localhost:5000/api
  // For physical device, use your computer's IP: http://192.168.x.x:5000/api
  
  static const String authEndpoint = '$baseUrl/auth';
  static const String patientsEndpoint = '$baseUrl/patients';
  static const String symptomsEndpoint = '$baseUrl/symptoms';
  static const String alertsEndpoint = '$baseUrl/alerts';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
