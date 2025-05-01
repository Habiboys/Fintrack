import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';

class ProfileScreen extends StatefulWidget {
  // Memperbaiki parameter key menjadi super parameter
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0, // Remove decimal places for cleaner iOS display
  );

  // Sample data - in a real app, this would come from your database
  final Map<String, dynamic> user = {
    'name': 'Nouval Habibie',
    'email': 'nouval.habibie@example.com',
    'joinDate': DateTime(2023, 1, 15),
    'profileImage': null, // In a real app, this would be a URL or asset path
  };

  final List<Map<String, dynamic>> monthlyData = [
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

  @override
  void initState() {
    super.initState();
    // Inisialisasi format tanggal untuk bahasa Indonesia
    initializeDateFormatting('id_ID', null);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                      // Memperbaiki withOpacity menjadi withValues
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 51.0), // 0.2 * 255 = 51
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anggota sejak ${DateFormat('MMMM yyyy', 'id_ID').format(user['joinDate'])}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                   
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Financial Summary
              const Text(
                'Ringkasan Keuangan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 15), // Reduced from 26 to 15
                      blurRadius: 6, // Reduced from 10 to 6
                      offset: const Offset(0, 2), // Reduced from 4 to 2
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < monthlyData.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        monthlyData[value.toInt()]['month'],
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
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Income Line
                            LineChartBarData(
                              spots: List.generate(
                                monthlyData.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  monthlyData[index]['income'] / 1000000,
                                ),
                              ),
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                // Memperbaiki withOpacity menjadi withValues
                                color: Colors.green.withValues(alpha: 26.0), // 0.1 * 255 = 26
                              ),
                            ),
                            // Expense Line
                            LineChartBarData(
                              spots: List.generate(
                                monthlyData.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  monthlyData[index]['expense'] / 1000000,
                                ),
                              ),
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                // Memperbaiki withOpacity menjadi withValues
                                color: Colors.red.withValues(alpha: 26.0), // 0.1 * 255 = 26
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

              // Achievements
              const Text(
                'Pencapaian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _buildAchievementItem(context, achievement);
                },
              ),

              const SizedBox(height: 32),

              // App Settings
              const Text(
                'Pengaturan Aplikasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final settings = [
                    {
                      'title': 'Notifikasi',
                      'icon': Icons.notifications,
                      'color': Colors.orange,
                    },
                    {
                      'title': 'Mata Uang',
                      'icon': Icons.attach_money,
                      'color': Colors.green,
                    },
                    {
                      'title': 'Keamanan',
                      'icon': Icons.security,
                      'color': Colors.blue,
                    },
                    {
                      'title': 'Bantuan & Dukungan',
                      'icon': Icons.help,
                      'color': Colors.purple,
                    },
                    {
                      'title': 'Keluar',
                      'icon': Icons.logout,
                      'color': Colors.red,
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
                      onTap: () {
                        // Handle tap for each setting
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (setting['color'] as Color?)?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              setting['icon'] as IconData,
                              color: setting['color'] as Color?,
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildAchievementItem(
    BuildContext context,
    Map<String, dynamic> achievement,
  ) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement['icon'],
              color: achievement['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(
            achievement['completed']
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: achievement['completed'] ? Colors.green : Colors.grey,
            size: 24,
          ),
        ],
      ),
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
                // Memperbaiki withOpacity menjadi withValues
                color: color.withValues(alpha: 51.0), // 0.2 * 255 = 51
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
