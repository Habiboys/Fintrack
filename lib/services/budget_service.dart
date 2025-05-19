import 'api_service.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class BudgetService {
  final ApiService _apiService = ApiService();
  final _logger = Logger();

  // Get all budgets
  Future<List<Map<String, dynamic>>> getBudgets() async {
    try {
      final response = await _apiService.get('budgets');
      return List<Map<String, dynamic>>.from(response['data'] as List);
    } catch (e) {
      _logger.e('Error fetching budgets', error: e);
      return [];
    }
  }

  // Get budget by ID
  Future<Map<String, dynamic>> getBudgetById(String id) async {
    try {
      final response = await _apiService.get('budgets/$id');
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error fetching budget by id', error: e);
      return {};
    }
  }

  // Create new budget
  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> budget) async {
    try {
      // Pastikan amount dikirim sebagai string
      if (budget.containsKey('amount')) {
        final amount = budget['amount'];
        // Jika amount bukan string, konversi ke string
        if (amount is! String) {
          budget['amount'] = amount.toString();
        }
      }

      _logger.d('Creating budget with data: $budget');
      final response = await _apiService.post('budgets', budget);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error creating budget', error: e);
      rethrow; // Throw kembali untuk ditangani oleh pemanggil
    }
  }

  // Update budget
  Future<Map<String, dynamic>> updateBudget(
    String id,
    Map<String, dynamic> budget,
  ) async {
    try {
      // Pastikan amount dikirim sebagai string
      if (budget.containsKey('amount')) {
        final amount = budget['amount'];
        if (amount is! String) {
          budget['amount'] = amount.toString();
        }
      }

      final response = await _apiService.put('budgets/$id', budget);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error updating budget', error: e);
      rethrow;
    }
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    try {
      await _apiService.delete('budgets/$id');
    } catch (e) {
      _logger.e('Error deleting budget', error: e);
      rethrow;
    }
  }

  // Get budget summary
  Future<Map<String, dynamic>> getBudgetSummary() async {
    try {
      _logger.d('Meminta budget summary dari API');
      final response = await _apiService.get('budgets/summary');

      // Jika respons null, kembalikan map kosong
      if (response == null) {
        _logger.w('Budget summary response is null');
        return {
          'data': {'budgets': []},
        };
      }

      // Log respons mentah untuk debugging
      _logger.d('Raw response: $response');

      // Jika respons bukan Map, konversi ke format yang diharapkan
      if (response is! Map<String, dynamic>) {
        _logger.w('Budget summary response is not a map: $response');
        if (response is List) {
          _logger.d('Response is a list, converting to expected format');
          return {
            'data': {'budgets': response},
          };
        }
        return {
          'data': {'budgets': []},
        };
      }

      // Jika data adalah array langsung (bukan object dengan key budgets)
      if (response.containsKey('data') && response['data'] is List) {
        _logger.d('Data berupa array langsung, mengonversi ke format budgets');
        final List<dynamic> dataList = response['data'] as List;
        return {
          'data': {'budgets': dataList},
        };
      }

      // Jika data budgets tidak ada, tambahkan key kosong
      if (!response.containsKey('data')) {
        _logger.w('Response tidak berisi key "data"');
        response['data'] = {'budgets': []};
      } else if (response['data'] is Map<String, dynamic> &&
          !response['data'].containsKey('budgets')) {
        _logger.w('Response["data"] tidak berisi key "budgets"');
        response['data']['budgets'] = [];
      }

      // Log detail untuk debugging
      _logger.d('Budget summary response structure: ${json.encode(response)}');

      // Buat salinan untuk diproses
      final processedResponse = Map<String, dynamic>.from(response);

      // Pastikan data dalam format yang konsisten
      if (!processedResponse.containsKey('data')) {
        _logger.d('Adding missing data key to response');
        processedResponse['data'] = {'budgets': []};
      } else if (processedResponse['data'] is! Map) {
        // Jika data bukan map, konversi ke format yang benar
        _logger.d('Data is not a map, converting to expected format');
        final originalData = processedResponse['data'];
        if (originalData is List) {
          processedResponse['data'] = {'budgets': originalData};
        } else {
          processedResponse['data'] = {'budgets': []};
        }
      } else if (!(processedResponse['data'] as Map).containsKey('budgets')) {
        // Jika data tidak memiliki key budgets, tambahkan
        _logger.d('Adding missing budgets key to data');
        (processedResponse['data'] as Map<String, dynamic>)['budgets'] = [];
      }

      // Pastikan data budgets adalah List
      var budgetsData = processedResponse['data']['budgets'];
      if (budgetsData == null) {
        _logger.d('budgets is null, setting to empty list');
        processedResponse['data']['budgets'] = [];
        return processedResponse;
      }

      if (budgetsData is! List) {
        _logger.w('budgets is not a list: ${budgetsData.runtimeType}');
        processedResponse['data']['budgets'] = [];
        return processedResponse;
      }

      // Proses data budget untuk memastikan semua field ada dan valid
      try {
        List<dynamic> budgetsList = processedResponse['data']['budgets'];
        List<Map<String, dynamic>> processedBudgets = [];

        _logger.d('Processing ${budgetsList.length} budgets');

        for (var index = 0; index < budgetsList.length; index++) {
          var budget = budgetsList[index];

          _logger.d('Processing budget at index $index: $budget');

          if (budget is Map) {
            // Convert Map to Map<String, dynamic> explicitly
            final Map<String, dynamic> budgetMap = Map<String, dynamic>.from(
              budget,
            );

            // Pastikan semua field penting ada dan dalam format yang benar
            var processedBudget = {
              ...budgetMap,
              'amount': budgetMap['amount']?.toString() ?? '0',
              'spent': budgetMap['spent']?.toString() ?? '0',
              'category_id': budgetMap['category_id']?.toString() ?? null,
              'name': budgetMap['name'] ?? 'Anggaran Tanpa Nama',
            };

            processedBudgets.add(processedBudget);
          } else {
            _logger.w('Budget item is not a map: ${budget?.runtimeType}');
          }
        }

        _logger.d('Processed ${processedBudgets.length} valid budgets');

        processedResponse['data']['budgets'] = processedBudgets;
      } catch (e) {
        _logger.e('Error processing budgets data', error: e);
        // Jika terjadi error saat memproses, kembalikan list kosong untuk menghindari crash
        processedResponse['data']['budgets'] = [];
      }

      return processedResponse;
    } catch (e) {
      _logger.e('Error fetching budget summary', error: e);
      // Kembalikan struktur data default jika terjadi error
      return {
        'data': {'budgets': []},
      };
    }
  }
}
