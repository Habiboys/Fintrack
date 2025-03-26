import 'package:flutter/material.dart';
import 'package:fintrack/screens/login_screen.dart';
import 'package:fintrack/screens/home_screen.dart';
import 'package:fintrack/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          elevation: 0,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _authService.isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final isAuthenticated = snapshot.data ?? false;
          return isAuthenticated ? HomeScreen() : LoginScreen();
        },
      ),
    );
  }
}
