import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:fintrack/services/account_service.dart';
import 'package:fintrack/widgets/slidable_item.dart';
import 'package:fintrack/widgets/confirm_dialog.dart';
import 'package:fintrack/widgets/custom_input.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AccountService _accountService = AccountService();
  final logger = Logger();
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  List<Map<String, dynamic>> accounts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final accountsData = await _accountService.getAccounts();
      setState(() {
        accounts = accountsData;
        isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading accounts', error: e);
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat data rekening: $e';
      });
    }
  }

  void _showAddAccountDialog() {
    _showAccountFormDialog(null);
  }

  void _showEditAccountDialog(Map<String, dynamic> account) {
    _showAccountFormDialog(account);
  }

  void _showAccountFormDialog(Map<String, dynamic>? account) {
    final formKey = GlobalKey<FormState>();
    final isEditing = account != null;

    String name = isEditing ? account['name'] : '';
    String type = isEditing ? account['type'] : 'cash';
    String balance = isEditing ? account['balance'].toString() : '0';
    String currency = 'IDR'; // Selalu gunakan IDR sebagai mata uang default

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isEditing
                                      ? 'Edit Rekening'
                                      : 'Tambah Rekening Baru',
                                  style: const TextStyle(
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

                            // Nama Rekening
                            CustomTextField(
                              label: 'Nama Rekening',
                              hint: 'Contoh: BCA, Cash, Dompet',
                              prefixIcon: Icons.account_balance_wallet_outlined,
                              initialValue: name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama rekening tidak boleh kosong';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                name = value;
                              },
                              isRequired: true,
                            ),

                            const SizedBox(height: 16),

                            // Tipe Rekening
                            CustomDropdown<String>(
                              label: 'Tipe Rekening',
                              hint: 'Pilih tipe rekening',
                              value: type,
                              prefixIcon: Icons.category_outlined,
                              items: [
                                DropdownMenuItem(
                                  value: 'cash',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.wallet,
                                        color: Colors.green[700],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Tunai/Cash'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'bank',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance,
                                        color: Colors.blue[700],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Rekening Bank'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'ewallet',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.smartphone,
                                        color: Colors.purple[700],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('E-Wallet'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  type = value!;
                                });
                              },
                              isRequired: true,
                            ),

                            const SizedBox(height: 16),

                            // Saldo Awal
                            CustomTextField(
                              label: 'Saldo',
                              hint: 'Contoh: 1000000',
                              prefixText: 'Rp ',
                              prefixIcon: Icons.monetization_on_outlined,
                              initialValue: balance,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Saldo tidak boleh kosong';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Saldo harus berupa angka';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                balance = value;
                              },
                              isRequired: true,
                            ),

                            const SizedBox(height: 24),

                            CustomButton(
                              text:
                                  isEditing
                                      ? 'Perbarui Rekening'
                                      : 'Tambah Rekening',
                              icon:
                                  isEditing
                                      ? Icons.save
                                      : Icons.add_circle_outline,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();

                                  try {
                                    final accountData = {
                                      'name': name,
                                      'type': type,
                                      'balance': double.tryParse(balance) ?? 0,
                                      'currency': currency,
                                    };

                                    if (isEditing) {
                                      await _accountService.updateAccount(
                                        account['id'].toString(),
                                        accountData,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Rekening berhasil diperbarui',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      await _accountService.createAccount(
                                        accountData,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Rekening berhasil ditambahkan',
                                            ),
                                          ),
                                        );
                                      }
                                    }

                                    if (mounted) {
                                      Navigator.pop(context);
                                      _loadAccounts(); // Muat ulang daftar rekening
                                    }
                                  } catch (e) {
                                    logger.e('Error saving account', error: e);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Gagal menyimpan rekening: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
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
    );
  }

  Future<void> _deleteAccount(String id) async {
    try {
      await _accountService.deleteAccount(id);
      _loadAccounts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekening berhasil dihapus')),
        );
      }
    } catch (e) {
      logger.e('Error deleting account', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus rekening: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.wallet;
      case 'bank':
        return Icons.account_balance;
      case 'ewallet':
        return Icons.smartphone;
      default:
        return Icons.payment;
    }
  }

  Color _getAccountColor(String type) {
    switch (type) {
      case 'cash':
        return Colors.green[700]!;
      case 'bank':
        return Colors.blue[700]!;
      case 'ewallet':
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Rekening',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : accounts.isEmpty
              ? _buildEmptyState()
              : _buildAccountList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada rekening',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan rekening untuk melacak transaksi Anda',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Tambah Rekening',
            icon: Icons.add,
            onPressed: _showAddAccountDialog,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        final accountColor = _getAccountColor(account['type']);
        final accountIcon = _getAccountIcon(account['type']);

        return SlidableItem(
          deleteConfirmationText:
              'Apakah Anda yakin ingin menghapus rekening "${account['name']}"? Semua transaksi terkait dengan rekening ini akan tetap ada tetapi tidak terhubung ke rekening manapun.',
          itemName: account['name'],
          onDelete: () => _deleteAccount(account['id'].toString()),
          onEdit: () => _showEditAccountDialog(account),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accountColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(accountIcon, color: accountColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getAccountTypeName(account['type']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo Saat Ini',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(
                            account['balance'] is String
                                ? double.tryParse(account['balance']) ?? 0
                                : account['balance'],
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                _getBalanceValue(account['balance']) >= 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getAccountTypeName(String type) {
    switch (type) {
      case 'cash':
        return 'Tunai';
      case 'bank':
        return 'Rekening Bank';
      case 'ewallet':
        return 'E-Wallet';
      default:
        return 'Lainnya';
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Informasi Rekening'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cara mengakses halaman rekening:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('1. Melalui menu navigasi bawah dengan ikon dompet'),
                SizedBox(height: 4),
                Text('2. Melalui form tambah transaksi saat memilih rekening'),
                SizedBox(height: 12),
                Text(
                  'Fitur rekening memungkinkan Anda:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Melacak saldo di setiap rekening'),
                SizedBox(height: 4),
                Text('• Menyimpan riwayat transaksi per rekening'),
                SizedBox(height: 4),
                Text('• Memantau aliran uang masuk dan keluar'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  double _getBalanceValue(dynamic balance) {
    if (balance == null) return 0;
    if (balance is num) return balance.toDouble();
    if (balance is String) {
      return double.tryParse(balance) ?? 0;
    }
    return 0;
  }
}
