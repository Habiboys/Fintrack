import 'api_service.dart';
import 'package:logger/logger.dart';

class AccountService {
  final ApiService _apiService = ApiService();
  final _logger = Logger();

  // Get all accounts
  Future<List<Map<String, dynamic>>> getAccounts() async {
    try {
      final response = await _apiService.get('accounts');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      _logger.e('Error getting accounts', error: e);
      return [];
    }
  }

  // Get account by ID
  Future<Map<String, dynamic>> getAccountById(String id) async {
    try {
      final response = await _apiService.get('accounts/$id');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error getting account by ID', error: e);
      return {};
    }
  }

  // Create new account
  Future<Map<String, dynamic>> createAccount(
    Map<String, dynamic> account,
  ) async {
    try {
      // Pastikan balance dalam format yang benar
      if (account.containsKey('balance')) {
        final balance = account['balance'];
        // Konversi ke numerik jika string
        if (balance is String) {
          account['balance'] = double.tryParse(balance) ?? 0;
        }
        // Pastikan balance selalu numerik
        if (!(account['balance'] is num)) {
          account['balance'] = 0;
        }
      }

      _logger.d('Creating account with data: $account');
      final response = await _apiService.post('accounts', account);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error creating account', error: e);
      rethrow;
    }
  }

  // Update account
  Future<Map<String, dynamic>> updateAccount(
    String id,
    Map<String, dynamic> account,
  ) async {
    try {
      // Pastikan balance dalam format yang benar
      if (account.containsKey('balance')) {
        final balance = account['balance'];
        // Konversi ke numerik jika string
        if (balance is String) {
          account['balance'] = double.tryParse(balance) ?? 0;
        }
        // Pastikan balance selalu numerik
        if (!(account['balance'] is num)) {
          account['balance'] = 0;
        }
      }

      _logger.d('Updating account $id with data: $account');
      final response = await _apiService.put('accounts/$id', account);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error updating account', error: e);
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount(String id) async {
    try {
      await _apiService.delete('accounts/$id');
    } catch (e) {
      _logger.e('Error deleting account', error: e);
      rethrow;
    }
  }
}
