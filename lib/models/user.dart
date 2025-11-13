class AppUser {
  final int? id; // nullable (auto increment)
  final String email;
  final String passwordHash; // hash hasil enkripsi
  final String salt;         // untuk hashing
  final String role;

  String? password; // ✅ ubah ke nullable

  AppUser({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.role,
    this.password, // ✅ opsional
  });

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as int?,
        email: map['email'] as String,
        passwordHash: map['password_hash'] as String,
        salt: map['salt'] as String,
        role: map['role'] as String,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'email': email,
        'password_hash': passwordHash,
        'salt': salt,
        'role': role,
      };
}
