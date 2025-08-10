class UserDto {
  final String id;
  final String name;
  final String email;
  final String role;

  UserDto({required this.id, required this.name, required this.email, required this.role});

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
    );
  }
}

class AuthResult {
  final String token;
  final UserDto user;

  AuthResult({required this.token, required this.user});
}