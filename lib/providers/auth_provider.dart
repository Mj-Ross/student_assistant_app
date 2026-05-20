// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _isAdmin = false;
  String? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _isAdmin;
  String? get currentUserId => _currentUserId;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        _currentUserId = response.user!.id;
        
        // Try to get user from public.users
        final userData = await SupabaseService.client
            .from('users')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle();
        
        if (userData != null) {
          // User exists in public.users
          _isAdmin = userData['role'] == 'admin';
          print('✅ User found in public.users, role: ${userData['role']}');
        } else {
          // User doesn't exist in public.users - create them
          print('⚠️ User not in public.users, creating entry...');
          
          final isAdminUser = email == 'admin@studentassistant.com';
          
          await SupabaseService.client
              .from('users')
              .insert({
                'id': response.user!.id,
                'email': email,
                'full_name': email.split('@')[0],
                'student_number': 'STU${response.user!.id.substring(0, 8)}',
                'role': isAdminUser ? 'admin' : 'student',
                'department': 'Information Technology',
                'current_year_of_study': isAdminUser ? null : 2,
              });
          
          _isAdmin = isAdminUser;
          print('✅ User created in public.users with role: ${_isAdmin ? 'admin' : 'student'}');
        }
        
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await SupabaseService.client.auth.signOut();
    _isAuthenticated = false;
    _isAdmin = false;
    _currentUserId = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}