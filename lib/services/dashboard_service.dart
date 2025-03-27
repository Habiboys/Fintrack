import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();
  
  // Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _apiService.get('dashboard');
    return response as Map<String, dynamic>;
  }
  
  // Get spending overview data
  Future<List<Map<String, dynamic>>> getSpendingOverview() async {
    final response = await _apiService.get('dashboard/spending-overview');
    return List<Map<String, dynamic>>.from(response['data'] as List);
  }
  
  // Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary() async {
    final response = await _apiService.get('dashboard/monthly-summary');
    return response as Map<String, dynamic>;
  }
  
  // Get financial statistics
  Future<Map<String, dynamic>> getFinancialStats() async {
    final response = await _apiService.get('dashboard/stats');
    return response as Map<String, dynamic>;
  }
}

