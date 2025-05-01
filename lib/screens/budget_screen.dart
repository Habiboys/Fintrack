import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BudgetScreen extends StatefulWidget {
  // Fixed: Using super parameter for key
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
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
  final double totalBudget = 5000000;
  final double totalSpent = 3250000;

  final List<Map<String, dynamic>> budgetCategories = [
    {
      'name': 'Makanan',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'budget': 1500000,
      'spent': 1250000,
    },
    {
      'name': 'Transportasi',
      'icon': Icons.directions_car,
      'color': Colors.purple,
      'budget': 800000,
      'spent': 650000,
    },
    {
      'name': 'Utilitas',
      'icon': Icons.electric_bolt,
      'color': Colors.blue,
      'budget': 1000000,
      'spent': 800000,
    },
    {
      'name': 'Belanja',
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
      'budget': 1200000,
      'spent': 400000,
    },
    {
      'name': 'Hiburan',
      'icon': Icons.movie,
      'color': Colors.red,
      'budget': 500000,
      'spent': 150000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalBudget - totalSpent;
    final budgetProgress = totalSpent / totalBudget;

   return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Anggaran',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 51.0), // 0.2 * 255 = 51
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetModal(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Budget Overview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8), // Changed from withValues
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3), // Changed from withValues
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Anggaran Bulanan',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 12.0,
                      percent: budgetProgress > 1 ? 1 : budgetProgress,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currencyFormatter.format(remainingBudget),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Tersisa',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      progressColor:
                          remainingBudget < 0 ? Colors.red : Colors.greenAccent, // Changed from white to greenAccent
                      backgroundColor: Colors.white.withOpacity(0.2), // Changed from withValues to withOpacity
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBudgetSummaryItem(
                          'Total Anggaran',
                          currencyFormatter.format(totalBudget),
                        ),
                        _buildBudgetSummaryItem(
                          'Total Pengeluaran',
                          currencyFormatter.format(totalSpent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Budget Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kategori Anggaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // TextButton.icon removed from here
                ],
              ),
              const SizedBox(height: 24),
              ListView.separated(  // Changed from ListView.builder to ListView.separated
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgetCategories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),  // Adjust spacing as needed
                itemBuilder: (context, index) {
                  final category = budgetCategories[index];
                  return _buildBudgetCategoryItem(context, category);
                },
              ),

              const SizedBox(height: 24),

              // Budget Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Fixed: Replaced withOpacity with withValues
                  color: Colors.amber.withValues(alpha: 51.0), // 0.2 * 255 = 51
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text(
                          'Tips Anggaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Coba aturan 50/30/20: Gunakan 50% penghasilan untuk kebutuhan, 30% untuk keinginan, dan simpan 20%.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCategoryItem(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final double spent = (category['spent'] as int).toDouble();
    final double budget = (category['budget'] as int).toDouble();
    final double progress = spent / budget;
    final bool isOverBudget = spent > budget;

    return Container(
      // Increase padding for larger boxes
      padding: const EdgeInsets.all(24),  // Changed from 16 to 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),  // Increased from 12 to 16
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),  // Changed from withValues to withOpacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),  // Increased from 8 to 12
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.2),  // Changed from withValues to withOpacity
                  borderRadius: BorderRadius.circular(12),  // Increased from 8 to 12
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 28,  // Increased from 20 to 28
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currencyFormatter.format(spent)} dari ${currencyFormatter.format(budget)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isOverBudget ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? Colors.red : Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress > 1 ? 1 : progress,
            progressColor: isOverBudget ? Colors.red : category['color'],
            backgroundColor: Colors.grey[200],
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
          if (isOverBudget) ...[
            const SizedBox(height: 8),
            Text(
              'Melebihi anggaran sebesar ${currencyFormatter.format(spent - budget)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddBudgetModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String category = 'Makanan';
    // Fixed: Using the amount variable in the onPressed callback
    double amount = 0;

    final categories = [
      {'name': 'Makanan', 'icon': Icons.restaurant, 'color': Colors.orange},
      {
        'name': 'Transportasi',
        'icon': Icons.directions_car,
        'color': Colors.purple,
      },
      {'name': 'Utilitas', 'icon': Icons.electric_bolt, 'color': Colors.blue},
      {'name': 'Belanja', 'icon': Icons.shopping_bag, 'color': Colors.pink},
      {'name': 'Hiburan', 'icon': Icons.movie, 'color': Colors.red},
      {'name': 'Lainnya', 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white, // Explicit for iOS
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add a drag indicator for iOS
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambah Anggaran',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category Selection
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          categories.map((c) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  category = c['name'] as String;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      category == c['name']
                                          ? (c['color'] as Color).withValues(
                                            alpha: 51.0, // 0.2 * 255 = 51
                                          )
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      category == c['name']
                                          ? Border.all(
                                            color: c['color'] as Color,
                                          )
                                          : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      c['icon'] as IconData,
                                      color:
                                          category == c['name']
                                              ? c['color'] as Color
                                              : Colors.grey[600],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      c['name'] as String,
                                      style: TextStyle(
                                        color:
                                            category == c['name']
                                                ? c['color'] as Color
                                                : Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Jumlah Anggaran',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners for iOS
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true), // Better iOS keyboard
                      
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan jumlah';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Silakan masukkan angka yang valid';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        amount = double.parse(value!);
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            // Add budget logic - now using the amount variable
debugPrint('Menambahkan anggaran: $category - Rp ${amount.toStringAsFixed(0)}');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Anggaran berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Simpan Anggaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
