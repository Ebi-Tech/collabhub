import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String bio;
  final List<String> skills;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = '',
    this.bio = '',
    this.skills = const [],
    this.avatarUrl,
  });

  /// Two-letter initials for the avatar fallback.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Deserialise from a Firestore document map.
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      skills: List<String>.from(data['skills'] as List? ?? []),
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  /// Serialise to a map for Firestore (does not include [id]).
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'bio': bio,
        'skills': skills,
        'avatarUrl': avatarUrl,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? bio,
    List<String>? skills,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, bio, skills, avatarUrl];
}