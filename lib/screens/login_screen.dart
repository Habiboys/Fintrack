import 'package:flutter/material.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/widgets/custom_text_field.dart';
import 'package:fintrack/widgets/auth_button.dart';
import 'package:fintrack/screens/register_screen.dart';
import 'package:fintrack/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  // Using super parameter syntax
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

// Changed from _LoginScreenState to LoginScreenState (removing the underscore)
class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo or App Name
                  // Icon(
                  //   Icons.account_balance_wallet,
                  //   size: 80,
                  //   color: Theme.of(context).primaryColor,
                  // ),
                  const SizedBox(height: 16),
                  Text(
                    'FinTrack',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      // if (value.length < 6) {
                      //   return 'Password must be at least 6 characters';
                      // }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       // Navigate to forgot password screen
                  //     },
                  //     child: Text(
                  //       'Forgot Password?',
                  //       style: TextStyle(color: Theme.of(context).primaryColor),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 24),

                  // Login Button
                  AuthButton(
                    text: 'Login',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
