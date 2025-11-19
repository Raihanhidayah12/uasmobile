import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/hashing.dart'; // gunakan hash SALT+PASSWORD, generateSalt yang benar
import '../data/local/dao/user_dao.dart';

class AuthProvider extends ChangeNotifier {
  final _dao = UserDao();
  final _storage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _current;
  AppUser? get current => _current;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  AuthProvider() {
    _restoreSession();
  }

  /// Restore session dari storage
  Future<void> _restoreSession() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final u = await _dao.findByEmail(user.email!.trim());
        _current = u;
        if (u != null) {
          await _storage.write(key: 'uid', value: u.id!.toString());
        }
      } else {
        final idStr = await _storage.read(key: 'uid');
        if (idStr != null) {
          final u = await _dao.findById(int.parse(idStr));
          _current = u;
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Register user baru dengan hash password (salt+password) dan salt
  Future<bool> register(String email, String password, {String role = "siswa_pending"}) async {
    _error = null;
    try {
      final existing = await _dao.findByEmail(email.trim());
      if (existing != null) {
        _error = 'Email sudah terdaftar';
        notifyListeners();
        return false;
      }
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      final salt = generateSalt();
      final hash = hashPassword(password, salt); // GABUNGAN SALT+PASSWORD
      final id = await _dao.insert(
        AppUser(
          email: email.trim(),
          passwordHash: hash,
          salt: salt,
          role: role,
          password: '',
        ),
      );
      final user = await _dao.findById(id);
      _current = user;
      await _storage.write(key: 'uid', value: user!.id.toString());
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal register: $e';
      notifyListeners();
      return false;
    }
  }

  /// Login user menggunakan hash password (salt+password, salt dari DB)
  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      var user = await _dao.findByEmail(email.trim());
      if (user == null) {
        final salt = generateSalt();
        final hash = hashPassword(password, salt);
        final id = await _dao.insert(
          AppUser(
            email: email.trim(),
            passwordHash: hash,
            salt: salt,
            role: 'siswa',
            password: '',
          ),
        );
        user = await _dao.findById(id);
      }
      if (user == null) {
        _error = 'Gagal login: data lokal tidak ditemukan';
        notifyListeners();
        return false;
      }
      if (user.role == "siswa_pending") {
        _error = "Akun Anda menunggu verifikasi admin";
        notifyListeners();
        return false;
      }
      _current = user;
      if (user.id != null) {
        await _storage.write(key: 'uid', value: user.id!.toString());
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal login: $e';
      notifyListeners();
      return false;
    }
  }

  /// Logout dan hapus session
  Future<void> logout() async {
    _current = null;
    await _storage.delete(key: 'uid');
    await _auth.signOut();
    notifyListeners();
  }
}
