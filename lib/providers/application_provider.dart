// GROUP MEMBERS: [Full Names and Student Numbers]

import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/supabase_service.dart';

class ApplicationProvider extends ChangeNotifier {
  List<StudentApplication> _userApplications = [];
  List<StudentApplication> _allApplications = [];
  bool _isLoading = false;

  List<StudentApplication> get userApplications => _userApplications;
  List<StudentApplication> get allApplications => _allApplications;
  bool get isLoading => _isLoading;

  // Load applications for a specific student
  Future<void> loadUserApplications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      _userApplications = response.map((json) => StudentApplication.fromJson(json)).toList();
      print('✅ Loaded ${_userApplications.length} applications for user');
    } catch (e) {
      print('❌ Error loading user applications: $e');
      _userApplications = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load all applications (for admin)
  Future<void> loadAllApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('applications')
          .select()
          .order('submitted_at', ascending: false);

      _allApplications = response.map((json) => StudentApplication.fromJson(json)).toList();
      print('✅ Loaded ${_allApplications.length} total applications');
    } catch (e) {
      print('❌ Error loading all applications: $e');
      _allApplications = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Submit a new application (CREATE)
  Future<bool> submitApplication(StudentApplication application) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('applications')
          .insert({
            'user_id': application.userId,
            'year_of_study': application.yearOfStudy,
            'selected_modules': application.selectedModules.map((m) => {
              'academic_level': m.academicLevel,
              'module_code': m.moduleCode,
              'module_name': m.moduleName,
              'meets_requirements': m.meetsRequirements,
            }).toList(),
            'status': application.status.value,
            'submitted_at': application.submittedAt.toIso8601String(),
            'supporting_documents': application.supportingDocuments,
          })
          .select();

      print('✅ Application saved to Supabase');
      
      // Refresh the lists
      await loadUserApplications(application.userId);
      await loadAllApplications();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error submitting application: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing application (EDIT)
  Future<bool> updateApplication(StudentApplication application) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.client
          .from('applications')
          .update({
            'year_of_study': application.yearOfStudy,
            'selected_modules': application.selectedModules.map((m) => {
              'academic_level': m.academicLevel,
              'module_code': m.moduleCode,
              'module_name': m.moduleName,
              'meets_requirements': m.meetsRequirements,
            }).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', application.id);

      print('✅ Application updated successfully');
      
      // Refresh the lists
      await loadUserApplications(application.userId);
      await loadAllApplications();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error updating application: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update application status (approve/reject)
  Future<bool> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
    String? comment,
  ) async {
    try {
      await SupabaseService.client
          .from('applications')
          .update({
            'status': status.value,
            'admin_comment': comment,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);

      // Refresh the lists
      await loadAllApplications();
      
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error updating status: $e');
      return false;
    }
  }

  // Delete an application (DELETE)
  Future<bool> deleteApplication(String applicationId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.client
          .from('applications')
          .delete()
          .eq('id', applicationId);

      print('✅ Application deleted successfully');
      
      // Refresh the lists
      await loadUserApplications(userId);
      await loadAllApplications();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error deleting application: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get application by ID
  StudentApplication? getApplicationById(String id) {
    try {
      final allApps = [..._userApplications, ..._allApplications];
      return allApps.firstWhere((app) => app.id == id);
    } catch (e) {
      return null;
    }
  }
}