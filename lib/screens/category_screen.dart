import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fintrack/services/category_service.dart';
import 'package:fintrack/widgets/slidable_item.dart';
import 'package:fintrack/widgets/confirm_dialog.dart';
import 'package:fintrack/widgets/custom_input.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  final CategoryService _categoryService = CategoryService();
  late TabController _tabController;

  // State data
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeDateFormatting('id_ID', null);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat kategori
  Future<void> _loadCategories() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = '';
        });
      }

      final categoriesData = await _categoryService.getCategories();

      if (mounted) {
        setState(() {
          categories = categoriesData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat kategori: $e';
        });
      }
    }
  }

  // Fungsi untuk membuat kategori baru
  Future<void> _createCategory(Map<String, dynamic> categoryData) async {
    try {
      await _categoryService.createCategory(categoryData);
      if (mounted) {
        await _loadCategories();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat kategori: $e')));
      }
    }
  }

  // Fungsi untuk memperbarui kategori
  Future<void> _updateCategory(
    String id,
    Map<String, dynamic> categoryData,
  ) async {
    try {
      await _categoryService.updateCategory(id, categoryData);
      if (mounted) {
        await _loadCategories();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui kategori: $e')),
        );
      }
    }
  }

  // Fungsi untuk menghapus kategori
  Future<void> _deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      if (mounted) {
        await _loadCategories();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus kategori: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Kategori',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [Tab(text: 'Pengeluaran'), Tab(text: 'Pemasukan')],
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryList('expense'),
                  _buildCategoryList('income'),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    final filteredCategories =
        categories.where((c) => c['type'] == type).toList();

    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'expense'
                  ? Icons.shopping_cart_outlined
                  : Icons.account_balance_wallet_outlined,
              size: 70,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              type == 'expense'
                  ? 'Belum ada kategori pengeluaran'
                  : 'Belum ada kategori pemasukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan kategori untuk melacak keuangan Anda',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];

        // Parse warna kategori
        Color categoryColor = Colors.grey;
        try {
          if (category['color'] is String &&
              (category['color'] as String).startsWith('#')) {
            categoryColor = Color(
              int.parse(
                    (category['color'] as String).substring(1, 7),
                    radix: 16,
                  ) +
                  0xFF000000,
            );
          }
        } catch (e) {
          // Fallback ke warna default
        }

        final categoryName = category['name'] ?? 'Tanpa nama';
        final categoryId = category['id']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SlidableItem(
            itemName: categoryName,
            deleteConfirmationText:
                'Yakin ingin menghapus kategori "$categoryName"?',
            onDelete: () => _deleteCategory(categoryId),
            onEdit: () => _showEditCategoryDialog(context, category),
            child: Container(
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
                      child: Icon(
                        _getCategoryIcon(category['icon']),
                        color: categoryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Detail kategori
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type == 'expense'
                                ? 'Kategori Pengeluaran'
                                : 'Kategori Pemasukan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialog untuk menambah kategori baru
  void _showAddCategoryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String type = 'expense';
    String color = '#FF6B6B';
    String icon = 'shopping_bag';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle untuk drag
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 16, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Tambah Kategori Baru',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Nama Kategori
                                  CustomTextField(
                                    label: 'Nama Kategori',
                                    hint: 'Contoh: Makan dan Minum',
                                    prefixIcon: Icons.label_outline,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nama kategori tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      name = value.trim();
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 16),

                                  // Tipe Kategori
                                  CustomDropdown<String>(
                                    label: 'Tipe Kategori',
                                    hint: 'Pilih tipe kategori',
                                    value: type,
                                    prefixIcon: Icons.category_outlined,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'expense',
                                        child: Text('Pengeluaran'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'income',
                                        child: Text('Pemasukan'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        type = value!;
                                      });
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 16),

                                  // Warna Kategori
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CustomDropdown<String>(
                                          label: 'Warna',
                                          hint: 'Pilih warna',
                                          value: color,
                                          prefixIcon: Icons.color_lens_outlined,
                                          items: [
                                            _buildColorDropdownItem(
                                              '#FF6B6B',
                                              'Merah',
                                            ),
                                            _buildColorDropdownItem(
                                              '#4ECDC4',
                                              'Tosca',
                                            ),
                                            _buildColorDropdownItem(
                                              '#FFD166',
                                              'Kuning',
                                            ),
                                            _buildColorDropdownItem(
                                              '#118AB2',
                                              'Biru',
                                            ),
                                            _buildColorDropdownItem(
                                              '#6A0572',
                                              'Ungu',
                                            ),
                                            _buildColorDropdownItem(
                                              '#52B788',
                                              'Hijau',
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              color = value!;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 32.0,
                                        ),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              int.parse(
                                                    color.substring(1, 7),
                                                    radix: 16,
                                                  ) +
                                                  0xFF000000,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Ikon Kategori
                                  CustomDropdown<String>(
                                    label: 'Ikon',
                                    hint: 'Pilih ikon',
                                    value: icon,
                                    prefixIcon: Icons.emoji_objects_outlined,
                                    items: [
                                      _buildIconDropdownItem(
                                        'shopping_bag',
                                        'Belanja',
                                      ),
                                      _buildIconDropdownItem(
                                        'restaurant',
                                        'Makanan',
                                      ),
                                      _buildIconDropdownItem(
                                        'directions_car',
                                        'Transportasi',
                                      ),
                                      _buildIconDropdownItem('home', 'Rumah'),
                                      _buildIconDropdownItem(
                                        'medical_services',
                                        'Kesehatan',
                                      ),
                                      _buildIconDropdownItem(
                                        'school',
                                        'Pendidikan',
                                      ),
                                      _buildIconDropdownItem(
                                        'sports_esports',
                                        'Hiburan',
                                      ),
                                      _buildIconDropdownItem(
                                        'account_balance_wallet',
                                        'Gaji',
                                      ),
                                      _buildIconDropdownItem(
                                        'card_giftcard',
                                        'Hadiah',
                                      ),
                                      _buildIconDropdownItem(
                                        'more_horiz',
                                        'Lainnya',
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        icon = value!;
                                      });
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 24),

                                  CustomButton(
                                    text: 'Simpan Kategori',
                                    icon: Icons.check_circle_outline,
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        formKey.currentState!.save();

                                        // Buat data kategori
                                        final categoryData = {
                                          'name': name,
                                          'type': type,
                                          'color': color,
                                          'icon': icon,
                                        };

                                        // Tambah kategori baru
                                        _createCategory(categoryData);
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Dialog untuk mengedit kategori
  void _showEditCategoryDialog(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final formKey = GlobalKey<FormState>();
    String name = category['name'] ?? '';
    String type = category['type'] ?? 'expense';
    String color = category['color'] ?? '#FF6B6B';
    String icon = category['icon'] ?? 'shopping_bag';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle untuk drag
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 16, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Edit Kategori',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Nama Kategori
                                  CustomTextField(
                                    label: 'Nama Kategori',
                                    hint: 'Contoh: Makan dan Minum',
                                    prefixIcon: Icons.label_outline,
                                    initialValue: name,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nama kategori tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      name = value.trim();
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 16),

                                  // Tipe Kategori
                                  CustomDropdown<String>(
                                    label: 'Tipe Kategori',
                                    hint: 'Pilih tipe kategori',
                                    value: type,
                                    prefixIcon: Icons.category_outlined,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'expense',
                                        child: Text('Pengeluaran'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'income',
                                        child: Text('Pemasukan'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        type = value!;
                                      });
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 16),

                                  // Warna Kategori
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CustomDropdown<String>(
                                          label: 'Warna',
                                          hint: 'Pilih warna',
                                          value: color,
                                          prefixIcon: Icons.color_lens_outlined,
                                          items: [
                                            _buildColorDropdownItem(
                                              '#FF6B6B',
                                              'Merah',
                                            ),
                                            _buildColorDropdownItem(
                                              '#4ECDC4',
                                              'Tosca',
                                            ),
                                            _buildColorDropdownItem(
                                              '#FFD166',
                                              'Kuning',
                                            ),
                                            _buildColorDropdownItem(
                                              '#118AB2',
                                              'Biru',
                                            ),
                                            _buildColorDropdownItem(
                                              '#6A0572',
                                              'Ungu',
                                            ),
                                            _buildColorDropdownItem(
                                              '#52B788',
                                              'Hijau',
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              color = value!;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 32.0,
                                        ),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              int.parse(
                                                    color.substring(1, 7),
                                                    radix: 16,
                                                  ) +
                                                  0xFF000000,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Ikon Kategori
                                  CustomDropdown<String>(
                                    label: 'Ikon',
                                    hint: 'Pilih ikon',
                                    value: icon,
                                    prefixIcon: Icons.emoji_objects_outlined,
                                    items: [
                                      _buildIconDropdownItem(
                                        'shopping_bag',
                                        'Belanja',
                                      ),
                                      _buildIconDropdownItem(
                                        'restaurant',
                                        'Makanan',
                                      ),
                                      _buildIconDropdownItem(
                                        'directions_car',
                                        'Transportasi',
                                      ),
                                      _buildIconDropdownItem('home', 'Rumah'),
                                      _buildIconDropdownItem(
                                        'medical_services',
                                        'Kesehatan',
                                      ),
                                      _buildIconDropdownItem(
                                        'school',
                                        'Pendidikan',
                                      ),
                                      _buildIconDropdownItem(
                                        'sports_esports',
                                        'Hiburan',
                                      ),
                                      _buildIconDropdownItem(
                                        'account_balance_wallet',
                                        'Gaji',
                                      ),
                                      _buildIconDropdownItem(
                                        'card_giftcard',
                                        'Hadiah',
                                      ),
                                      _buildIconDropdownItem(
                                        'more_horiz',
                                        'Lainnya',
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        icon = value!;
                                      });
                                    },
                                    isRequired: true,
                                  ),

                                  const SizedBox(height: 24),

                                  CustomButton(
                                    text: 'Simpan Perubahan',
                                    icon: Icons.check_circle_outline,
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        formKey.currentState!.save();

                                        // Buat data kategori
                                        final categoryData = {
                                          'name': name,
                                          'type': type,
                                          'color': color,
                                          'icon': icon,
                                        };

                                        // Update kategori
                                        _updateCategory(
                                          category['id'].toString(),
                                          categoryData,
                                        );
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // Helper untuk membuat item dropdown warna
  DropdownMenuItem<String> _buildColorDropdownItem(String value, String label) {
    Color color = Color(
      int.parse(value.substring(1, 7), radix: 16) + 0xFF000000,
    );
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  // Helper untuk membuat item dropdown ikon
  DropdownMenuItem<String> _buildIconDropdownItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(_getCategoryIcon(value)),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  // Helper untuk mendapatkan ikon dari string ikon
  IconData _getCategoryIcon(dynamic iconData) {
    if (iconData is IconData) return iconData;

    // Map string ikon ke IconData
    final iconMap = {
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
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'home': Icons.home,
    };

    return iconMap[iconData] ?? Icons.help_outline;
  }
}
