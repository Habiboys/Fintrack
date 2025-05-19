import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:fintrack/services/budget_service.dart';
import 'package:fintrack/services/category_service.dart';
import 'dart:developer' as developer;
import 'package:fintrack/widgets/slidable_item.dart';
import 'package:fintrack/widgets/confirm_dialog.dart';
import 'package:fintrack/widgets/transaction_card.dart';
import 'package:fintrack/widgets/custom_input.dart';
import 'package:flutter/services.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // Initialize services
  final BudgetService _budgetService = BudgetService();
  final CategoryService _categoryService = CategoryService();

  // Currency formatter
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Data state
  List<Map<String, dynamic>> budgets = [];
  List<Map<String, dynamic>> categories = [];
  double totalBudget = 0;
  double totalSpent = 0;
  bool isLoading = true;
  String errorMessage = '';

  // Sample budget categories for UI demo
  final List<Map<String, dynamic>> budgetCategories = [
    {
      'name': 'Makanan',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'budget': 2000000,
      'spent': 1500000,
    },
    {
      'name': 'Transportasi',
      'icon': Icons.directions_car,
      'color': Colors.purple,
      'budget': 1000000,
      'spent': 800000,
    },
    {
      'name': 'Utilitas',
      'icon': Icons.electric_bolt,
      'color': Colors.blue,
      'budget': 800000,
      'spent': 750000,
    },
    {
      'name': 'Belanja',
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
      'budget': 1500000,
      'spent': 1800000,
    },
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadData(); // Load data when initialized
  }

  // Function to load budget and category data
  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = '';
        });
      }

      developer.log('Memuat data kategori dan anggaran', name: 'BudgetScreen');

      // Load categories first
      try {
        final categoriesResult = await _categoryService.getCategories();
        if (mounted) {
          setState(() {
            categories = categoriesResult;
          });
        }
        developer.log(
          'Berhasil memuat ${categories.length} kategori',
          name: 'BudgetScreen',
        );
      } catch (e) {
        developer.log(
          'Error saat memuat kategori: $e',
          name: 'BudgetScreen',
          error: e,
        );
        // Continue loading budgets even if categories failed
      }

      // Then load budgets summary
      try {
        final budgetSummary = await _budgetService.getBudgetSummary();
        developer.log(
          'Berhasil mendapatkan budget summary',
          name: 'BudgetScreen',
        );

        if (mounted) {
          setState(() {
            // Pastikan data budgets ada sebelum mencoba mengakses
            final budgetsData = budgetSummary['data']?['budgets'];
            if (budgetsData == null) {
              developer.log(
                'Data budget tidak ditemukan dalam response',
                name: 'BudgetScreen',
              );
              budgets = [];
            } else {
              try {
                budgets = List<Map<String, dynamic>>.from(budgetsData as List);
                developer.log(
                  'Berhasil memuat ${budgets.length} anggaran',
                  name: 'BudgetScreen',
                );
              } catch (e) {
                developer.log(
                  'Error saat konversi data budget: $e',
                  name: 'BudgetScreen',
                  error: e,
                );
                budgets = [];
              }
            }

            // Calculate total budget and spent dengan pengecekan tipe data yang ketat
            totalBudget = 0.0;
            totalSpent = 0.0;

            for (var budget in budgets) {
              try {
                // Parse amount
                double amount = 0.0;
                if (budget.containsKey('amount') && budget['amount'] != null) {
                  final amountStr = budget['amount'].toString();
                  amount = double.tryParse(amountStr) ?? 0.0;
                  totalBudget += amount;
                }

                // Parse spent
                double spent = 0.0;
                if (budget.containsKey('spent') && budget['spent'] != null) {
                  final spentStr = budget['spent'].toString();
                  spent = double.tryParse(spentStr) ?? 0.0;
                  totalSpent += spent;
                }

                developer.log(
                  'Budget: ${budget['name']}, Amount: $amount, Spent: $spent',
                  name: 'BudgetScreen',
                );
              } catch (e) {
                developer.log(
                  'Error menghitung budget: $e',
                  name: 'BudgetScreen',
                  error: e,
                );
              }
            }

            isLoading = false;
          });
        }
      } catch (e) {
        developer.log(
          'Error saat memuat data budget: $e',
          name: 'BudgetScreen',
          error: e,
        );
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Gagal memuat data anggaran: $e';
          });
        }
      }
    } catch (e) {
      developer.log(
        'Error umum saat _loadData: $e',
        name: 'BudgetScreen',
        error: e,
      );
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  // Function to create a new budget
  Future<void> _createBudget(Map<String, dynamic> budgetData) async {
    try {
      // Format data untuk API
      if (budgetData.containsKey('amount')) {
        budgetData['amount'] = budgetData['amount'].toString();
      }

      // Tambahkan field period yang tidak boleh null
      // Default-nya 'monthly' karena kebanyakan anggaran bulanan
      if (!budgetData.containsKey('period')) {
        budgetData['period'] = 'monthly';
      }

      developer.log(
        'Mengirim data budget ke API: $budgetData',
        name: 'BudgetScreen',
      );
      await _budgetService.createBudget(budgetData);
      // Reload data after creating a new budget
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil ditambahkan')),
        );
      }
    } catch (e) {
      developer.log(
        'Error saat membuat anggaran: $e',
        name: 'BudgetScreen',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat anggaran: $e')));
      }
    }
  }

  // Function to delete a budget
  Future<void> _deleteBudget(String id) async {
    try {
      developer.log('Menghapus anggaran dengan ID: $id', name: 'BudgetScreen');
      await _budgetService.deleteBudget(id);

      // Reload data setelah menghapus anggaran
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil dihapus')),
        );
      }
    } catch (e) {
      developer.log(
        'Error saat menghapus anggaran: $e',
        name: 'BudgetScreen',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus anggaran: $e')));
      }
    }
  }

  // Function to update a budget
  Future<void> _updateBudget(String id, Map<String, dynamic> budgetData) async {
    try {
      developer.log('Mengupdate anggaran dengan ID: $id', name: 'BudgetScreen');
      await _budgetService.updateBudget(id, budgetData);

      // Reload data setelah mengupdate anggaran
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggaran berhasil diperbarui')),
        );
      }
    } catch (e) {
      developer.log(
        'Error saat mengupdate anggaran: $e',
        name: 'BudgetScreen',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui anggaran: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalBudget - totalSpent;
    final budgetProgress = totalBudget > 0 ? totalSpent / totalBudget : 0;

    // Periksa apakah kategori sudah dimuat
    bool canAddBudget = true;
    try {
      final hasExpenseCategories =
          categories
              .where((cat) => cat['type'] == 'expense' && cat['id'] != null)
              .isNotEmpty;
      canAddBudget = hasExpenseCategories;
    } catch (e) {
      developer.log(
        'Error checking categories: $e',
        name: 'BudgetScreen',
        error: e,
      );
      canAddBudget = false;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Anggaran',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          developer.log('FloatingActionButton ditekan', name: 'BudgetScreen');
          if (canAddBudget) {
            _showAddBudgetDialog(context);
          } else {
            developer.log(
              'Tidak dapat menambah anggaran: tidak ada kategori pengeluaran',
              name: 'BudgetScreen',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Anda harus menambahkan minimal satu kategori pengeluaran terlebih dahulu',
                ),
                backgroundColor: Colors.red,
              ),
            );
            // Navigate to category screen
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushNamed(context, '/category');
              }
            });
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
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
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Anggaran Bulanan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CircularPercentIndicator(
                              radius: 80.0,
                              lineWidth: 12.0,
                              percent:
                                  budgetProgress > 1.0
                                      ? 1.0
                                      : budgetProgress.toDouble(),
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
                                  remainingBudget < 0
                                      ? Colors.red
                                      : Colors.greenAccent,
                              backgroundColor: Colors.white.withOpacity(0.2),
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
                        children: const [
                          Text(
                            'Kategori Anggaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      budgets.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Belum ada anggaran yang dibuat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: budgets.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final budget = budgets[index];
                              // Cari kategori yang sesuai dengan budget
                              final category = categories.firstWhere(
                                (c) => c['id'] == budget['category_id'],
                                orElse:
                                    () => {
                                      'name': 'Tidak ditemukan',
                                      'color': '#CCCCCC',
                                      'icon': 'more_horiz',
                                    },
                              );
                              return _buildBudgetCategoryItem(
                                context,
                                budget,
                                category,
                              );
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
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  'Tips Anggaran',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
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
    Map<String, dynamic> budget,
    Map<String, dynamic> category,
  ) {
    // Parsing nilai numerik dengan safety
    double spent = 0.0;
    double budgetAmount = 0.0;

    try {
      if (budget['spent'] != null) {
        spent = double.tryParse(budget['spent'].toString()) ?? 0.0;
      }

      if (budget['amount'] != null) {
        budgetAmount = double.tryParse(budget['amount'].toString()) ?? 0.0;
      }
    } catch (e) {
      developer.log(
        'Error parsing budget values: $e',
        name: 'BudgetScreen',
        error: e,
      );
    }

    final double progress = budgetAmount > 0 ? spent / budgetAmount : 0;
    final bool isOverBudget = spent > budgetAmount;

    // Parse warna kategori
    Color categoryColor = Colors.grey;
    try {
      if (category.containsKey('color') && category['color'] != null) {
        if (category['color'] is String &&
            (category['color'] as String).startsWith('#')) {
          categoryColor = Color(
            int.parse(
                  (category['color'] as String).substring(1, 7),
                  radix: 16,
                ) +
                0xFF000000,
          );
        } else if (category['color'] is Color) {
          categoryColor = category['color'] as Color;
        }
      }
    } catch (e) {
      // Fallback ke warna default
      developer.log(
        'Error parsing category color: $e',
        name: 'BudgetScreen',
        error: e,
      );
    }

    // Get icon with proper error handling
    IconData iconData = Icons.help_outline;
    try {
      iconData = _getCategoryIcon(category['icon']);
    } catch (e) {
      developer.log(
        'Error getting category icon: $e',
        name: 'BudgetScreen',
        error: e,
      );
    }

    final budgetId = budget['id']?.toString() ?? '';
    final budgetName = budget['name'] ?? 'Anggaran Tanpa Nama';
    final String categoryName = category['name'] ?? 'Kategori Tidak Diketahui';

    return SlidableItem(
      itemName: budgetName,
      deleteConfirmationText: 'Yakin ingin menghapus anggaran "$budgetName"?',
      onDelete: () => _deleteBudget(budgetId),
      onEdit: () => _showAddBudgetDialog(context, budget: budget),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: categoryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currencyFormatter.format(spent)} dari ${currencyFormatter.format(budgetAmount)}',
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
                    color: isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: progress > 1.0 ? 1.0 : progress,
              progressColor: isOverBudget ? Colors.red : Colors.green,
              backgroundColor: Colors.grey[200],
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
            ),
            if (isOverBudget) ...[
              const SizedBox(height: 8),
              Text(
                'Melebihi anggaran sebesar ${currencyFormatter.format(spent - budgetAmount)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper untuk mendapatkan ikon dari string ikon
  IconData _getCategoryIcon(dynamic iconData) {
    try {
      // Handle null atau empty string
      if (iconData == null || (iconData is String && iconData.isEmpty)) {
        developer.log(
          'Icon tidak ditemukan atau kosong, menggunakan ikon default',
          name: 'BudgetScreen',
        );
        return Icons.help_outline;
      }

      if (iconData is IconData) return iconData;

      // Map string ikon ke IconData
      final iconMap = {
        'restaurant': Icons.restaurant,
        'fastfood': Icons.fastfood,
        'directions_car': Icons.directions_car,
        'train': Icons.train,
        'electric_bolt': Icons.electric_bolt,
        'shower': Icons.shower,
        'shopping_bag': Icons.shopping_bag,
        'shopping_cart': Icons.shopping_cart,
        'movie': Icons.movie,
        'sports_esports': Icons.sports_esports,
        'account_balance_wallet': Icons.account_balance_wallet,
        'attach_money': Icons.attach_money,
        'card_giftcard': Icons.card_giftcard,
        'more_horiz': Icons.more_horiz,
        'help_outline': Icons.help_outline,
        'health_and_safety': Icons.health_and_safety,
        'medical_services': Icons.medical_services,
        'school': Icons.school,
        'home': Icons.home,
        'category': Icons.category,
      };

      // Convert iconData to string if necessary
      final iconString = iconData.toString();
      final icon = iconMap[iconString] ?? Icons.help_outline;

      if (!iconMap.containsKey(iconString)) {
        developer.log(
          'Icon "$iconString" tidak ditemukan dalam map, menggunakan default',
          name: 'BudgetScreen',
        );
      }

      return icon;
    } catch (e) {
      developer.log(
        'Error pada _getCategoryIcon: $e',
        name: 'BudgetScreen',
        error: e,
      );
      return Icons.help_outline;
    }
  }

  // Dialog untuk menambah anggaran baru
  void _showAddBudgetDialog(
    BuildContext context, {
    Map<String, dynamic>? budget,
  }) {
    developer.log('_showAddBudgetDialog dipanggil', name: 'BudgetScreen');

    final formKey = GlobalKey<FormState>();
    String name = budget?['name'] ?? '';
    String amount = budget?['amount']?.toString() ?? '';
    String categoryId = budget?['category_id']?.toString() ?? '';
    String period =
        budget?['period'] ?? 'monthly'; // Default period adalah bulanan
    DateTime startDate =
        budget != null && budget['start_date'] != null
            ? DateTime.parse(budget['start_date'].toString())
            : DateTime.now();
    DateTime endDate =
        budget != null && budget['end_date'] != null
            ? DateTime.parse(budget['end_date'].toString())
            : DateTime.now().add(const Duration(days: 30));

    // Debug kategori yang tersedia
    developer.log(
      'Jumlah kategori tersedia: ${categories.length}',
      name: 'BudgetScreen',
    );

    // Periksa apakah kategori sudah dimuat
    if (categories.isEmpty) {
      developer.log(
        'Kategori kosong, mencoba memuat ulang',
        name: 'BudgetScreen',
      );
      // Coba muat kategori sekali lagi
      try {
        _categoryService
            .getCategories()
            .then((categoriesData) {
              developer.log(
                'Berhasil memuat ${categoriesData.length} kategori',
                name: 'BudgetScreen',
              );
              if (mounted) {
                setState(() {
                  categories = categoriesData;

                  // Setelah memuat kategori, panggil dialog ini lagi
                  if (categories.isNotEmpty) {
                    _showAddBudgetDialog(context, budget: budget);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Anda harus menambahkan minimal satu kategori terlebih dahulu',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Navigate to category screen
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        Navigator.pushNamed(context, '/category');
                      }
                    });
                  }
                });
              }
            })
            .catchError((error) {
              developer.log(
                'Error saat memuat kategori: $error',
                name: 'BudgetScreen',
                error: error,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memuat kategori: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            });
      } catch (e) {
        developer.log(
          'Error saat memuat kategori: $e',
          name: 'BudgetScreen',
          error: e,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat kategori: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Kategori pengeluaran saja yang boleh memiliki anggaran
    List<Map<String, dynamic>> expenseCategories = [];
    try {
      // Filter kategori dan pastikan semua kategori valid dengan id
      expenseCategories =
          categories
              .where(
                (cat) =>
                    cat['type'] == 'expense' &&
                    cat['id'] != null &&
                    cat['id'].toString().isNotEmpty,
              )
              .toList();

      developer.log(
        'Jumlah kategori pengeluaran: ${expenseCategories.length}',
        name: 'BudgetScreen',
      );
      for (var cat in expenseCategories) {
        developer.log(
          'Kategori: ${cat['name']}, ID: ${cat['id']}, Type: ${cat['type']}',
          name: 'BudgetScreen',
        );
      }
    } catch (e) {
      developer.log(
        'Error saat memfilter kategori: $e',
        name: 'BudgetScreen',
        error: e,
      );
      expenseCategories = [];
    }

    if (expenseCategories.isEmpty) {
      developer.log('Tidak ada kategori pengeluaran', name: 'BudgetScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anda harus menambahkan minimal satu kategori pengeluaran terlebih dahulu',
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Navigate to category screen
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushNamed(context, '/category');
        }
      });
      return;
    }

    // Set default kategori dengan pengecekan null-safety
    try {
      if (expenseCategories.isNotEmpty &&
          expenseCategories[0].containsKey('id') &&
          expenseCategories[0]['id'] != null) {
        categoryId = expenseCategories[0]['id'].toString();
        developer.log('Default categoryId: $categoryId', name: 'BudgetScreen');
      } else {
        throw Exception('Kategori yang dipilih tidak memiliki ID valid');
      }
    } catch (e) {
      developer.log(
        'Error saat mengambil id kategori: $e',
        name: 'BudgetScreen',
        error: e,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    developer.log('Menampilkan modal bottom sheet', name: 'BudgetScreen');

    // Pastikan context masih valid
    if (!mounted) {
      developer.log(
        'Context tidak valid (widget sudah tidak di-mount)',
        name: 'BudgetScreen',
      );
      return;
    }

    Future.microtask(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder:
            (context) => StatefulBuilder(
              builder: (context, setState) {
                developer.log(
                  'Building bottom sheet dialog',
                  name: 'BudgetScreen',
                );
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle untuk drag
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 16, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          budget != null
                                              ? 'Edit Anggaran'
                                              : 'Tambah Anggaran Baru',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed:
                                              () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Nama Anggaran
                                    CustomTextField(
                                      label: 'Nama Anggaran',
                                      hint: 'Contoh: Belanja Bulanan',
                                      prefixIcon: Icons.note_alt_outlined,
                                      initialValue: name,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nama anggaran tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        name = value;
                                      },
                                      isRequired: true,
                                    ),

                                    const SizedBox(height: 16),

                                    // Jumlah Anggaran
                                    CustomTextField(
                                      label: 'Jumlah Anggaran',
                                      hint: 'Contoh: 1000000',
                                      prefixText: 'Rp ',
                                      prefixIcon:
                                          Icons.monetization_on_outlined,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      initialValue: amount,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Jumlah anggaran tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        amount = value;
                                      },
                                      isRequired: true,
                                    ),

                                    const SizedBox(height: 16),

                                    // Kategori
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4.0,
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Kategori',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              Text(
                                                ' *',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: DropdownButtonFormField<
                                            String
                                          >(
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                            value: categoryId,
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.grey[600],
                                            ),
                                            items:
                                                expenseCategories.map((
                                                  category,
                                                ) {
                                                  Color categoryColor =
                                                      Colors.grey;

                                                  try {
                                                    if (category['color'] !=
                                                            null &&
                                                        category['color']
                                                            is String &&
                                                        (category['color']
                                                                as String)
                                                            .startsWith('#')) {
                                                      categoryColor = Color(
                                                        int.parse(
                                                              category['color']
                                                                  .substring(
                                                                    1,
                                                                    7,
                                                                  ),
                                                              radix: 16,
                                                            ) +
                                                            0xFF000000,
                                                      );
                                                    }
                                                  } catch (e) {
                                                    print(
                                                      'Error saat parsing warna: $e',
                                                    );
                                                    // Tetap gunakan warna default
                                                  }

                                                  // Default icon jika terjadi error
                                                  IconData iconData =
                                                      Icons.category;
                                                  try {
                                                    if (category['icon'] !=
                                                        null) {
                                                      final code = _getIconCode(
                                                        category['icon']
                                                            .toString(),
                                                      );
                                                      iconData = IconData(
                                                        code,
                                                        fontFamily:
                                                            'MaterialIcons',
                                                      );
                                                    }
                                                  } catch (e) {
                                                    print(
                                                      'Error saat parsing icon: $e',
                                                    );
                                                    // Tetap gunakan icon default
                                                  }

                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value:
                                                        category['id']
                                                            .toString(),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: categoryColor
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            iconData,
                                                            color:
                                                                categoryColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          category['name'] ??
                                                              'Tidak ada nama',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey[800],
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                if (value != null) {
                                                  categoryId = value;
                                                }
                                              });
                                            },
                                            dropdownColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Periode Anggaran
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4.0,
                                            bottom: 8.0,
                                          ),
                                          child: Text(
                                            'Periode Anggaran',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: DropdownButtonFormField<
                                            String
                                          >(
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                            value: period,
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.grey[600],
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'daily',
                                                child: Text('Harian'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'weekly',
                                                child: Text('Mingguan'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'monthly',
                                                child: Text('Bulanan'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'yearly',
                                                child: Text('Tahunan'),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                if (value != null) {
                                                  period = value;
                                                }
                                              });
                                            },
                                            dropdownColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Tanggal Mulai
                                    CustomDatePicker(
                                      label: 'Tanggal Mulai',
                                      hint: 'Pilih tanggal mulai',
                                      value: startDate,
                                      onChanged: (date) {
                                        setState(() {
                                          startDate = date;
                                          // If end date is before start date, update it
                                          if (endDate.isBefore(startDate)) {
                                            endDate = startDate.add(
                                              const Duration(days: 30),
                                            );
                                          }
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Tanggal Selesai
                                    CustomDatePicker(
                                      label: 'Tanggal Selesai',
                                      hint: 'Pilih tanggal selesai',
                                      value: endDate,
                                      onChanged: (date) {
                                        setState(() {
                                          endDate = date;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    CustomButton(
                                      text:
                                          budget != null
                                              ? 'Perbarui Anggaran'
                                              : 'Simpan Anggaran',
                                      icon: Icons.check_circle_outline,
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          formKey.currentState!.save();

                                          // Format tanggal
                                          final formattedStartDate = DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(startDate);
                                          final formattedEndDate = DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(endDate);

                                          // Buat data anggaran
                                          final budgetData = {
                                            'name': name,
                                            'amount': amount,
                                            'category_id': categoryId,
                                            'period': period,
                                            'start_date': formattedStartDate,
                                            'end_date': formattedEndDate,
                                          };

                                          developer.log(
                                            'Data anggaran yang akan dikirim: $budgetData',
                                            name: 'BudgetScreen',
                                          );

                                          // Update atau tambah anggaran baru
                                          if (budget != null &&
                                              budget['id'] != null) {
                                            // Update anggaran yang sudah ada
                                            _updateBudget(
                                              budget['id'].toString(),
                                              budgetData,
                                            );
                                          } else {
                                            // Tambah anggaran baru
                                            _createBudget(budgetData);
                                          }
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      );
    });
  }

  // Fungsi untuk mendapatkan kode ikon dari string nama ikon
  int _getIconCode(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.category.codePoint;
    }

    try {
      Map<String, int> iconCodes = {
        'shopping_bag': Icons.shopping_bag.codePoint,
        'restaurant': Icons.restaurant.codePoint,
        'directions_car': Icons.directions_car.codePoint,
        'home': Icons.home.codePoint,
        'medical_services': Icons.medical_services.codePoint,
        'school': Icons.school.codePoint,
        'sports_esports': Icons.sports_esports.codePoint,
        'account_balance_wallet': Icons.account_balance_wallet.codePoint,
        'card_giftcard': Icons.card_giftcard.codePoint,
        'more_horiz': Icons.more_horiz.codePoint,
        // Default fallback
        'default': Icons.category.codePoint,
      };

      return iconCodes[iconName] ?? iconCodes['default']!;
    } catch (e) {
      print('Error saat mendapatkan kode ikon: $e');
      return Icons.category.codePoint;
    }
  }
}
