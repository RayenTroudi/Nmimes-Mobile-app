// nmimes/lib/models/parent.dart
class Parent {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String subscriptionStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Parent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.subscriptionStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      subscriptionStatus: json['subscription_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'subscription_status': subscriptionStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
