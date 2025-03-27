import 'api_service.dart';

class BudgetService {
  final ApiService _apiService = ApiService();
  
  // Get all budgets
  Future<List<Map<String, dynamic>>> getBudgets() async {
    final response = await _apiService.get('budgets');
    return List<Map<String, dynamic>>.from(response['data'] as List);
  }
  
  // Get budget by ID
  Future<Map<String, dynamic>> getBudgetById(String id) async {
    final response = await _apiService.get('budgets/$id');
    return response['data'] as Map<String, dynamic>;
  }
  
  // Create new budget
  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> budget) async {
    final response = await _apiService.post('budgets', budget);
    return response['data'] as Map<String, dynamic>;
  }
  
  // Update budget
  Future<Map<String, dynamic>> updateBudget(String id, Map<String, dynamic> budget) async {
    final response = await _apiService.put('budgets/$id', budget);
    return response['data'] as Map<String, dynamic>;
  }
  
  // Delete budget
  Future<void> deleteBudget(String id) async {
    await _apiService.delete('budgets/$id');
  }
  
  // Get budget summary
  Future<Map<String, dynamic>> getBudgetSummary() async {
    final response = await _apiService.get('budgets/summary');
    return response as Map<String, dynamic>;
  }
}

