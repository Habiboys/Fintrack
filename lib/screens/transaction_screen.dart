import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';

class TransactionScreen extends StatefulWidget {
  // Fixed: Using super parameter for key
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );
  
  // Initialize logger
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize date formatting for Indonesian locale
    initializeDateFormatting('id_ID', null);
  }

  // Sample data - in a real app, this would come from your database
  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'Belanja Bahan Makanan',
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
    {
      'title': 'Makan Malam dengan Teman',
      'amount': 275000,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'isExpense': true,
      'category': 'Makanan',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'title': 'Proyek Freelance',
      'amount': 2500000,
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'isExpense': false,
      'category': 'Pendapatan',
      'icon': Icons.work,
      'color': Colors.green,
    },
    {
      'title': 'Tagihan Internet',
      'amount': 350000,
      'date': DateTime.now().subtract(const Duration(days: 12)),
      'isExpense': true,
      'category': 'Utilitas',
      'icon': Icons.wifi,
      'color': Colors.blue,
    },
    {
      'title': 'Transportasi',
      'amount': 125000,
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'isExpense': true,
      'category': 'Transportasi',
      'icon': Icons.directions_car,
      'color': Colors.purple,
    },
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(transactions),
          _buildTransactionList(
            transactions.where((t) => !t['isExpense']).toList(),
          ),
          _buildTransactionList(
            transactions.where((t) => t['isExpense']).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionModal(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Tidak ada transaksi ditemukan'));
    }

    // Group transactions by date
    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};

    for (var transaction in transactions) {
      final date = DateFormat('dd MMM yyyy', 'id_ID').format(transaction['date']);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final date = groupedTransactions.keys.elementAt(index);
        final dailyTransactions = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Fixed: Removed unnecessary toList() in spread
            ...dailyTransactions.map(
              (transaction) => _buildTransactionItem(context, transaction),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
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
            // Fixed: Converted int to double for alpha parameter
            color: Colors.grey.withValues(alpha: 26.0), // 0.1 * 255 = 26.0
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showTransactionDetails(context, transaction);
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Fixed: Replaced withOpacity with withValues
                color: transaction['color'].withValues(alpha: 51.0), // 0.2 * 255 = 51
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
                    transaction['category'],
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
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Transaksi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Fixed: Replaced withOpacity with withValues
                    color: transaction['color'].withValues(alpha: 51.0), // 0.2 * 255 = 51
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction['icon'],
                    color: transaction['color'],
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '${transaction['isExpense'] ? '-' : '+'} ${currencyFormatter.format(transaction['amount'])}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: transaction['isExpense'] ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildDetailItem('Judul', transaction['title']),
              _buildDetailItem('Kategori', transaction['category']),
              _buildDetailItem(
                'Tanggal',
                DateFormat('dd MMMM yyyy', 'id_ID').format(transaction['date']),
              ),
              _buildDetailItem(
                'Tipe',
                transaction['isExpense'] ? 'Pengeluaran' : 'Pemasukan',
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Edit transaction logic
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Delete transaction logic
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    double amount = 0;
    String category = 'Makanan';
    bool isExpense = true;

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
      {
        'name': 'Pendapatan',
        'icon': Icons.account_balance_wallet,
        'color': Colors.green,
      },
      {'name': 'Lainnya', 'icon': Icons.more_horiz, 'color': Colors.grey},
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
                        Text(
                          'Tambah ${isExpense ? 'Pengeluaran' : 'Pemasukan'}',
                          style: const TextStyle(
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

                    // Transaction Type Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    isExpense ? Colors.red : Colors.grey[200],
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Pengeluaran',
                                  style: TextStyle(
                                    color:
                                        isExpense
                                            ? Colors.white
                                            : Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = false;
                                category = 'Pendapatan';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    !isExpense
                                        ? Colors.green
                                        : Colors.grey[200],
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Pemasukan',
                                  style: TextStyle(
                                    color:
                                        !isExpense
                                            ? Colors.white
                                            : Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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

                    const SizedBox(height: 16),

                    // Title Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan judul';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        title = value!;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Category Selection
                    if (isExpense) ...[
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
                            categories
                                .where(
                                  (c) =>
                                      isExpense
                                          ? c['name'] != 'Pendapatan'
                                          : c['name'] == 'Pendapatan',
                                )
                                .map((c) {
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
                                        color: category == c['name']
                                            ? (c['color'] as Color).withValues(alpha: 51.0)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(16),
                                        border: category == c['name']
                                            ? Border.all(color: c['color'] as Color)
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
                                })
                                .toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            // Replace print with logger
                            logger.i('Menambahkan transaksi: $title - $category - Rp ${amount.toStringAsFixed(0)}');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaksi berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Simpan Transaksi'),
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
