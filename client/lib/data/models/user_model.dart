class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String level;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.level,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      level: json['level'] ?? 'beginner',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'level': level,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get levelDisplay {
    switch (level) {
      case 'beginner':
        return 'Beginner (A1-A2)';
      case 'intermediate':
        return 'Intermediate (B1-B2)';
      case 'advanced':
        return 'Advanced (C1-C2)';
      default:
        return level;
    }
  }

  String get roleDisplay {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'student':
        return 'Học viên';
      default:
        return role;
    }
  }
}
