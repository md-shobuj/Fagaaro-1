import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? dateOfBirth;
  final int? age;
  final String? avatarPath;
  final bool isEmailVerified;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'field_user',
    this.phoneNumber,
    this.dateOfBirth,
    this.age,
    this.avatarPath,
    this.isEmailVerified = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phoneNumber,
    String? dateOfBirth,
    int? age,
    String? avatarPath,
    bool? isEmailVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      avatarPath: avatarPath ?? this.avatarPath,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        phoneNumber,
        dateOfBirth,
        age,
        avatarPath,
        isEmailVerified,
      ];
}

