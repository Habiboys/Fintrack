import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final bool showCategory;
  final bool showDate;
  final Function? onTap;
  final NumberFormat currencyFormatter;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.showCategory = true,
    this.showDate = true,
    this.onTap,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    // Dapatkan data yang diperlukan dari transaksi
    final String title = transaction['description'] ?? 'Tidak ada deskripsi';
    final String categoryName =
        transaction['category']?['name'] ??
        transaction['Category']?['name'] ??
        'Tidak terkategori';

    // Dapatkan warna kategori
    Color categoryColor = Colors.grey;
    if (transaction.containsKey('color') && transaction['color'] is Color) {
      categoryColor = transaction['color'];
    } else if (transaction.containsKey('category') &&
        transaction['category'] is Map &&
        transaction['category'].containsKey('color')) {
      final colorString = transaction['category']['color'];
      if (colorString is String && colorString.startsWith('#')) {
        try {
          categoryColor = Color(
            int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000,
          );
        } catch (e) {
          // Fallback ke warna default
        }
      }
    } else if (transaction.containsKey('Category') &&
        transaction['Category'] is Map &&
        transaction['Category'].containsKey('color')) {
      final colorString = transaction['Category']['color'];
      if (colorString is String && colorString.startsWith('#')) {
        try {
          categoryColor = Color(
            int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000,
          );
        } catch (e) {
          // Fallback ke warna default
        }
      }
    } else {
      // Default berdasarkan tipe transaksi
      bool isExpense =
          transaction['transaction_type'] == 'expense' ||
          transaction['isExpense'] == true;
      categoryColor = isExpense ? Colors.red : Colors.green;
    }

    // Dapatkan ikon
    IconData categoryIcon = Icons.category;
    if (transaction.containsKey('icon') && transaction['icon'] is IconData) {
      categoryIcon = transaction['icon'];
    } else {
      final iconString =
          transaction['category']?['icon'] ??
          transaction['Category']?['icon'] ??
          'category';
      categoryIcon = _getCategoryIcon(iconString);
    }

    // Format tanggal
    String formattedDate = '';
    try {
      final DateTime transactionDate;
      if (transaction.containsKey('date') && transaction['date'] is DateTime) {
        transactionDate = transaction['date'];
      } else if (transaction.containsKey('transaction_date')) {
        transactionDate = DateTime.parse(transaction['transaction_date']);
      } else {
        transactionDate = DateTime.now();
      }
      formattedDate = DateFormat(
        'dd MMM yyyy',
        'id_ID',
      ).format(transactionDate);
    } catch (e) {
      formattedDate = 'Tanggal tidak valid';
    }

    // Format jumlah
    final dynamic amount = transaction['amount'] ?? 0;
    final double numericAmount = _parseAmount(amount);
    final bool isExpense =
        transaction['transaction_type'] == 'expense' ||
        transaction['isExpense'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap != null ? () => onTap!() : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ikon kategori
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
                ),
                const SizedBox(width: 16),

                // Detail transaksi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showCategory) ...[
                        const SizedBox(height: 4),
                        Text(
                          categoryName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (showDate) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Jumlah transaksi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isExpense
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${isExpense ? '-' : '+'} ${currencyFormatter.format(numericAmount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk parsing amount
  double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is num) return amount.toDouble();
    if (amount is String) {
      final cleanAmount = amount.replaceAll(RegExp(r'[^0-9.]'), '');
      try {
        return double.parse(cleanAmount);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Helper untuk mendapatkan ikon dari string
  IconData _getCategoryIcon(dynamic iconName) {
    if (iconName is IconData) return iconName;

    final Map<String, IconData> iconMap = {
      'restaurant': Icons.restaurant,
      'fastfood': Icons.fastfood,
      'directions_car': Icons.directions_car,
      'train': Icons.train,
      'electric_bolt': Icons.electric_bolt,
      'shower': Icons.shower,
      'shopping_bag': Icons.shopping_bag,
      'shopping_cart': Icons.shopping_cart,
      'movie': Icons.movie,
      'sports_esports': Icons.sports_esports,
      'account_balance_wallet': Icons.account_balance_wallet,
      'attach_money': Icons.attach_money,
      'card_giftcard': Icons.card_giftcard,
      'more_horiz': Icons.more_horiz,
      'health_and_safety': Icons.health_and_safety,
      'school': Icons.school,
      'home': Icons.home,
      'category': Icons.category,
    };

    if (iconName is String && iconMap.containsKey(iconName)) {
      return iconMap[iconName]!;
    }

    return Icons.help_outline;
  }
}
