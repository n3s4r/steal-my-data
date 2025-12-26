import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class UserEntity extends Equatable {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.createdAt,
    this.lastSignInAt,
  });

  @override
  List<Object?> get props => [id, email, createdAt, lastSignInAt];
}

