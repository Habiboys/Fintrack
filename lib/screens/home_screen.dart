import 'package:flutter/material.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  // Using super parameter syntax
  HomeScreen({super.key});
  
  final AuthService _authService = AuthService();

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FinTrack Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to FinTrack!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

