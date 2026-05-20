// GROUP MEMBERS: [Full Names and Student Numbers]

import 'package:flutter/material.dart';
import '../providers/application_provider.dart';
import '../models/application.dart';

class AdminViewModel extends ChangeNotifier {
  final ApplicationProvider _applicationProvider;
  
  AdminViewModel(this._applicationProvider);
  
  List<StudentApplication> get allApplications => _applicationProvider.allApplications;
  bool get isLoading => _applicationProvider.isLoading;
  
  int get totalApplications => _applicationProvider.allApplications.length;
  int get pendingApplications => _applicationProvider.allApplications.where((a) => a.isPending).length;
  int get approvedApplications => _applicationProvider.allApplications.where((a) => a.isApproved).length;
  int get rejectedApplications => _applicationProvider.allApplications.where((a) => a.isRejected).length;
  
  Future<void> loadAllApplications() async {
    await _applicationProvider.loadAllApplications();
    notifyListeners();
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
      await loadAllApplications();
      notifyListeners();
    }
    return success;
  }
  
  List<StudentApplication> getFilteredApplications(String filter) {
    switch (filter) {
      case 'pending':
        return allApplications.where((a) => a.isPending).toList();
      case 'approved':
        return allApplications.where((a) => a.isApproved).toList();
      case 'rejected':
        return allApplications.where((a) => a.isRejected).toList();
      default:
        return allApplications;
    }
  }
}