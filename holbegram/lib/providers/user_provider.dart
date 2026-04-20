import 'package:flutter/material.dart';
import '../models/user.dart';
import '../resources/auth_methods.dart';

class UsersProvider with ChangeNotifier {
  Users? _user;
  final AuthMethods _authMethods = AuthMethods();

  Users get getUsers => _user!;

  Future<void> refreshUsers() async {
    Users user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
