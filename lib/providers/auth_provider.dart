import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/hashing.dart'; // generateSalt & hashPassword
import '../data/local/dao/user_dao.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final _dao = UserDao();
  final _storage = const FlutterSecureStorage();

  AppUser? _current;
  AppUser? get current => _current;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  AuthProvider() {
    _restoreSession();
  }

  /// ✅ Restore session dari secure storage
  Future<void> _restoreSession() async {
    try {
      final idStr = await _storage.read(key: 'uid');
      if (idStr != null) {
        final u = await _dao.findById(int.parse(idStr));
        _current = u;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

 /// ✅ Register user baru
Future<bool> register(String email, String password, {String role = "siswa_pending"}) async {
  _error = null;
  try {
    final existing = await _dao.findByEmail(email.trim());
    if (existing != null) {
      _error = 'Email sudah terdaftar';
      notifyListeners();
      return false;
    }

    // 🔑 Hash password pakai salt
    final salt = generateSalt();
    final hash = hashPassword(password, salt);

    final id = await _dao.insert(
      AppUser(
        email: email.trim(),
        passwordHash: hash,
        salt: salt,
        role: role, password: '', // otomatis "siswa_pending" kalau tidak dikirim
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


  /// ✅ Login user
  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final user = await _dao.findByEmail(email.trim());
      if (user == null) {
        _error = 'Email tidak ditemukan';
        notifyListeners();
        return false;
      }

      // 🔑 Hash password input pakai salt dari DB
      final hash = hashPassword(password, user.salt);
      if (hash != user.passwordHash) {
        _error = 'Password salah';
        notifyListeners();
        return false;
      }

      // 🔑 Role check
      if (user.role == "siswa_pending") {
        _error = "Akun Anda menunggu verifikasi admin";
        notifyListeners();
        return false;
      }

      _current = user;
      await _storage.write(key: 'uid', value: user.id.toString());
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal login: $e';
      notifyListeners();
      return false;
    }
  }

  /// ✅ Logout user
  Future<void> logout() async {
    _current = null;
    await _storage.delete(key: 'uid');
    notifyListeners();
  }
}
