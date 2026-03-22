import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabhub/models/user_model.dart';

/// Firebase Auth + Firestore user profile service.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the currently signed-in user, or null.
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchOrCreate(firebaseUser);
  }

  /// Signs in with a Google account.
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    return _fetchOrCreate(userCredential.user!);
  }

  /// Signs in with email and password.
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fetchOrCreate(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyError(e.code));
    }
  }

  /// Creates a new account with email and password.
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      return _fetchOrCreate(credential.user!, displayName: name);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyError(e.code));
    }
  }

  /// Persists updated profile fields to Firestore.
  Future<UserModel> updateProfile({
    required UserModel user,
    required String name,
    required String role,
    required String bio,
    required List<String> skills,
  }) async {
    await _db.collection('users').doc(user.id).update({
      'name': name,
      'role': role,
      'bio': bio,
      'skills': skills,
    });
    await _auth.currentUser?.updateDisplayName(name);
    return user.copyWith(name: name, role: role, bio: bio, skills: skills);
  }

  /// Signs out from Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Fetches the Firestore user doc; creates it on first sign-in.
  Future<UserModel> _fetchOrCreate(User firebaseUser, {String? displayName}) async {
    final uid = firebaseUser.uid;
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      return UserModel.fromMap(uid, doc.data()!);
    }

    final newUser = UserModel(
      id: uid,
      name: displayName ??
          firebaseUser.displayName ??
          (firebaseUser.email?.split('@').first ?? 'User'),
      email: firebaseUser.email ?? '',
      role: 'University Student',
      bio: '',
      skills: const [],
      avatarUrl: firebaseUser.photoURL,
    );
    await docRef.set(newUser.toMap());
    return newUser;
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
