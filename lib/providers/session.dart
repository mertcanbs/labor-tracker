import 'package:flutter/material.dart';
import 'package:mware/models/user.dart';
import 'package:mware/services/auth_service.dart';

class Session extends ChangeNotifier {
  MWUser? _user;
  MWUser? get user => _user;

  bool get isLoggedIn => user != null;

  void setUser(MWUser? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    setUser(await AuthService.instance.getCurrentUser());
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    setUser(null);
  }
}
