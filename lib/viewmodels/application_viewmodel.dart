// lib/viewmodels/application_viewmodel.dart

import 'package:flutter/material.dart';
import '../providers/application_provider.dart';
import '../models/application.dart';

class ApplicationViewModel extends ChangeNotifier {
  final ApplicationProvider _applicationProvider;
  
  ApplicationViewModel(this._applicationProvider);
  
  List<StudentApplication> get userApplications => _applicationProvider.userApplications;
  List<StudentApplication> get allApplications => _applicationProvider.allApplications;
  bool get isLoading => _applicationProvider.isLoading;
  
  Future<void> loadUserApplications(String userId) async {
    await _applicationProvider.loadUserApplications(userId);
    notifyListeners();
  }
  
  Future<void> loadAllApplications() async {
    await _applicationProvider.loadAllApplications();
    notifyListeners();
  }
  
  Future<bool> submitApplication(StudentApplication application) async {
    final success = await _applicationProvider.submitApplication(application);
    if (success) {
      notifyListeners();
    }
    return success;
  }
  
  Future<bool> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
    String? comment,
  ) async {
    final success = await _applicationProvider.updateApplicationStatus(
      applicationId,
      status,
      comment,
    );
    if (success) {
      notifyListeners();
    }
    return success;
  }
  
  // This matches the provider - no Future
  StudentApplication? getApplicationById(String id) {
    return _applicationProvider.getApplicationById(id);
  }
}