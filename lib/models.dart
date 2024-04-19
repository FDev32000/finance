import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final bool isIncome;

  Category(
      {required this.id,
      required this.name,
      required this.color,
      this.isIncome = true});

  // Конвертация объекта Category в JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.value, // Сохраняем цвет как число
        'isIncome': isIncome,
      };

  // Создание объекта Category из JSON
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        color: Color(json['color']), // Восстанавливаем цвет из числа
        isIncome: json['isIncome'],
      );
}

class Entry {
  final String id;
  final String name;
  final DateTime date;
  final Category category;
  final double price;

  Entry({
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    required this.price,
  });

  // Конвертация объекта Entry в JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(), // Сохраняем дату как строку
        'category': category.toJson(), // Сохраняем категорию как JSON
        'price': price,
      };

  // Создание объекта Entry из JSON
  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        id: json['id'],
        name: json['name'],
        date: DateTime.parse(json['date']), // Восстанавливаем дату из строки
        category: Category.fromJson(
            json['category']), // Восстанавливаем категорию из JSON
        price: json['price'],
      );
}

Future<void> saveData(List<Entry> entries) async {
  final prefs = await SharedPreferences.getInstance();
  final data = entries.map((e) => e.toJson()).toList();
  prefs.setString('data', json.encode(data));
}

Future<List<Entry>> loadData() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('data');
  if (data == null) return [];
  final list = json.decode(data) as List;
  return list.map((json) => Entry.fromJson(json)).toList();
}
