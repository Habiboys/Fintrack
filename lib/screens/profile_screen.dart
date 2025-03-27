import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  // Sample data - in a real app, this would come from your database
  final Map<String, dynamic> user = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
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
      'title': 'Budget Master',
      'description': 'Stayed under budget for 3 consecutive months',
      'icon': Icons.emoji_events,
      'color': Colors.amber,
      'completed': true,
    },
    {
      'title': 'Saving Star',
      'description': 'Saved more than 20% of income',
      'icon': Icons.star,
      'color': Colors.blue,
      'completed': true,
    },
    {
      'title': 'Expense Tracker',
      'description': 'Recorded expenses for 30 days straight',
      'icon': Icons.trending_down,
      'color': Colors.green,
      'completed': true,
    },
    {
      'title': 'Financial Planner',
      'description': 'Created and maintained 5 different budgets',
      'icon': Icons.account_balance,
      'color': Colors.purple,
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
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
                      'Member since ${DateFormat('MMMM yyyy').format(user['joinDate'])}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Edit profile logic
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Financial Summary
              const Text(
                'Financial Summary',
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
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                                color: Colors.green.withOpacity(0.1),
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
                                color: Colors.red.withOpacity(0.1),
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
                        _buildChartLegend('Income', Colors.green),
                        const SizedBox(width: 24),
                        _buildChartLegend('Expense', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Achievements
              const Text(
                'Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _buildAchievementItem(context, achievement);
                },
              ),

              const SizedBox(height: 32),

              // App Settings
              const Text(
                'App Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      'Notifications',
                      Icons.notifications,
                      Colors.orange,
                      onTap: () {
                        // Navigate to notifications settings
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      'Currency',
                      Icons.attach_money,
                      Colors.green,
                      onTap: () {
                        // Navigate to currency settings
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      'Security',
                      Icons.security,
                      Colors.blue,
                      onTap: () {
                        // Navigate to security settings
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      'Help & Support',
                      Icons.help,
                      Colors.purple,
                      onTap: () {
                        // Navigate to help & support
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      'Logout',
                      Icons.logout,
                      Colors.red,
                      onTap: () {
                        // Logout logic
                      },
                    ),
                  ],
                ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(10),
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
                    fontWeight: FontWeight.bold,
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
