import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// 🔑 Generate salt random (default panjang 16 byte, hasil base64)
String generateSalt([int length = 16]) {
  final rand = Random.secure();
  final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
  return base64Url.encode(bytes);
}

/// 🔑 Hash password dengan SHA-256 (kombinasi salt + password)
String hashPassword(String password, String salt) {
  final bytes = utf8.encode('$salt$password'); // salt dulu baru password
  return sha256.convert(bytes).toString();
}
