import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fintrack/services/auth_service.dart'; // Import service
import 'package:fintrack/services/dashboard_service.dart'; // Import service
import 'package:logger/logger.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Initialize services
  final AuthService _authService = AuthService();
  final DashboardService _dashboardService = DashboardService();
  final _logger = Logger(); // Initialize logger

  // Data state
  Map<String, dynamic> user = {};
  List<Map<String, dynamic>> monthlyData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadData(); // Load data saat inisialisasi
  }

  // Fungsi untuk memuat data profil dan statistik keuangan
  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Cobalah memuat data profil pengguna jika tersedia
      try {
        // Load user profile first
        final userResult = await _authService.getCurrentUser();
        _logger.d('User result: $userResult');

        // Struktur data dari backend adalah {user: {...}, message: "..."}
        Map<String, dynamic> userData = {};
        if (userResult != null) {
          // Cek apakah respons memiliki key 'data'
          if (userResult.containsKey('data')) {
            _logger.d('Response with data key: ${userResult['data']}');
            // Format API lama - data dalam objek data
            if (userResult['data'] != null) {
              if (userResult['data'] is Map &&
                  userResult['data'].containsKey('user')) {
                userData = userResult['data']['user'];
              } else {
                userData = userResult['data'];
              }
            }
          } else if (userResult.containsKey('user')) {
            // Format API baru - user langsung di root objek
            _logger.d('Response with direct user key');
            userData = userResult['user'];
          }
        }

        _logger.d('Final user data: $userData');
        if (userData.isNotEmpty) {
          _logger.d('User data keys: ${userData.keys.toList()}');
        }

        setState(() {
          user = userData;
          _logger.d('User email: ${user['email']}');
        });
      } catch (profileError) {
        _logger.w('Gagal memuat profil: $profileError', error: profileError);
        // Jangan logout, gunakan data dummy saja
        setState(() {
          user = {
            'name': 'Pengguna FinTrack',
            'email': 'pengguna@fintrack.app',
            'joinDate': DateTime.now().toIso8601String(),
          };
        });
      }

      // Coba muat data ringkasan bulanan
      try {
        final monthlySummary = await _dashboardService.getMonthlySummary();
        setState(() {
          monthlyData = List<Map<String, dynamic>>.from(
            monthlySummary['data']['months'] ?? [],
          );
        });
      } catch (summaryError) {
        _logger.w('Gagal memuat ringkasan bulanan: $summaryError');
        // Gunakan data dummy untuk visualisasi
        setState(() {
          monthlyData = sampleMonthlyData;
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      _logger.e('Error loading profile data', error: e);
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat data: $e';
      });
    }
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (!mounted) return;

      // Perbaikan: Gunakan navigator untuk kembali ke halaman login dengan mengganti pushReplacementNamed ke rute /login
      Navigator.of(context).pushReplacementNamed('/login');

      // Tampilkan notifikasi logout berhasil
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logout berhasil')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
      }
    }
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0, // Remove decimal places for cleaner iOS display
  );

  // Sample data - in a real app, this would come from your database
  final Map<String, dynamic> sampleUser = {
    'name': 'Nouval Habibie',
    'email': 'nouval.habibie@example.com',
    'joinDate': DateTime(2023, 1, 15),
    'profileImage': null, // In a real app, this would be a URL or asset path
  };

  final List<Map<String, dynamic>> sampleMonthlyData = [
    {'month': 'Jan', 'income': 7500000, 'expense': 5000000},
    {'month': 'Feb', 'income': 8000000, 'expense': 5500000},
    {'month': 'Mar', 'income': 7800000, 'expense': 4800000},
    {'month': 'Apr', 'income': 8200000, 'expense': 5200000},
    {'month': 'May', 'income': 8500000, 'expense': 5100000},
    {'month': 'Jun', 'income': 8300000, 'expense': 4900000},
  ];

  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'Master Anggaran',
      'description': 'Tetap di bawah anggaran selama 3 bulan berturut-turut',
      'icon': Icons.emoji_events,
      'color': Colors.amber,
      'completed': true,
    },
    {
      'title': 'Bintang Tabungan',
      'description': 'Menabung lebih dari 20% pendapatan',
      'icon': Icons.star,
      'color': Colors.blue,
      'completed': true,
    },
    {
      'title': 'Pelacak Pengeluaran',
      'description': 'Mencatat pengeluaran selama 30 hari berturut-turut',
      'icon': Icons.trending_down,
      'color': Colors.green,
      'completed': true,
    },
    {
      'title': 'Perencana Keuangan',
      'description': 'Membuat dan memelihara 5 anggaran berbeda',
      'icon': Icons.account_balance,
      'color': Colors.purple,
      'completed': false,
    },
  ];

  // Helper untuk mendapatkan nilai 'month' sebagai String
  String _getMonthName(dynamic month) {
    if (month == null) return '';
    if (month is String) return month;
    if (month is int || month is num) return month.toString();
    return '';
  }

  // Add helper for numeric values
  double _getNumericValue(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Profil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user['fullname'] ??
                                  user['username'] ??
                                  'Tidak ada nama',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['email'] ?? 'Email tidak tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['joinDate'] != null
                                  ? 'Anggota sejak ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime.parse(user['joinDate']))}'
                                  : 'Tanggal bergabung tidak tersedia',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Financial Summary
                      const Text(
                        'Ringkasan Keuangan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child:
                                  monthlyData.isEmpty
                                      ? const Center(
                                        child: Text('Tidak ada data tersedia'),
                                      )
                                      : LineChart(
                                        LineChartData(
                                          gridData: FlGridData(show: false),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  if (value.toInt() >= 0 &&
                                                      value.toInt() <
                                                          monthlyData.length) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 8.0,
                                                          ),
                                                      child: Text(
                                                        _getMonthName(
                                                          monthlyData[value
                                                              .toInt()]['month'],
                                                        ),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          lineBarsData: [
                                            // Income Line
                                            LineChartBarData(
                                              spots: List.generate(
                                                monthlyData.length,
                                                (index) => FlSpot(
                                                  index.toDouble(),
                                                  _getNumericValue(
                                                        monthlyData[index]['income'],
                                                      ) /
                                                      1000000,
                                                ),
                                              ),
                                              isCurved: true,
                                              curveSmoothness: 0.3,
                                              preventCurveOverShooting: true,
                                              color: Colors.green,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(show: false),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                cutOffY: 0,
                                                applyCutOffY: true,
                                              ),
                                            ),
                                            // Expense Line
                                            LineChartBarData(
                                              spots: List.generate(
                                                monthlyData.length,
                                                (index) => FlSpot(
                                                  index.toDouble(),
                                                  _getNumericValue(
                                                        monthlyData[index]['expense'],
                                                      ) /
                                                      1000000,
                                                ),
                                              ),
                                              isCurved: true,
                                              curveSmoothness: 0.3,
                                              preventCurveOverShooting: true,
                                              color: Colors.red,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(show: false),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                cutOffY: 0,
                                                applyCutOffY: true,
                                              ),
                                            ),
                                          ],
                                          minY: 0,
                                        ),
                                      ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildChartLegend('Pendapatan', Colors.green),
                                const SizedBox(width: 24),
                                _buildChartLegend('Pengeluaran', Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App Settings
                      const Text(
                        'Pengaturan Aplikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final settings = [
                            {
                              'title': 'Notifikasi',
                              'icon': Icons.notifications,
                              'color': Colors.orange,
                              'route': null,
                            },
                            {
                              'title': 'Mata Uang',
                              'icon': Icons.attach_money,
                              'color': Colors.green,
                              'route': null,
                            },
                            {
                              'title': 'Keamanan',
                              'icon': Icons.security,
                              'color': Colors.indigo,
                              'route': null,
                            },
                            {
                              'title': 'Bantuan & Dukungan',
                              'icon': Icons.help,
                              'color': Colors.purple,
                              'route': null,
                            },
                            {
                              'title': 'Keluar',
                              'icon': Icons.logout,
                              'color': Colors.red,
                              'onTap': _logout,
                            },
                          ];

                          final setting = settings[index];
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap:
                                  setting['onTap'] != null
                                      ? setting['onTap'] as Function()
                                      : () {
                                        if (setting['title'] == 'Kategori') {
                                          // Navigasi khusus untuk Kategori
                                          Navigator.of(
                                            context,
                                          ).pushNamed('/category');
                                        } else if (setting['route'] != null) {
                                          // Untuk route lain yang sudah didefinisikan
                                          final route =
                                              setting['route'] as String;
                                          Navigator.of(
                                            context,
                                          ).pushNamed(route);
                                        } else {
                                          // Fallback untuk fitur yang belum diimplementasikan
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${setting['title']} belum diimplementasikan',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (setting['color'] as Color)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      setting['icon'] as IconData,
                                      color: setting['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      setting['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Version Info
                      Center(
                        child: Text(
                          'FinTrack v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
