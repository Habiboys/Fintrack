import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fintrack/services/dashboard_service.dart';
import 'package:logger/logger.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:fintrack/main.dart';
import 'dart:math';
import 'package:fintrack/widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  final Logger _logger = Logger();

  // Data state
  double totalBalance = 0;
  double income = 0;
  double expense = 0;
  List<Map<String, dynamic>> recentTransactions = [];
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> dailySpending = [];
  String userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadUserProfile().then((_) {
      _loadDashboardData();
    });
  }

  // Fungsi untuk memuat data dashboard
  Future<void> _loadDashboardData() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = '';
        });
      }

      // Dapatkan data dashboard dan spending overview secara paralel
      final results = await Future.wait([
        _dashboardService.getDashboardData(),
        _dashboardService.getSpendingOverview(),
      ]);

      final dashboardData = results[0] as Map<String, dynamic>;
      final spendingData = results[1] as List<Map<String, dynamic>>;

      _logger.d('Dashboard data: $dashboardData');
      _logger.d('Spending data: $spendingData');

      if (mounted) {
        setState(() {
          // Parse data dasar dengan penanganan error
          _parseDashboardData(dashboardData);

          // Simpan data spending overview untuk grafik
          dailySpending = spendingData;

          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading dashboard data',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  // Metode untuk memisahkan parsing data dashboard
  void _parseDashboardData(Map<String, dynamic> dashboardData) {
    try {
      // Log seluruh data untuk debugging
      _logger.d('Parsing dashboard data: $dashboardData');

      // Parse data dasar
      if (dashboardData.containsKey('data')) {
        var data = dashboardData['data'];
        if (data == null) {
          _logger.w('Dashboard data.data is null');
          return;
        }

        _logger.d('Dashboard data content: $data');

        // Gunakan accountBalance langsung karena sudah memperhitungkan transaksi
        // Tidak perlu mengurangi expense lagi karena accountBalance sudah mencakup semua transaksi
        if (data.containsKey('accountBalance')) {
          var accountBalance = _parseAmount(data['accountBalance']);
          totalBalance = accountBalance;
          _logger.d('Using account balance: $totalBalance');
        } else if (data.containsKey('totalBalance')) {
          // Fallback ke totalBalance jika accountBalance tidak ada
          var rawBalance = data['totalBalance'];
          totalBalance = _parseAmount(rawBalance);
          _logger.d('Using total balance: $totalBalance');
        }

        // Handle income
        if (data.containsKey('monthlyIncome')) {
          var rawIncome = data['monthlyIncome'];
          income = _parseAmount(rawIncome);
          _logger.d('Parsed income: $income');
        }

        // Handle expense
        if (data.containsKey('monthlyExpense')) {
          var rawExpense = data['monthlyExpense'];
          expense = _parseAmount(rawExpense);
          _logger.d('Parsed expense: $expense');
        }

        // Handle userName
        if (data.containsKey('user') && data['user'] != null) {
          var user = data['user'];
          if (user is Map) {
            userName = user['fullname'] ?? user['username'] ?? 'Pengguna';
            _logger.d('Parsed userName: $userName');
          }
        } else {
          // Ambil data dari profil sekarang
          _loadUserProfile();
        }

        // Handle recentTransactions dengan penanganan berbagai format
        _parseTransactions(data);
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error parsing dashboard data',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Fungsi untuk memuat profil pengguna jika tidak tersedia di dashboard data
  Future<void> _loadUserProfile() async {
    try {
      final authService = AuthService();
      final result = await authService.getCurrentUser();

      if (result['success'] == true && result.containsKey('data')) {
        final userData = result['data'];
        if (mounted) {
          setState(() {
            if (userData is Map) {
              if (userData.containsKey('user')) {
                final user = userData['user'];
                userName = user['fullname'] ?? user['username'] ?? 'Pengguna';
              } else {
                userName =
                    userData['fullname'] ?? userData['username'] ?? 'Pengguna';
              }
            }
          });
        }
      }
    } catch (e) {
      _logger.w('Error loading user profile: $e');
    }
  }

  // Metode untuk memisahkan parsing transaksi
  void _parseTransactions(dynamic data) {
    try {
      // Reset list transaksi
      recentTransactions = [];

      // Coba beberapa kemungkinan format data transaksi
      List? rawTransactions;

      if (data.containsKey('recentTransactions')) {
        var transData = data['recentTransactions'];
        if (transData is List) {
          rawTransactions = transData;
        } else if (transData is Map && transData.containsKey('transactions')) {
          // Format alternatif: {recentTransactions: {transactions: [...]}}
          var nestedTrans = transData['transactions'];
          if (nestedTrans is List) {
            rawTransactions = nestedTrans;
          }
        }
      }

      // Jika tidak ada data transaksi, biarkan list transaksi kosong
      if (rawTransactions == null || rawTransactions.isEmpty) {
        _logger.d('No transaction data found');
        return;
      }

      // Proses setiap transaksi
      for (var item in rawTransactions) {
        if (item is Map) {
          try {
            Map<String, dynamic> transaction = Map<String, dynamic>.from(item);

            // Set transaction type berdasarkan transaction_type dari API
            if (transaction.containsKey('transaction_type')) {
              transaction['isExpense'] =
                  transaction['transaction_type'].toString().toLowerCase() ==
                  'expense';
            }

            // Set description sebagai title jika title tidak ada
            if (!transaction.containsKey('title') &&
                transaction.containsKey('description')) {
              transaction['title'] = transaction['description'];
            }

            // Tambahkan properti visual yang diperlukan UI
            var categoryData =
                transaction['Category'] ?? transaction['category'];
            if (categoryData is Map) {
              // Jika kategori ada, gunakan warna dan ikon dari kategori
              String colorHex = categoryData['color'] ?? '#6C63FF';
              Color color = _parseColor(colorHex);
              transaction['color'] = color;

              // Parse icon jika ada
              String iconName = categoryData['icon'] ?? 'category';
              transaction['icon'] = _getIconData(iconName);
            } else {
              // Default jika kategori tidak ada
              transaction['color'] =
                  transaction['isExpense'] == true ? Colors.red : Colors.green;
              transaction['icon'] =
                  transaction['isExpense'] == true
                      ? Icons.arrow_upward
                      : Icons.arrow_downward;
            }

            // Pastikan ada date dalam format proper
            if (transaction.containsKey('transaction_date') &&
                transaction['transaction_date'] != null) {
              // API mungkin mengirim transaction_date, bukan date
              try {
                transaction['date'] = DateTime.parse(
                  transaction['transaction_date'],
                );
              } catch (e) {
                transaction['date'] = DateTime.now();
              }
            } else if (transaction.containsKey('date') &&
                transaction['date'] != null) {
              if (transaction['date'] is String) {
                try {
                  transaction['date'] = DateTime.parse(transaction['date']);
                } catch (e) {
                  transaction['date'] = DateTime.now();
                }
              } else if (!(transaction['date'] is DateTime)) {
                transaction['date'] = DateTime.now();
              }
            } else {
              transaction['date'] = DateTime.now();
            }

            recentTransactions.add(transaction);
          } catch (e) {
            _logger.w('Error processing transaction item: $e');
          }
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error parsing transactions', error: e, stackTrace: stackTrace);
    }
  }

  // Parse warna dari hex string
  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      _logger.w('Error parsing color: $hexColor', error: e);
    }
    return const Color(0xFF6C63FF); // Default color
  }

  // Get icon data from string
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'food':
      case 'makanan':
        return Icons.restaurant;
      case 'transport':
      case 'transportasi':
        return Icons.directions_car;
      case 'shopping':
      case 'belanja':
        return Icons.shopping_basket;
      case 'entertainment':
      case 'hiburan':
        return Icons.movie;
      case 'utilities':
      case 'utilitas':
        return Icons.flash_on;
      case 'health':
      case 'kesehatan':
        return Icons.medical_services;
      case 'education':
      case 'pendidikan':
        return Icons.school;
      case 'income':
      case 'pendapatan':
        return Icons.account_balance_wallet;
      case 'salary':
      case 'gaji':
        return Icons.work;
      case 'gift':
      case 'hadiah':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

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
            'Beranda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            tooltip: 'Refresh data',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SafeArea(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.0,
                        16.0,
                        16.0,
                        16.0 + safePadding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat datang kembali,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName.isNotEmpty ? userName : 'Pengguna',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Balance Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Saldo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyFormatter.format(totalBalance),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: _buildBalanceItem(
                                        context,
                                        'Pemasukan',
                                        income,
                                        Icons.arrow_downward,
                                        Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: _buildBalanceItem(
                                        context,
                                        'Pengeluaran',
                                        expense,
                                        Icons.arrow_upward,
                                        Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Spending Chart
                          const Text(
                            'Ringkasan Pengeluaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 200,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child:
                                dailySpending.isEmpty
                                    ? const Center(
                                      child: Text('Tidak ada data pengeluaran'),
                                    )
                                    : BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY: _getMaxY(),
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            tooltipBgColor: Colors.blueGrey,
                                            getTooltipItem: (
                                              group,
                                              groupIndex,
                                              rod,
                                              rodIndex,
                                            ) {
                                              return BarTooltipItem(
                                                currencyFormatter.format(
                                                  rod.toY,
                                                ),
                                                const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() <
                                                    dailySpending.length) {
                                                  final day =
                                                      dailySpending[value
                                                          .toInt()]['day'] ??
                                                      '';
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Text(
                                                      day.toString().substring(
                                                        0,
                                                        min(
                                                          day.toString().length,
                                                          3,
                                                        ),
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: _buildBarGroups(),
                                      ),
                                    ),
                          ),

                          const SizedBox(height: 24),

                          // Recent Transactions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Transaksi Terakhir',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigasi ke MainScreen dengan tab transaksi (indeks 1)
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const MainScreen(
                                            initialTabIndex: 1,
                                          ),
                                    ),
                                  );
                                },
                                child: const Text('Lihat Semua'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          recentTransactions.isEmpty
                              ? Container(
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
                                child: const Center(
                                  child: Text(
                                    'Belum ada transaksi. Tambahkan transaksi pertama Anda!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                              : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: recentTransactions.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 6),
                                itemBuilder: (context, index) {
                                  final transaction = recentTransactions[index];
                                  return _buildTransactionItem(
                                    context,
                                    transaction,
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                currencyFormatter.format(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fungsi helper untuk membuat BarChartGroupData
  BarChartGroupData _buildBarGroup(int x, double y, {Color? color}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color ?? Theme.of(context).primaryColor,
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    return TransactionCard(
      transaction: transaction,
      currencyFormatter: currencyFormatter,
      showCategory: false,
    );
  }

  // Helper untuk mengkonversi berbagai tipe data amount ke double
  double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;

    if (amount is num) return amount.toDouble();

    if (amount is String) {
      // Hapus karakter non-numerik (kecuali titik desimal)
      final String cleanedAmount = amount.replaceAll(RegExp(r'[^0-9.]'), '');
      try {
        return double.parse(cleanedAmount);
      } catch (e) {
        _logger.w('Error parsing amount string: $amount');
        return 0.0;
      }
    }

    return 0.0;
  }

  // Fungsi untuk mendapatkan nilai maksimum Y dari data pengeluaran
  double _getMaxY() {
    if (dailySpending.isEmpty) {
      return 1000000; // Nilai default jika tidak ada data
    }

    // Cari nilai tertinggi dari data pengeluaran dan tambahkan 10% untuk margin
    double maxAmount = 0;
    for (var spending in dailySpending) {
      final amount = (spending['amount'] ?? 0).toDouble();
      if (amount > maxAmount) {
        maxAmount = amount;
      }
    }

    return maxAmount * 1.1; // Tambahkan 10% margin
  }

  // Fungsi untuk membuat daftar BarChartGroupData berdasarkan data
  List<BarChartGroupData> _buildBarGroups() {
    if (dailySpending.isEmpty) {
      // Data statis untuk fallback
      return [
        _buildBarGroup(0, 0),
        _buildBarGroup(1, 0),
        _buildBarGroup(2, 0),
        _buildBarGroup(3, 0),
        _buildBarGroup(4, 0),
        _buildBarGroup(5, 0),
        _buildBarGroup(6, 0),
      ];
    }

    // Buat grup bar dari data yang sebenarnya
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < dailySpending.length; i++) {
      final spending = dailySpending[i];
      final double amount = (spending['amount'] ?? 0).toDouble();
      groups.add(_buildBarGroup(i, amount, color: _getBarColor(amount)));
    }

    return groups;
  }

  // Fungsi untuk mendapatkan warna bar berdasarkan jumlah pengeluaran
  Color _getBarColor(double amount) {
    if (amount > 500000) {
      return Colors.redAccent;
    } else if (amount > 200000) {
      return Colors.orangeAccent;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  // Helper untuk menentukan nilai minimum
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
