import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuripazu/services/firestore_service.dart';
import 'package:nuripazu/models/index.dart';

/// Firebase Auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Firestore Service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Current user information
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUser(authUser.uid);
});

/// Current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// User creation with email/password
final userSignUpProvider =
    FutureProvider.family<UserCredential, (String, String)>((ref, args) async {
  final (email, password) = args;
  return await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);
});

/// User login
final userSignInProvider =
    FutureProvider.family<UserCredential, (String, String)>((ref, args) async {
  final (email, password) = args;
  return await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
});

/// User logout
final userSignOutProvider = FutureProvider<void>((ref) async {
  return await FirebaseAuth.instance.signOut();
});
