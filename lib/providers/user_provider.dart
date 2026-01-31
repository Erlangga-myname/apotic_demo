import 'package:flutter/material.dart';
import '../models/shared/user_models.dart';
import '../services/firebase_service.dart';

class UserData extends ChangeNotifier {
  bool isLoggedIn = false;
  UserBase? loggedInUser;
  final FirebaseService _firebaseService = FirebaseService();

  Future<UserBase?> login(String email, String password) async {
    UserBase? user = await _firebaseService.login(email, password);
    if (user != null) {
      isLoggedIn = true;
      loggedInUser = user;
      notifyListeners();
      return user;
    }
    return null;
  }

  void loginNative(UserBase user) {
    isLoggedIn = true;
    loggedInUser = user;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    loggedInUser = null;
    notifyListeners();
  }
}
