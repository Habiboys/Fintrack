import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  // Using super parameter for key
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize date formatting for Indonesian locale
    initializeDateFormatting('id_ID', null);
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  // Sample data - in a real app, this would come from your database
  final double totalBalance = 5750000;
  final double income = 8500000;
  final double expense = 2750000;

  final List<Map<String, dynamic>> recentTransactions = [
    {
      'title': 'Belanja Bulanan',
      'amount': 350000,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'isExpense': true,
      'category': 'Makanan',
      'icon': Icons.shopping_basket,
      'color': Colors.orange,
    },
    {
      'title': 'Gaji Bulanan',
      'amount': 8500000,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'isExpense': false,
      'category': 'Pendapatan',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'title': 'Tagihan Listrik',
      'amount': 450000,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'isExpense': true,
      'category': 'Utilitas',
      'icon': Icons.electric_bolt,
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get the safe area padding for iOS
// Remove unused variable since SafeArea widget already handles padding
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            // Adjust padding to account for iOS devices
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
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
                        const Text(
                          'Nouval Habibie',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 24,
                      // Fix: Convert int to double for alpha parameter
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 51.0),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      ),
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
                        // Replacing withOpacity with withValues
                        Theme.of(context).primaryColor.withValues(alpha: 204.0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // Replacing withOpacity with withValues
                        color: Theme.of(context).primaryColor.withValues(alpha: 77.0),
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
                        style: TextStyle(fontSize: 16, color: Colors.white70),
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
                        // Mengubah dari spaceBetween menjadi spaceAround untuk distribusi ruang yang lebih baik
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Wrap dengan Flexible untuk memastikan konten dapat menyesuaikan ruang yang tersedia
                          Flexible(
                            child: _buildBalanceItem(
                              context,
                              'Pemasukan',
                              income,
                              Icons.arrow_downward,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8), // Mengurangi jarak antar item
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        // Replacing withOpacity with withValues
                        color: Colors.grey.withValues(alpha: 26.0),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 1000000,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              currencyFormatter.format(rod.toY),
                              const TextStyle(color: Colors.white),
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
                              const titles = [
                                'Sen',
                                'Sel',
                                'Rab',
                                'Kam',
                                'Jum',
                                'Sab',
                                'Min',
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  titles[value.toInt() % titles.length],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBarGroup(0, 250000),
                        _buildBarGroup(1, 400000),
                        _buildBarGroup(2, 150000),
                        _buildBarGroup(3, 650000),
                        _buildBarGroup(4, 350000),
                        _buildBarGroup(5, 900000),
                        _buildBarGroup(6, 200000),
                      ],
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
                        // Navigate to transactions screen
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = recentTransactions[index];
                    return _buildTransactionItem(context, transaction);
                  },
                ),
              ],
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
      mainAxisSize: MainAxisSize.min, // Menggunakan minimum ruang yang diperlukan
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(  // Tambahkan Flexible di sini
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormatter.format(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
              ),
            ],
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Theme.of(context).primaryColor,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // Replacing withOpacity with withValues
            color: Colors.grey.withValues(alpha: 26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Fix: Convert int to double for alpha parameter
              color: transaction['color'].withValues(alpha: 51.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction['icon'],
              color: transaction['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMMM yyyy', 'id_ID').format(transaction['date']),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${transaction['isExpense'] ? '-' : '+'} ${currencyFormatter.format(transaction['amount'])}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transaction['isExpense'] ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
