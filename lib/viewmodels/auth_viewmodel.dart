// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]

import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  AuthViewModel(this._authProvider);
  
  bool get isLoading => _authProvider.isLoading;
  String? get errorMessage => _authProvider.errorMessage;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  bool get isAdmin => _authProvider.isAdmin;
  String? get currentUserId => _authProvider.currentUserId;
  
  Future<bool> login(String email, String password) async {
    return await _authProvider.login(email, password);
  }
  
  Future<void> logout() async {
    await _authProvider.logout();
  }
  
  void clearError() {
    _authProvider.clearError();
  }
}
