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
import 'package:firebase_core/firebase_core.dart';
import 'package:fintrack/services/notification_service.dart';
import 'package:fintrack/firebase_options.dart';

void main() async {
  // Persiapan untuk splash screen dan Flutter bindings
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // Inisialisasi Firebase dengan konfigurasi default
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inisialisasi notification service
    final notificationService = NotificationService();
    await notificationService.initialize();

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
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Tetap jalankan aplikasi meskipun Firebase gagal diinisialisasi
    runApp(const MyApp(isLoggedIn: false));
  }
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
    const ProfileScreen(),
  ];

  final List<NavigationItem> items = [
    NavigationItem(icon: Icons.dashboard_rounded, label: 'Home'),
    NavigationItem(icon: Icons.sync_alt_rounded, label: 'Transaksi'),
    NavigationItem(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Anggaran',
    ),
    NavigationItem(icon: Icons.grid_view_rounded, label: 'Kategori'),
    NavigationItem(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 768;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Row(
          children: [
            if (isWideScreen) _buildSidebar(),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: isWideScreen ? null : _buildBottomBar(),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Text(
              'FinTrack',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = _selectedIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[800],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () => setState(() => _selectedIndex = index),
                    selected: isSelected,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
          items:
              items
                  .map((item) => TabItem(icon: item.icon, title: item.label))
                  .toList(),
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
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
