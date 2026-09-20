import 'package:hive_ce/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 0)
class UserProfileModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? role;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'field_user',
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // If wrapped under a 'user' key or directly in the map
    final userMap = json['user'] != null ? json['user'] as Map<String, dynamic> : json;
    return UserProfileModel(
      id: (userMap['id'] ?? '') as String,
      name: (userMap['name'] ?? userMap['full_name'] ?? '') as String,
      email: (userMap['email'] ?? '') as String,
      role: userMap['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      role: role ?? 'field_user',
    );
  }
}
