import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  late String id;
  late String name;
  late String address;

  late String contactName;
  late String contactNumber;

  @override
  bool operator ==(other) => other is Company && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Company.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    id = snapshot.id;
    name = data?['name'] ?? '';
    address = data?['address'] ?? '';
    contactName = data?['contact_name'] ?? '';
    contactNumber = data?['contact_number'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'contact_name': contactName,
      'contact_number': contactNumber,
    };
  }
}
