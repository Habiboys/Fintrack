import 'package:logger/logger.dart';
import 'api_service.dart';

class CurrencyService {
  final ApiService _apiService = ApiService();
  final _logger = Logger();

  // Daftar mata uang yang didukung
  static const Map<String, String> supportedCurrencies = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'JPY': 'Japanese Yen',
    'GBP': 'British Pound',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'SGD': 'Singapore Dollar',
    'MYR': 'Malaysian Ringgit',
    'THB': 'Thai Baht',
    'KRW': 'South Korean Won',
  };

  // Mendapatkan exchange rate dari IDR ke mata uang target
  Future<double> getExchangeRate(String targetCurrency) async {
    try {
      final response = await _apiService.get('currency/rate/$targetCurrency');

      if (response['success'] == true && response['data'] != null) {
        final rate = response['data']['rate'] as double;
        _logger.d('Exchange rate IDR to $targetCurrency: $rate');
        return rate;
      } else {
        throw Exception(response['message'] ?? 'Failed to get exchange rate');
      }
    } catch (e) {
      _logger.e('Error getting exchange rate', error: e);
      rethrow;
    }
  }

  // Melakukan konversi mata uang
  Future<Map<String, dynamic>> convertCurrency({
    required String accountId,
    required double amountInIDR,
    required String targetCurrency,
  }) async {
    try {
      final requestData = {
        'accountId': accountId,
        'amountInIDR': amountInIDR,
        'targetCurrency': targetCurrency,
      };

      final response = await _apiService.post('currency/convert', requestData);

      if (response['success'] == true && response['data'] != null) {
        _logger.d('Currency conversion completed: ${response['data']}');

        return {
          'success': true,
          'original_amount': response['data']['originalAmount'],
          'converted_amount': response['data']['convertedAmount'],
          'target_currency': response['data']['targetCurrency'],
          'exchange_rate': response['data']['exchangeRate'],
          'new_balance': response['data']['newBalance'],
          'account_name': response['data']['accountName'],
        };
      } else {
        throw Exception(response['message'] ?? 'Konversi gagal');
      }
    } catch (e) {
      _logger.e('Error converting currency', error: e);
      rethrow;
    }
  }

  // Mendapatkan daftar mata uang yang didukung
  Future<List<Map<String, String>>> getSupportedCurrencies() async {
    try {
      final response = await _apiService.get('currency/supported');

      if (response['success'] == true && response['data'] != null) {
        return List<Map<String, String>>.from(
          response['data'].map(
            (currency) => {
              'code': currency['code'].toString(),
              'name': currency['name'].toString(),
            },
          ),
        );
      } else {
        throw Exception(
          response['message'] ?? 'Failed to get supported currencies',
        );
      }
    } catch (e) {
      _logger.e('Error getting supported currencies', error: e);
      // Fallback ke data statis jika API gagal
      return supportedCurrencies.entries
          .map((entry) => {'code': entry.key, 'name': entry.value})
          .toList();
    }
  }

  // Format mata uang sesuai kode
  String formatCurrency(double amount, String currencyCode) {
    switch (currencyCode) {
      case 'USD':
      case 'AUD':
      case 'CAD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      case 'JPY':
      case 'KRW':
        return '¥${amount.toStringAsFixed(0)}';
      case 'CHF':
        return 'Fr ${amount.toStringAsFixed(2)}';
      case 'CNY':
        return '¥${amount.toStringAsFixed(2)}';
      case 'SGD':
        return 'S\$${amount.toStringAsFixed(2)}';
      case 'MYR':
        return 'RM ${amount.toStringAsFixed(2)}';
      case 'THB':
        return '฿${amount.toStringAsFixed(2)}';
      default:
        return '$currencyCode ${amount.toStringAsFixed(2)}';
    }
  }
}
