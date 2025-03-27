import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  // Sample data - in a real app, this would come from your database
  final double totalBudget = 5000000;
  final double totalSpent = 3250000;

  final List<Map<String, dynamic>> budgetCategories = [
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'budget': 1500000,
      'spent': 1250000,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'color': Colors.purple,
      'budget': 800000,
      'spent': 650000,
    },
    {
      'name': 'Utilities',
      'icon': Icons.electric_bolt,
      'color': Colors.blue,
      'budget': 1000000,
      'spent': 800000,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
      'budget': 1200000,
      'spent': 400000,
    },
    {
      'name': 'Entertainment',
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
      appBar: AppBar(
        title: const Text(
          'Budget',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to budget history
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
              // Monthly Budget Overview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Monthly Budget',
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
                            'Remaining',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      progressColor:
                          remainingBudget < 0 ? Colors.red : Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBudgetSummaryItem(
                          'Total Budget',
                          currencyFormatter.format(totalBudget),
                        ),
                        _buildBudgetSummaryItem(
                          'Total Spent',
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
                    'Budget Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showAddBudgetModal(context);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Budget'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgetCategories.length,
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
                  color: Colors.amber.withOpacity(0.2),
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
                          'Budget Tip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try the 50/30/20 rule: Spend 50% of your income on needs, 30% on wants, and save 20%.',
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
        const SizedBox(height: 4),
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
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 20,
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
                      '${currencyFormatter.format(spent)} of ${currencyFormatter.format(budget)}',
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
              'Over budget by ${currencyFormatter.format(spent - budget)}',
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
    String category = 'Food';
    double amount = 0;

    final categories = [
      {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
      {
        'name': 'Transport',
        'icon': Icons.directions_car,
        'color': Colors.purple,
      },
      {'name': 'Utilities', 'icon': Icons.electric_bolt, 'color': Colors.blue},
      {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink},
      {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.red},
      {'name': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Budget',
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
                      'Category',
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
                                          ? (c['color'] as Color).withOpacity(
                                            0.2,
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
                      decoration: const InputDecoration(
                        labelText: 'Budget Amount',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
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
                            // Add budget logic
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Budget added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Budget'),
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
