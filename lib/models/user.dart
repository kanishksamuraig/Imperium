enum UserRole {
  patient,
  nurse,
  doctor,
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      phone: json['phone'],
      token: json['token'] ?? '',
    );
  }

  static UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'patient':
        return UserRole.patient;
      case 'nurse':
        return UserRole.nurse;
      case 'doctor':
        return UserRole.doctor;
      default:
        return UserRole.patient;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phone': phone,
      'token': token,
    };
  }
}
