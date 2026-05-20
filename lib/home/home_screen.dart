// GROUP MEMBERS: [Full Names and Student Numbers]

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../views/student/student_home_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../shared/constants/app_colors.dart';
import '../shared/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Redirect based on user role
    if (authProvider.isAdmin) {
      return const AdminDashboardScreen();
    } else {
      return const StudentHomeScreen();
    }
  }
}