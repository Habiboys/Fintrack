import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintrack/screens/home_screen.dart';
import 'package:fintrack/screens/transaction_screen.dart';
import 'package:fintrack/screens/budget_screen.dart';
import 'package:fintrack/screens/profile_screen.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:fintrack/screens/login_screen.dart';
import 'package:fintrack/screens/register_screen.dart';
import 'package:fintrack/screens/category_screen.dart';
import 'package:fintrack/screens/account_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:logger/logger.dart';

void main() async {
  // Persiapan untuk splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Cek token untuk login persisten
  final authService = AuthService();
  final bool isLoggedIn = await authService.isAuthenticated();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    // Hapus splash screen setelah aplikasi dimuat
    FlutterNativeSplash.remove();

    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 0, 119, 58),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
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
      home:
          isLoggedIn
              ? const MainScreen(initialTabIndex: 0)
              : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(initialTabIndex: 0),
        '/category': (context) => const CategoryScreen(),
        '/account': (context) => const AccountScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final AuthService _authService = AuthService();
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _checkAuth();
  }

  // Cek autentikasi secara berkala
  Future<void> _checkAuth() async {
    try {
      bool isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated && mounted) {
        _logger.w('Sesi login tidak valid, kembali ke halaman login');
        // Jika token tidak valid, redirect ke login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _logger.e('Error saat memeriksa autentikasi', error: e);
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const BudgetScreen(),
    const CategoryScreen(),
    // const AccountScreen(),
    const ProfileScreen(),
  ];

  final List<TabItem> items = [
    const TabItem(icon: Icons.dashboard_rounded, title: 'Home'),
    const TabItem(icon: Icons.sync_alt_rounded, title: 'Transaksi'),
    const TabItem(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Anggaran',
    ),
    const TabItem(icon: Icons.grid_view_rounded, title: 'Kategori'),
    // const TabItem(icon: Icons.account_balance_wallet, title: 'Rekening'),
    const TabItem(icon: Icons.person_outline_rounded, title: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Jika pengguna tidak berada di tab beranda, maka kembalikan ke beranda
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Jangan keluar dari aplikasi
        }
        // Jika sudah di beranda, biarkan sistem menangani navigasi kembali
        return true;
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomBarDefault(
              items: items,
              backgroundColor: Colors.transparent,
              color: Colors.grey,
              colorSelected: Theme.of(context).primaryColor,
              indexSelected: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              animated: true,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuint,
              paddingVertical: 12,
              enableShadow: false,
            ),
          ),
        ),
      ),
    );
  }
}
