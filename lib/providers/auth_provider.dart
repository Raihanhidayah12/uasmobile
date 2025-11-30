import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan Firestore import!
import 'package:uasmobile/models/user.dart';
// Note: local SQLite removed — using Firestore only

class AuthProvider extends ChangeNotifier {
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

  Future<void> _restoreSession() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // load user profile from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          _current = AppUser(
            id: null,
            email: data['email'] ?? user.email ?? '',
            passwordHash: '',
            salt: '',
            role: data['role'] ?? 'siswa',
          );
        }
      } else {
        _current = null;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Register user baru (SQLite dan Firestore)
  Future<bool> register(
    String email,
    String password, {
    String role = "siswa_pending",
  }) async {
    _error = null;
    try {
      // create Firebase Auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _error = 'Gagal membuat akun Firebase Auth';
        notifyListeners();
        return false;
      }

      // write user profile to Firestore only
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
            'email': email.trim(),
            'role': role,
            'username': email.split('@')[0],
            'created_at': FieldValue.serverTimestamp(),
          });

      _current = AppUser(
        id: null,
        email: email.trim(),
        passwordHash: '',
        salt: '',
        role: role,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal register: $e';
      notifyListeners();
      return false;
    }
  }

  /// Login logic tetap sama
  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _error = 'Gagal login: user tidak ditemukan';
        notifyListeners();
        return false;
      }
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
      final doc = await docRef.get();
      String role;
      String emailStored;
      if (doc.exists) {
        final data = doc.data()!;
        role = (data['role'] ?? 'siswa') as String;
        emailStored = data['email'] ?? firebaseUser.email ?? '';
        if (role == 'siswa_pending') {
          _error = 'Akun Anda menunggu verifikasi admin';
          notifyListeners();
          return false;
        }
      } else {
        // If no Firestore profile exists, allow login based on FirebaseAuth only.
        // Heuristic: treat users with 'admin' in local part as admin, otherwise default to 'siswa'.
        final local = (firebaseUser.email ?? '').split('@').first.toLowerCase();
        if (local.contains('admin')) {
          role = 'admin';
        } else {
          role = 'siswa';
        }
        emailStored = firebaseUser.email ?? '';
      }

      _current = AppUser(
        id: null,
        email: emailStored,
        passwordHash: '',
        salt: '',
        role: role,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal login: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _current = null;
    await _auth.signOut();
    notifyListeners();
  }
}
