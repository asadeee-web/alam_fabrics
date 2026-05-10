import 'package:alam_fabrics/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/services/auth_service.dart';
import 'core/services/database_service.dart';

import 'ui/features/auth/login_screen.dart';
import 'ui/features/auth/login_view_model.dart';
import 'ui/features/inventory/inventory_view_model.dart';
import 'ui/features/sales/sales_view_model.dart';
import 'ui/features/dashboard/dashboard_view_model.dart';
import 'ui/features/reports/reports_view_model.dart';
import 'ui/features/main/main_wrapper.dart';
import 'ui/features/main/main_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA6JAqhuD4koVKCOFbVVBW7kD8MJxvw6jU",
      authDomain: "alam-fabrics.firebaseapp.com",
      projectId: "alam-fabrics",
      storageBucket: "alam-fabrics.firebasestorage.app",
      messagingSenderId: "405687784887",
      appId: "1:405687784887:web:e873d662e69fd4be7ac432",
      measurementId: "G-CRMD233JQP",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => DatabaseService()),

        // View Models
        ChangeNotifierProxyProvider<AuthService, LoginViewModel>(
          create: (context) =>
              LoginViewModel(Provider.of<AuthService>(context, listen: false)),
          update: (context, authService, previous) =>
              previous ?? LoginViewModel(authService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, InventoryViewModel>(
          create: (context) => InventoryViewModel(
            Provider.of<DatabaseService>(context, listen: false),
          ),
          update: (context, dbService, previous) =>
              previous ?? InventoryViewModel(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, SalesViewModel>(
          create: (context) => SalesViewModel(
            Provider.of<DatabaseService>(context, listen: false),
          ),
          update: (context, dbService, previous) =>
              previous ?? SalesViewModel(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            Provider.of<DatabaseService>(context, listen: false),
          ),
          update: (context, dbService, previous) =>
              previous ?? DashboardViewModel(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, ReportsViewModel>(
          create: (context) => ReportsViewModel(
            Provider.of<DatabaseService>(context, listen: false),
          ),
          update: (context, dbService, previous) =>
              previous ?? ReportsViewModel(dbService),
        ),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
      ],
      child: MaterialApp(
        title: 'Alam&sons fabrics shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isAuthenticated) {
      return const MainWrapper();
    } else {
      return const LoginScreen();
    }
  }
}
