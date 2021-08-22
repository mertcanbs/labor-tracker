import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mware/models/user.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  factory AuthService() {
    return instance;
  }

  AuthService._internal();

  Future<User?> logIn({required String email, required String password}) async {
    UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return cred.user;
  }

  Future<User> signUpForeman({
    required String email,
    required String password,
    required String companyId,
    required String firstName,
    required String lastName,
  }) async {
    UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user!.updateDisplayName('$firstName $lastName');

    await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      'company_id': companyId,
      'user_type': 'Foreman',
      'name': {
        'first': firstName,
        'last': lastName,
      }
    });

    return cred.user!;
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  Future<MWUser?> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    return MWUser.fromSnapshot(user, doc);
  }
}
