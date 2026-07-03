// nmimes/lib/models/student.dart
class Student {
  final String id;
  final String parentId;
  final String name;
  final String? username;
  final String? grade;
  final String? interest;
  final int pointsBalance;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Student({
    required this.id,
    required this.parentId,
    required this.name,
    this.username,
    this.grade,
    this.interest,
    required this.pointsBalance,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      grade: json['grade'] as String?,
      interest: json['interest'] as String?,
      pointsBalance: json['points_balance'] as int,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'username': username,
      'grade': grade,
      'interest': interest,
      'points_balance': pointsBalance,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
