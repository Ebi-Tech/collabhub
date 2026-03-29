import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabhub/models/user_model.dart';

// Handles all Firebase Auth operations and syncs user data to Firestore
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // check if someone is already logged in (used on app startup)
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchOrCreate(firebaseUser);
  }

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

  // saves profile edits to Firestore; uploads avatar to Storage if a new photo was picked
  Future<UserModel> updateProfile({
    required UserModel user,
    required String name,
    required String role,
    required String bio,
    required List<String> skills,
    String? avatarLocalPath,
  }) async {
    String? avatarUrl = user.avatarUrl;

    if (avatarLocalPath != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${user.id}.jpg');
      await ref.putFile(File(avatarLocalPath));
      avatarUrl = await ref.getDownloadURL();
    }

    await _db.collection('users').doc(user.id).update({
      'name': name,
      'role': role,
      'bio': bio,
      'skills': skills,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    await _auth.currentUser?.updateDisplayName(name);
    return user.copyWith(
        name: name, role: role, bio: bio, skills: skills, avatarUrl: avatarUrl);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // pull user doc from Firestore, or create one if it's their first time
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
