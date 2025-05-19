import 'api_service.dart';
import 'package:logger/logger.dart';

class TransactionService {
  final ApiService _apiService = ApiService();
  final logger = Logger();

  // Get all transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await _apiService.get('transactions');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      logger.e('Error fetching transactions', error: e);
      return [];
    }
  }

  // Get transaction by ID
  Future<Map<String, dynamic>> getTransactionById(String id) async {
    try {
      final response = await _apiService.get('transactions/$id');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      logger.e('Error fetching transaction by id', error: e);
      return {};
    }
  }

  // Create new transaction - memastikan format data sesuai dengan API backend
  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> transaction,
  ) async {
    try {
      // Pastikan parameter yang diperlukan tersedia
      if (!transaction.containsKey('category_id') ||
          !transaction.containsKey('amount') ||
          !transaction.containsKey('description') ||
          !transaction.containsKey('transaction_date') ||
          !transaction.containsKey('transaction_type')) {
        throw Exception('Data transaksi tidak lengkap');
      }

      // Pastikan amount diformat dengan benar
      if (transaction.containsKey('amount')) {
        final amount = transaction['amount'];
        // Jika amount adalah string, coba konversi ke numerik
        if (amount is String) {
          final numericAmount = double.tryParse(amount);
          if (numericAmount != null) {
            transaction['amount'] = numericAmount;
          } else {
            transaction['amount'] = 0; // Default jika konversi gagal
          }
        }
        // Pastikan amount selalu numerik
        if (!(transaction['amount'] is num)) {
          transaction['amount'] = 0;
        }
      }

      // Pastikan category_id adalah integer
      if (transaction['category_id'] is String) {
        final categoryId = int.tryParse(transaction['category_id']);
        transaction['category_id'] = categoryId ?? 0;
      }

      // Pastikan account_id adalah integer jika ada
      if (transaction.containsKey('account_id') &&
          transaction['account_id'] is String) {
        final accountId = int.tryParse(transaction['account_id']);
        if (accountId != null) {
          transaction['account_id'] = accountId;
        } else {
          // Jika konversi gagal, hapus account_id dari request
          transaction.remove('account_id');
        }
      }

      logger.d('Mengirim transaksi ke API: $transaction');

      final response = await _apiService.post('transactions', transaction);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      logger.e('Error creating transaction', error: e);
      rethrow; // Throw kembali untuk ditangani oleh pemanggil
    }
  }

  // Update transaction
  Future<Map<String, dynamic>> updateTransaction(
    String id,
    Map<String, dynamic> transaction,
  ) async {
    try {
      // Pastikan amount dalam format yang benar
      if (transaction.containsKey('amount')) {
        final amount = transaction['amount'];
        if (amount is String) {
          transaction['amount'] = double.tryParse(amount) ?? 0;
        }
        if (!(transaction['amount'] is num)) {
          transaction['amount'] = 0;
        }
      }

      // Pastikan category_id adalah integer jika ada
      if (transaction.containsKey('category_id') &&
          transaction['category_id'] is String) {
        transaction['category_id'] =
            int.tryParse(transaction['category_id']) ?? 0;
      }

      // Pastikan account_id adalah integer jika ada
      if (transaction.containsKey('account_id') &&
          transaction['account_id'] is String) {
        final accountId = int.tryParse(transaction['account_id']);
        if (accountId != null) {
          transaction['account_id'] = accountId;
        } else {
          transaction.remove('account_id');
        }
      }

      final response = await _apiService.put('transactions/$id', transaction);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      logger.e('Error updating transaction', error: e);
      rethrow;
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _apiService.delete('transactions/$id');
    } catch (e) {
      logger.e('Error deleting transaction', error: e);
      rethrow;
    }
  }

  // Get transactions by type (income/expense)
  Future<List<Map<String, dynamic>>> getTransactionsByType(
    bool isExpense,
  ) async {
    try {
      final type = isExpense ? 'expense' : 'income';
      final response = await _apiService.get('transactions/type/$type');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      logger.e('Error fetching transactions by type', error: e);
      return [];
    }
  }

  // Get recent transactions
  Future<List<Map<String, dynamic>>> getRecentTransactions(int limit) async {
    try {
      final response = await _apiService.get(
        'transactions/recent?limit=$limit',
      );
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      logger.e('Error fetching recent transactions', error: e);
      return [];
    }
  }
}
