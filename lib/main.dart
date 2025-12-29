import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/gemini_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/resident_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GeminiService()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barangay Scheduler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/resident_dashboard': (context) => const ResidentDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    if (!authService.isAuthenticated) {
      return const LoginScreen();
    }

    if (authService.isAdmin) {
      return const AdminDashboard();
    } else {
      return const ResidentDashboard();
    }
  }
}
