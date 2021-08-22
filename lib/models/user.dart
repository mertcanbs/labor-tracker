import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MWUser {
  final User _user;
  late String companyId;
  late String userType;

  late String firstName;
  late String lastName;

  String get email => _user.email!;

  MWUser.fromSnapshot(this._user, DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    companyId = data['company_id'];
    userType = data['user_type'];
    firstName = data['name']?['first'] ?? '';
    lastName = data['name']?['last'] ?? '';
  }
}
