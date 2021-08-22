import 'package:flutter/material.dart';
import 'package:mware/models/company.dart';
import 'package:mware/services/companies_service.dart';

class SignupProvider extends ChangeNotifier {
  Iterable<Company>? _companies;
  Iterable<Company>? get companies => _companies;

  SignupProvider() {
    CompaniesService.instance.getCompanies().then((value) => _companies = value);
  }
}
