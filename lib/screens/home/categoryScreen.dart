import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance/models/category.dart';
import 'package:finance/services/categoryService.dart';
import 'package:finance/widgets/categoryForm.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories', 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              // Show sorting options
              _showSortOptions(context, categoryProvider);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: categoryProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await categoryProvider.fetchCategories();
                },
                child: categoryProvider.categories.isEmpty
                    ? _buildEmptyState(context)
                    : _buildCategoryList(context, categoryProvider),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: Icon(Icons.add),
        label: Text('New Category'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No categories found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create categories to organize your transactions',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: Icon(Icons.add),
            label: Text('Add your first category'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, CategoryProvider categoryProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView.builder(
        itemCount: categoryProvider.categories.length,
        itemBuilder: (context, index) {
          final category = categoryProvider.categories[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: category.color, width: 2),
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: category.color,
                ),
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Tap to view transactions',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit',
                    onPressed: () => _showEditCategoryDialog(context, category),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteCategoryDialog(context, category),
                  ),
                ],
              ),
              onTap: () {
                // Navigate to category details/transactions
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing ${category.name} transactions')),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method to choose an icon based on category name
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('food') || name.contains('grocery') || name.contains('restaurant'))
      return Icons.restaurant;
    else if (name.contains('transport') || name.contains('car') || name.contains('travel'))
      return Icons.directions_car;
    else if (name.contains('bill') || name.contains('utility'))
      return Icons.receipt;
    else if (name.contains('entertainment') || name.contains('movie'))
      return Icons.movie;
    else if (name.contains('shopping'))
      return Icons.shopping_bag;
    else if (name.contains('health') || name.contains('medical'))
      return Icons.medical_services;
    else if (name.contains('education'))
      return Icons.school;
    else if (name.contains('income') || name.contains('salary'))
      return Icons.attach_money;
    else
      return Icons.category;
  }

  void _showSortOptions(BuildContext context, CategoryProvider categoryProvider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Sort Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.sort_by_alpha),
              title: Text('Name (A-Z)'),
              onTap: () {
                // Sort by name
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.sort_by_alpha, textDirection: TextDirection.rtl),
              title: Text('Name (Z-A)'),
              onTap: () {
                // Sort by name descending
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Recently Added'),
              onTap: () {
                // Sort by date
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: CategoryForm(),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: CategoryForm(category: category),
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, category) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Category'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await categoryProvider.deleteCategory(category.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Category deleted'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}