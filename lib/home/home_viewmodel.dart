// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  HomeViewModel(this._authProvider);
  
  bool get isAdmin => _authProvider.isAdmin;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  String? get currentUserId => _authProvider.currentUserId;
  
  Future<void> logout() async {
    await _authProvider.logout();
    notifyListeners();
  }
}
