import 'api_service.dart';
import 'package:logger/logger.dart';

class CategoryService {
  final ApiService _apiService = ApiService();
  final _logger = Logger();

  // Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      _logger.d('Fetching categories from API');
      final response = await _apiService.get('categories');

      if (response == null) {
        _logger.w('Categories response is null');
        return [];
      }

      if (!response.containsKey('data')) {
        _logger.w('Categories response missing data field: $response');
        return [];
      }

      final data = response['data'];
      if (data == null) {
        _logger.w('Categories data is null');
        return [];
      }

      if (data is! List) {
        _logger.w('Categories data is not a list: $data');
        return [];
      }

      final categoriesList = List<Map<String, dynamic>>.from(data);

      // Periksa apakah setiap kategori memiliki id
      bool allCategoriesHaveIds = true;
      for (var category in categoriesList) {
        if (!category.containsKey('id') || category['id'] == null) {
          allCategoriesHaveIds = false;
          _logger.w('Found a category without an id: $category');
        }
      }

      if (!allCategoriesHaveIds) {
        _logger.w(
          'Some categories do not have valid IDs. This may cause issues.',
        );
      }

      _logger.d('Successfully fetched ${categoriesList.length} categories');
      return categoriesList;
    } catch (e) {
      _logger.e('Error fetching categories', error: e);
      return []; // Return empty list instead of crashing
    }
  }

  // Get categories by type (income/expense)
  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    try {
      final response = await _apiService.get('categories/type/$type');

      if (response == null || !response.containsKey('data')) {
        return [];
      }

      final data = response['data'];
      if (data == null || data is! List) {
        return [];
      }

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      _logger.e('Error fetching categories by type', error: e);
      return [];
    }
  }

  // Get category by ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    try {
      final response = await _apiService.get('categories/$id');

      if (response == null || !response.containsKey('data')) {
        return {};
      }

      final data = response['data'];
      if (data == null || data is! Map<String, dynamic>) {
        return {};
      }

      return data;
    } catch (e) {
      _logger.e('Error fetching category by id', error: e);
      return {};
    }
  }

  // Create new category
  Future<Map<String, dynamic>> createCategory(
    Map<String, dynamic> category,
  ) async {
    try {
      _logger.d('Creating category with data: $category');
      final response = await _apiService.post('categories', category);

      if (response == null || !response.containsKey('data')) {
        return {};
      }

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error creating category', error: e);
      rethrow; // Let the UI handle the error
    }
  }

  // Update category
  Future<Map<String, dynamic>> updateCategory(
    String id,
    Map<String, dynamic> category,
  ) async {
    try {
      final response = await _apiService.put('categories/$id', category);

      if (response == null || !response.containsKey('data')) {
        return {};
      }

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error updating category', error: e);
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      await _apiService.delete('categories/$id');
    } catch (e) {
      _logger.e('Error deleting category', error: e);
      rethrow;
    }
  }
}
