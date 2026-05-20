// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/application_provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'viewmodels/student_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'services/supabase_service.dart';
import 'views/auth/login_screen.dart';
import 'views/student/student_home_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseService.initialize();
    print('✅ Supabase initialized');
  } catch (e) {
    print('❌ Error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        
        // ViewModels
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(Provider.of<AuthProvider>(context, listen: false)),
        ),
        ChangeNotifierProvider(
          create: (context) => ApplicationViewModel(Provider.of<ApplicationProvider>(context, listen: false)),
        ),
        ChangeNotifierProvider(
          create: (context) => StudentViewModel(
            Provider.of<ApplicationProvider>(context, listen: false),
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminViewModel(Provider.of<ApplicationProvider>(context, listen: false)),
        ),
      ],
      child: MaterialApp(
        title: 'Student Assistant System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/student/home': (context) => const StudentHomeScreen(),
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}
