import 'api_service.dart';
import 'package:logger/logger.dart';

class DashboardService {
  final ApiService _apiService = ApiService();
  final _logger = Logger();

  // Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiService.get('dashboard');
      _logger.d('Dashboard raw response: $response');
      return response as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error getting dashboard data', error: e);
      rethrow;
    }
  }

  // Get spending overview data
  Future<List<Map<String, dynamic>>> getSpendingOverview() async {
    try {
      final response = await _apiService.get('dashboard/spending-overview');
      _logger.d('Spending overview response: $response');

      // Penanganan berbagai kemungkinan format respons
      if (response['data'] is List) {
        // Format yang diharapkan: {data: [...array data spending...]}
        return List<Map<String, dynamic>>.from(response['data'] as List);
      } else if (response['data'] is Map) {
        // Format alternatif: {data: {items: [...array data spending...]}}
        final dataMap = response['data'] as Map<String, dynamic>;
        if (dataMap.containsKey('items') && dataMap['items'] is List) {
          return List<Map<String, dynamic>>.from(dataMap['items'] as List);
        }

        // Jika tidak ada 'items', mungkin langsung berisi data spending dalam bentuk Map
        // Kembalikan sebagai list dengan satu item
        return [Map<String, dynamic>.from(dataMap)];
      }

      // Jika format tidak dikenal, kembalikan list kosong
      _logger.w('Format spending overview tidak dikenal: $response');
      return [];
    } catch (e) {
      _logger.e('Error getting spending overview', error: e);
      // Jika terjadi error, kembalikan list kosong agar UI tetap bisa ditampilkan
      return [];
    }
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
