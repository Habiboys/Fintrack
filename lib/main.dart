import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintrack/screens/home_screen.dart';
import 'package:fintrack/screens/transaction_screen.dart';
import 'package:fintrack/screens/budget_screen.dart';
import 'package:fintrack/screens/profile_screen.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:fintrack/screens/login_screen.dart';
import 'package:fintrack/screens/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[800],
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      // Remove initialRoute and home
      routes: {
        '/': (context) => const LoginScreen(), // Change to root route
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  final List<TabItem> items = [
    const TabItem(
      icon: Icons.home_rounded,
      title: 'Home',
    ),
    const TabItem(
      icon: Icons.swap_horiz_rounded,
      title: 'Transaksi',
    ),
    const TabItem(
      icon: Icons.pie_chart_rounded,
      title: 'Anggaran',
    ),
    const TabItem(
      icon: Icons.person_rounded,
      title: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 26.0),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomBarDefault(
            items: items,
            backgroundColor: Colors.white,
            color: Colors.grey,
            colorSelected: Theme.of(context).primaryColor,
            indexSelected: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            animated: true,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            paddingVertical: 16,
            enableShadow: true,
          ),
        ),
      ),
    );
  }
}
