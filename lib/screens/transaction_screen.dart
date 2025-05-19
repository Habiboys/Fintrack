import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:fintrack/services/transaction_service.dart';
import 'package:fintrack/services/category_service.dart';
import 'package:fintrack/services/account_service.dart';
import 'package:fintrack/widgets/slidable_item.dart';
import 'package:fintrack/widgets/transaction_card.dart';
import 'package:fintrack/widgets/transaction_slidable.dart';
import 'package:fintrack/widgets/custom_input.dart';
import 'package:flutter/services.dart';

class TransactionScreen extends StatefulWidget {
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

  // Initialize services
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final AccountService _accountService = AccountService();
  final logger = Logger();

  // Data state
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> accounts = [];
  bool isLoading = true;
  String errorMessage = '';

  // State untuk form transaksi
  Map<String, dynamic> _selectedCategory = {};
  String _transactionType = 'expense';
  String _amount = '';
  String _description = '';
  DateTime _transactionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initializeDateFormatting('id_ID', null);
    _loadData(); // Load data saat inisialisasi
  }

  // Fungsi untuk memuat data transaksi, kategori, dan rekening
  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = '';
        });
      }

      // Muat kategori terlebih dahulu
      final categoriesData = await _categoryService.getCategories();
      if (mounted) {
        setState(() {
          categories = categoriesData;
        });
      }

      // Muat rekening
      try {
        final accountsData = await _accountService.getAccounts();
        if (mounted) {
          setState(() {
            accounts = accountsData;
          });
        }
      } catch (e) {
        logger.w('Tidak dapat memuat rekening: $e');
        // Lanjutkan meskipun rekening gagal dimuat
      }

      // Terakhir muat transaksi
      final transactionsData = await _transactionService.getTransactions();
      if (mounted) {
        setState(() {
          transactions = transactionsData;
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error loading data', error: e);
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  // Fungsi untuk membuat transaksi baru
  Future<void> _createTransaction(Map<String, dynamic> transactionData) async {
    try {
      // Pastikan data transaksi lengkap
      final dataToSend = {
        'amount': transactionData['amount'].toString(),
        'description': transactionData['description'],
        'category_id': transactionData['category_id'],
        'transaction_date': transactionData['date'],
        'transaction_type': transactionData['type'],
      };

      // Tambahkan account_id jika disediakan
      if (transactionData.containsKey('account_id') &&
          transactionData['account_id'] != null &&
          transactionData['account_id'].isNotEmpty) {
        dataToSend['account_id'] = transactionData['account_id'];
      }

      logger.d('Mengirim data transaksi: $dataToSend');

      // Kirim ke API
      await _transactionService.createTransaction(dataToSend);

      // Reload data setelah membuat transaksi baru
      await _loadData();

      // Tampilkan notifikasi sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
        );
      }
    } catch (e) {
      logger.e('Error creating transaction', error: e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat transaksi: $e')));
      }
    }
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      await _transactionService.deleteTransaction(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
      }
    } catch (e) {
      logger.e('Error deleting transaction', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            'Transaksi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        actions: [
          // Tombol akses cepat ke rekening
          IconButton(
            icon: Icon(
              Icons.account_balance_wallet,
              color: Theme.of(context).primaryColor,
            ),
            tooltip: 'Kelola Rekening',
            onPressed: () {
              Navigator.pushNamed(context, '/account').then((_) {
                // Muat ulang data ketika kembali dari halaman rekening
                if (mounted) {
                  _loadData();
                }
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Pemasukan'),
                Tab(text: 'Pengeluaran'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(transactions),
          _buildTransactionList(
            transactions
                .where((t) => t['transaction_type'] == 'income')
                .toList(),
          ),
          _buildTransactionList(
            transactions
                .where((t) => t['transaction_type'] == 'expense')
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dialog untuk menambah transaksi baru
  void _showAddTransactionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String amount = '';
    String description = '';
    String categoryId = '';
    String accountId = '';
    String transactionType = 'expense';
    DateTime selectedDate = DateTime.now();

    // Periksa apakah kategori sudah dimuat
    if (categories.isEmpty) {
      // Coba muat kategori sekali lagi
      _categoryService
          .getCategories()
          .then((categoriesData) {
            setState(() {
              categories = categoriesData;
              // Setelah memuat kategori, panggil dialog ini lagi
              if (categories.isNotEmpty) {
                _showAddTransactionDialog(context);
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
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memuat kategori: $error'),
                backgroundColor: Colors.red,
              ),
            );
          });
      return;
    }

    // Filter categories based on type
    List<Map<String, dynamic>> filteredCategories =
        categories.where((cat) => cat['type'] == transactionType).toList();

    // Pastikan ada kategori yang tersedia dan tetapkan ID default
    if (filteredCategories.isNotEmpty) {
      logger.d(
        'Ada ${filteredCategories.length} kategori tersedia: ${filteredCategories[0]}',
      );
      var firstCategory = filteredCategories[0];
      // Pastikan ID dikonversi ke string untuk dropdown
      categoryId = firstCategory['id'].toString();
      logger.d('Kategori default ID: $categoryId (${categoryId.runtimeType})');
    } else {
      logger.w('Tidak ada kategori untuk tipe: $transactionType');
      categoryId = '';
    }

    // Set default account jika tersedia
    if (accounts.isNotEmpty) {
      accountId = accounts[0]['id'].toString();
    }

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
              // Function to filter categories
              void filterCategoriesByType(String type) {
                setState(() {
                  transactionType = type;
                  filteredCategories =
                      categories.where((cat) => cat['type'] == type).toList();

                  if (filteredCategories.isNotEmpty) {
                    var firstCategory = filteredCategories[0];
                    categoryId = firstCategory['id'].toString();
                    logger.d('Kategori terpilih setelah filter: $categoryId');
                  } else {
                    categoryId = '';
                  }
                });
              }

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
                                      const Text(
                                        'Tambah Transaksi Baru',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Tipe Transaksi
                                  CustomSegmentedButton(
                                    options: const ['Pengeluaran', 'Pemasukan'],
                                    selectedIndex:
                                        transactionType == 'expense' ? 0 : 1,
                                    onChanged: (index) {
                                      filterCategoriesByType(
                                        index == 0 ? 'expense' : 'income',
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 24),

                                  // Jumlah
                                  CustomTextField(
                                    label: 'Jumlah',
                                    hint: 'Contoh: 50000',
                                    prefixText: 'Rp ',
                                    prefixIcon: Icons.monetization_on_outlined,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Jumlah tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      amount = value;
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 16),

                                  // Deskripsi
                                  CustomTextField(
                                    label: 'Deskripsi',
                                    hint: 'Contoh: Makan Siang',
                                    prefixIcon: Icons.description_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Deskripsi tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      description = value;
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 16),

                                  // Rekening (opsional)
                                  if (accounts.isNotEmpty)
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
                                            'Rekening',
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
                                            value: accountId,
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.grey[600],
                                            ),
                                            items:
                                                accounts.map((account) {
                                                  final acctId =
                                                      account['id'].toString();
                                                  final accountType =
                                                      account['type'] ?? 'cash';
                                                  IconData iconData;
                                                  Color iconColor;

                                                  // Set icon based on account type
                                                  switch (accountType) {
                                                    case 'bank':
                                                      iconData =
                                                          Icons.account_balance;
                                                      iconColor =
                                                          Colors.blue[700]!;
                                                      break;
                                                    case 'ewallet':
                                                      iconData =
                                                          Icons.smartphone;
                                                      iconColor =
                                                          Colors.purple[700]!;
                                                      break;
                                                    case 'cash':
                                                    default:
                                                      iconData = Icons.wallet;
                                                      iconColor =
                                                          Colors.green[700]!;
                                                  }

                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: acctId,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: iconColor
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
                                                            color: iconColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          account['name'],
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
                                                accountId = value!;
                                                logger.d(
                                                  'Rekening terpilih: $accountId',
                                                );
                                              });
                                            },
                                            dropdownColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    InkWell(
                                      onTap: () {
                                        // Arahkan ke halaman rekening
                                        Navigator.pushNamed(
                                          context,
                                          '/account',
                                        ).then((_) {
                                          // Muat ulang rekening saat kembali
                                          _loadData();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons
                                                    .add_circle_outline_rounded,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Tambahkan rekening untuk melacak saldo',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 16),

                                  // Tanggal Transaksi
                                  CustomDatePicker(
                                    label: 'Tanggal Transaksi',
                                    hint: 'Pilih tanggal',
                                    value: selectedDate,
                                    onChanged: (date) {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Kategori
                                  if (filteredCategories.isNotEmpty)
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
                                                filteredCategories.map((
                                                  category,
                                                ) {
                                                  // Pastikan ID dikonversi ke string
                                                  final catId =
                                                      category['id'].toString();
                                                  logger.d(
                                                    'Mapping category ID: ${category['id']} ke string: $catId',
                                                  );

                                                  final categoryColor = Color(
                                                    int.parse(
                                                          category['color']
                                                              .substring(1, 7),
                                                          radix: 16,
                                                        ) +
                                                        0xFF000000,
                                                  );

                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: catId,
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
                                                            IconData(
                                                              _getIconCode(
                                                                category['icon'],
                                                              ),
                                                              fontFamily:
                                                                  'MaterialIcons',
                                                            ),
                                                            color:
                                                                categoryColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          category['name'],
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
                                                categoryId = value!;
                                                logger.d(
                                                  'Kategori terpilih: $categoryId',
                                                );
                                              });
                                            },
                                            dropdownColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red[400],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          const Flexible(
                                            child: Text(
                                              'Tidak ada kategori untuk tipe transaksi ini. Silakan tambahkan kategori terlebih dahulu.',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  CustomButton(
                                    text: 'Simpan Transaksi',
                                    icon: Icons.check_circle_outline,
                                    onPressed:
                                        filteredCategories.isNotEmpty
                                            ? () {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                formKey.currentState!.save();

                                                // Format tanggal
                                                final formattedDate =
                                                    DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(selectedDate);

                                                // Buat data transaksi
                                                final transactionData = {
                                                  'amount': amount,
                                                  'description': description,
                                                  'category_id': categoryId,
                                                  'date': formattedDate,
                                                  'type': transactionType,
                                                };

                                                // Tambahkan account_id jika rekening dipilih
                                                if (accounts.isNotEmpty &&
                                                    accountId.isNotEmpty) {
                                                  transactionData['account_id'] =
                                                      accountId;
                                                }

                                                logger.d(
                                                  'Mengirim data transaksi: $transactionData',
                                                );

                                                // Tambah transaksi baru
                                                _createTransaction(
                                                  transactionData,
                                                );
                                                Navigator.pop(context);
                                              }
                                            }
                                            : null,
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
  }

  Widget _buildTransactionList(
    List<Map<String, dynamic>> filteredTransactions,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (filteredTransactions.isEmpty) {
      return const Center(child: Text('Belum ada transaksi'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];

        // Cari kategori yang sesuai untuk mendapatkan warna dan ikon
        final category = categories.firstWhere(
          (c) => c['id'] == transaction['category_id'],
          orElse:
              () => {
                'name': 'Lainnya',
                'color': '#CCCCCC',
                'icon': 'more_horiz',
              },
        );

        // Parse color dari string hex jika ada
        Color categoryColor = Colors.grey;
        if (category['color'] != null) {
          try {
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
          } catch (e) {
            logger.e('Error parsing color', error: e);
          }
        }

        // Dapatkan tanggal transaksi dalam format lokal
        String formattedDate = '';
        try {
          final transactionDate = DateTime.parse(
            transaction['transaction_date'] ?? DateTime.now().toIso8601String(),
          );
          formattedDate = DateFormat(
            'dd MMM yyyy',
            'id_ID',
          ).format(transactionDate);
        } catch (e) {
          formattedDate = 'Tanggal tidak valid';
        }

        return TransactionSlidable(
          deleteConfirmationText:
              'Apakah Anda yakin ingin menghapus transaksi "${transaction['description']}"?',
          transactionName: transaction['description'] ?? 'Transaksi',
          onDelete: () => _deleteTransaction(transaction['id'].toString()),
          child: TransactionCard(
            transaction: transaction,
            currencyFormatter: currencyFormatter,
            showCategory: true,
          ),
        );
      },
    );
  }

  // Helper untuk mendapatkan ikon dari string ikon
  IconData _getCategoryIcon(dynamic iconData) {
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
      'health_and_safety': Icons.health_and_safety,
      'school': Icons.school,
      'home': Icons.home,
    };

    return iconMap[iconData] ?? Icons.help_outline;
  }

  // Helper method untuk mengkonversi nilai amount ke numerik
  dynamic _getAmountValue(dynamic amount) {
    if (amount == null) return 0;
    if (amount is num) return amount;
    if (amount is String) {
      return double.tryParse(amount) ?? 0;
    }
    return 0;
  }

  // Fungsi untuk mendapatkan kode ikon dari string nama ikon
  int _getIconCode(String iconName) {
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
  }
}
