// nmimes/lib/models/student_profile.dart
/// Lean read-model for the profile screen, matching the `profile` object
/// returned by the FastAPI `GET /students/{id}/profile` endpoint.
class StudentProfile {
  final String id;
  final String name;
  final int pointsBalance;
  final String? avatarUrl;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.pointsBalance,
    this.avatarUrl,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      pointsBalance: json['points_balance'] as int,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
