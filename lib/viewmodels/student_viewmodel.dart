// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]

import 'package:flutter/material.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../models/application.dart';

class StudentViewModel extends ChangeNotifier {
  final ApplicationProvider _applicationProvider;
  final AuthProvider _authProvider;
  
  StudentViewModel(this._applicationProvider, this._authProvider);
  
  List<StudentApplication> get myApplications => _applicationProvider.userApplications;
  bool get isLoading => _applicationProvider.isLoading;
  bool get hasActiveApplication => _applicationProvider.userApplications.any(
    (app) => app.isPending || app.isApproved
  );
  String? get currentUserId => _authProvider.currentUserId;
  
  Future<void> loadMyApplications() async {
    if (_authProvider.currentUserId != null) {
      await _applicationProvider.loadUserApplications(_authProvider.currentUserId!);
      notifyListeners();
    }
  }
  
  Future<bool> submitApplication(StudentApplication application) async {
    final success = await _applicationProvider.submitApplication(application);
    if (success) {
      await loadMyApplications();
      notifyListeners();
    }
    return success;
  }
  
  Future<bool> deleteApplication(String applicationId) async {
    // TODO: Implement delete
    notifyListeners();
    return true;
  }
}
