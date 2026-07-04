import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/preferences_service.dart';

class AuthState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final PreferencesService _prefs = PreferencesService();

  User? _user;
  String? _localUsername;
  bool _isAdmin = false;

  bool get isLoggedIn => _user != null;
  bool get isAdmin => _isAdmin;
  String? get email => _user?.email;
  String? get uid => _user?.uid;

  // Ganti Object? menjadi String?
  String? get username {
    if (!isLoggedIn) return 'Users'; // Langsung kembalikan teks murninya

    return _user?.displayName ??
        _localUsername ??
        _user?.email?.split('@').first;
  }

  AuthState() {
    _initSession();
  }

  Future<void> _initSession() async {
    _localUsername = await _prefs.getUserName();
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        final doc = await _db.collection('admins').doc(user.uid).get();
        _isAdmin = doc.exists;
      } else {
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Simpan nama ke profil Firebase
    await credential.user?.updateDisplayName(name);

    // TRIKNYA DI SINI: Langsung paksa logout setelah akun berhasil dibuat!
    await _auth.signOut();

    // Hapus kode notifyListeners() dan saveUserName() yang lama di sini
    // karena user belum resmi "login".
  }

  Future<void> loginWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user?.displayName != null) {
      await _prefs.saveUserName(credential.user!.displayName!);
    }
    // Set admin status langsung agar tersedia saat navigasi
    if (credential.user != null) {
      final doc = await _db.collection('admins').doc(credential.user!.uid).get();
      _isAdmin = doc.exists;
      notifyListeners();
    }
  }

  Future<void> updateProfileName(String newName) async {
    try {
      if (_user != null) {
        await _user!.updateDisplayName(newName);
        await _user!.reload();
        _user = _auth.currentUser;
      }
      await _prefs.saveUserName(newName);
      _localUsername = newName;
      notifyListeners();
    } catch (e) {
      throw Exception('Gagal update nama: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // user cancel

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final name = result.user?.displayName;
    if (name != null) {
      await _prefs.saveUserName(name);
      _localUsername = name;
    }
    // Set admin status langsung agar tersedia saat navigasi
    if (result.user != null) {
      final doc = await _db.collection('admins').doc(result.user!.uid).get();
      _isAdmin = doc.exists;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try { await GoogleSignIn().signOut(); } catch (_) {}
    await _prefs.clearSession();
    await _auth.signOut();
  }
}
