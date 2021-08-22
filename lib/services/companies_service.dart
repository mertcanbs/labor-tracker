import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mware/models/company.dart';

class CompaniesService {
  static final CompaniesService instance = CompaniesService._internal();

  factory CompaniesService() {
    return instance;
  }

  CompaniesService._internal();

  Future<Iterable<Company>> getCompanies() async {
    final result = await FirebaseFirestore.instance.collection('companies').get();
    return result.docs.map((e) => Company.fromSnapshot(e));
  }

  Future<Company?> getCompanyById(String id) async {
    try {
      final result = await FirebaseFirestore.instance.collection('companies').doc(id).get();
      return Company.fromSnapshot(result);
    } catch (_) {
      return null;
    }
  }

  Future<Company> createCompany({
    required String name,
    required String address,
    required String contactName,
    required String contactNumber,
  }) async {
    final result = await FirebaseFirestore.instance.collection('companies').add({
      'name': name,
      'address': address,
      'contactName': contactName,
      'contactNumber': contactNumber,
    });

    return Company.fromSnapshot(await result.get());
  }
}
