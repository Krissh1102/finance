// Provider to manage categories
import 'package:finance/models/category.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => [..._categories];
  bool get isLoading => _isLoading;

  // Fetch categories from storage/database
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Implement your data fetching logic here
      // For example:
      // final categoriesData = await YourCategoryService.getCategories();
      // _categories = categoriesData.map((data) => Category.fromJson(data)).toList();
      
      // Placeholder for demo
      await Future.delayed(Duration(seconds: 1));
      
    } catch (error) {
      // Handle error
      print('Error fetching categories: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new category
  Future<void> addCategory(String name, Color color, {IconData icon = Icons.category}) async {
    try {
      // Generate a unique ID (you might use UUID package in a real app)
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newCategory = Category(
        id: id,
        name: name,
        color: color,
        icon: icon,
      );
      
      // Save to database/storage
      // await YourCategoryService.addCategory(newCategory.toJson());
      
      // Add to local list
      _categories.add(newCategory);
      notifyListeners();
    } catch (error) {
      print('Error adding category: $error');
      throw error;
    }
  }

  // Update an existing category
  Future<void> updateCategory(
    String id, 
    String name, 
    Color color, 
    {IconData? icon}
  ) async {
    try {
      final categoryIndex = _categories.indexWhere((cat) => cat.id == id);
      
      if (categoryIndex >= 0) {
        final updatedCategory = _categories[categoryIndex].copyWith(
          name: name,
          color: color,
          icon: icon,
        );
        
        // Update in database/storage
        // await YourCategoryService.updateCategory(updatedCategory.toJson());
        
        // Update local list
        _categories[categoryIndex] = updatedCategory;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating category: $error');
      throw error;
    }
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      // Delete from database/storage
      // await YourCategoryService.deleteCategory(id);
      
      // Remove from local list
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } catch (error) {
      print('Error deleting category: $error');
      throw error;
    }
  }

  getCategoryById(String key) {}
}