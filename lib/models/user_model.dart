/// User data model for SecureVault application
class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final bool biometricEnabled;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    this.biometricEnabled = false,
  });

  /// Get full name from first and last names
  String get fullName => '$firstName $lastName';

  /// Create a copy of UserModel with optional parameter updates
  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? profileImageUrl,
    String? bio,
    DateTime? createdAt,
    bool? biometricEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  /// Convert UserModel to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'biometricEnabled': biometricEnabled,
    };
  }

  /// Create UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
    );
  }
}
