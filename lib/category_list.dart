import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'entry_list.dart';

typedef VoidCallback = void Function();

class CategoryList {
  List<Category> _categories = [];
  VoidCallback? onCategoryDeleted;

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('categories') ?? '[]';
    final jsonList = json.decode(jsonString) as List<dynamic>;
    _categories = jsonList.map((json) => Category.fromJson(json)).toList();
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_categories.map((category) => category.toJson()).toList());
    await prefs.setString('categories', jsonString);
  }

  void addCategory(Category category) {
    _categories.add(category);
    saveCategories();
  }

  Category updateCategory(int index, Category updatedCategory) {
    _categories[index] = updatedCategory;
    saveCategories();
    return updatedCategory;
  }

  Future<void> deleteCategory(int index, EntryList entryList) async {
    final deletedCategory = _categories.removeAt(index);

    // Create a new list of entries without the ones that reference the deleted category
    final newEntries = entryList.entries.where((entry) => entry.category.id != deletedCategory.id).toList();

    // Update the entries list with the new list of entries
    entryList.updateEntries(newEntries);

    // Save the updated list of categories
    saveCategories();

    // Call the callback
    onCategoryDeleted?.call();
  }
  
  List<Category> get categories => _categories;
}
