import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:fintrack/services/currency_service.dart';
import 'package:fintrack/services/account_service.dart';
import 'package:fintrack/widgets/custom_input.dart';
import 'package:fintrack/widgets/confirm_dialog.dart';

class CurrencyConversionScreen extends StatefulWidget {
  const CurrencyConversionScreen({super.key});

  @override
  State<CurrencyConversionScreen> createState() =>
      _CurrencyConversionScreenState();
}

class _CurrencyConversionScreenState extends State<CurrencyConversionScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final AccountService _accountService = AccountService();
  final _logger = Logger();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();

  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, String>> _currencies = [];

  String? _selectedAccountId;
  String? _selectedCurrency;
  double _exchangeRate = 0;
  double _convertedAmount = 0;
  bool _isLoading = true;
  bool _isConverting = false;
  bool _showResult = false;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isLoading = true);

      // Load accounts dan currencies
      final accountsData = await _accountService.getAccounts();
      final currenciesData = await _currencyService.getSupportedCurrencies();

      setState(() {
        _accounts = accountsData;
        _currencies = currenciesData;
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Error loading data', error: e);
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal memuat data: $e');
    }
  }

  Future<void> _calculateConversion() async {
    if (_selectedCurrency == null || _amountController.text.isEmpty) return;

    try {
      final amount = double.tryParse(
        _amountController.text.replaceAll(',', ''),
      );
      if (amount == null || amount <= 0) return;

      // Get exchange rate
      final rate = await _currencyService.getExchangeRate(_selectedCurrency!);
      final converted = amount * rate;

      setState(() {
        _exchangeRate = rate;
        _convertedAmount = converted;
        _showResult = true;
      });
    } catch (e) {
      _logger.e('Error calculating conversion', error: e);
      _showErrorSnackBar('Gagal menghitung konversi: $e');
    }
  }

  Future<void> _performConversion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedCurrency == null) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    // Tampilkan dialog konfirmasi
    await ConfirmDialog.show(
      context: context,
      title: 'Konfirmasi Konversi',
      content:
          'Apakah Anda yakin ingin mengkonversi ${currencyFormatter.format(amount)} '
          'ke ${_currencyService.formatCurrency(_convertedAmount, _selectedCurrency!)}?\n\n'
          'Saldo rekening akan berkurang sejumlah ${currencyFormatter.format(amount)}.',
      confirmText: 'Konversi',
      confirmColor: Theme.of(context).primaryColor,
      onConfirm: () => _executeConversion(amount),
    );
  }

  Future<void> _executeConversion(double amount) async {
    try {
      setState(() => _isConverting = true);

      final result = await _currencyService.convertCurrency(
        accountId: _selectedAccountId!,
        amountInIDR: amount,
        targetCurrency: _selectedCurrency!,
      );

      setState(() => _isConverting = false);

      // Tampilkan hasil sukses
      _showSuccessDialog(result);

      // Reset form
      _resetForm();
    } catch (e) {
      setState(() => _isConverting = false);
      _logger.e('Error performing conversion', error: e);
      _showErrorSnackBar('Konversi gagal: $e');
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Konversi Berhasil'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow(
                  'Jumlah Dikonversi',
                  currencyFormatter.format(result['original_amount']),
                ),
                _buildResultRow(
                  'Hasil Konversi',
                  _currencyService.formatCurrency(
                    result['converted_amount'],
                    result['target_currency'],
                  ),
                ),
                _buildResultRow(
                  'Kurs',
                  '1 IDR = ${result['exchange_rate'].toStringAsFixed(6)} ${result['target_currency']}',
                ),
                _buildResultRow(
                  'Saldo Tersisa',
                  currencyFormatter.format(result['new_balance']),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Riwayat konversi telah tersimpan di halaman Transaksi',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Kembali ke ProfileScreen
                },
                child: Text('Lihat Riwayat'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _amountController.clear();
      _selectedAccountId = null;
      _selectedCurrency = null;
      _exchangeRate = 0;
      _convertedAmount = 0;
      _showResult = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper function untuk safely convert balance
  double _getBalanceValue(dynamic balance) {
    if (balance is num) {
      return balance.toDouble();
    } else if (balance is String) {
      return double.tryParse(balance) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Konversi Mata Uang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      SizedBox(height: 24),
                      _buildFormCard(),
                      if (_showResult) ...[
                        SizedBox(height: 24),
                        _buildResultCard(),
                      ],
                      SizedBox(height: 32),
                      _buildConversionButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
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
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.currency_exchange, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Konversi Mata Uang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Tukar Rupiah Anda ke mata uang internasional dengan mudah',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Konversi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          // Pilih Rekening
          CustomDropdown<String>(
            label: 'Pilih Rekening',
            hint: 'Pilih rekening sumber dana',
            value: _selectedAccountId,
            prefixIcon: Icons.account_balance_wallet,
            items:
                _accounts.map((account) {
                  return DropdownMenuItem<String>(
                    value: account['id'].toString(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              account['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: Text(
                              currencyFormatter.format(
                                _getBalanceValue(account['balance']),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedAccountId = value);
            },
            validator: (value) {
              if (value == null) return 'Pilih rekening terlebih dahulu';
              return null;
            },
            isRequired: true,
          ),

          SizedBox(height: 16),

          // Jumlah Rupiah
          CustomTextField(
            label: 'Jumlah (IDR)',
            hint: 'Masukkan jumlah dalam Rupiah',
            prefixIcon: Icons.money,
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              TextInputFormatter.withFunction((oldValue, newValue) {
                if (newValue.text.isEmpty) return newValue;
                final number = int.tryParse(newValue.text);
                if (number == null) return oldValue;
                final formatted = NumberFormat('#,###').format(number);
                return newValue.copyWith(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan jumlah yang akan dikonversi';
              }
              final amount = double.tryParse(value.replaceAll(',', ''));
              if (amount == null || amount <= 0) {
                return 'Masukkan jumlah yang valid';
              }
              if (_selectedAccountId != null) {
                final account = _accounts.firstWhere(
                  (acc) => acc['id'].toString() == _selectedAccountId,
                );
                if (amount > _getBalanceValue(account['balance'])) {
                  return 'Jumlah melebihi saldo rekening';
                }
              }
              return null;
            },
            onChanged: (value) => _calculateConversion(),
            isRequired: true,
          ),

          SizedBox(height: 16),

          // Pilih Mata Uang Target
          CustomDropdown<String>(
            label: 'Mata Uang Target',
            hint: 'Pilih mata uang tujuan',
            value: _selectedCurrency,
            prefixIcon: Icons.language,
            items:
                _currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency['code'],
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              currency['code']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(currency['name']!)),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedCurrency = value);
              _calculateConversion();
            },
            validator: (value) {
              if (value == null) return 'Pilih mata uang target';
              return null;
            },
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Colors.blue[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Hasil Konversi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kurs Saat Ini:', style: TextStyle(color: Colors.grey[600])),
              Text(
                '1 IDR = ${_exchangeRate.toStringAsFixed(6)} $_selectedCurrency',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anda akan menerima:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                _currencyService.formatCurrency(
                  _convertedAmount,
                  _selectedCurrency!,
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConversionButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: _isConverting || !_showResult ? null : _performConversion,
        child:
            _isConverting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Memproses...'),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_horiz),
                    SizedBox(width: 8),
                    Text(
                      'Konversi Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
