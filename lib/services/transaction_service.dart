import 'api_service.dart';

class TransactionService {
  final ApiService _apiService = ApiService();
  
  // Get all transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await _apiService.get('transactions');
    return List<Map<String, dynamic>>.from(response['data'] as List);
  }
  
  // Get transaction by ID
  Future<Map<String, dynamic>> getTransactionById(String id) async {
    final response = await _apiService.get('transactions/$id');
    return response['data'] as Map<String, dynamic>;
  }
  
  // Create new transaction
  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> transaction) async {
    final response = await _apiService.post('transactions', transaction);
    return response['data'] as Map<String, dynamic>;
  }
  
  // Update transaction
  Future<Map<String, dynamic>> updateTransaction(String id, Map<String, dynamic> transaction) async {
    final response = await _apiService.put('transactions/$id', transaction);
    return response['data'] as Map<String, dynamic>;
  }
  
  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _apiService.delete('transactions/$id');
  }
  
  // Get transactions by type (income/expense)
  Future<List<Map<String, dynamic>>> getTransactionsByType(bool isExpense) async {
    final type = isExpense ? 'expense' : 'income';
    final response = await _apiService.get('transactions/type/$type');
    return List<Map<String, dynamic>>.from(response['data'] as List);
  }
  
  // Get recent transactions
  Future<List<Map<String, dynamic>>> getRecentTransactions(int limit) async {
    final response = await _apiService.get('transactions/recent?limit=$limit');
    return List<Map<String, dynamic>>.from(response['data'] as List);
  }
}

