import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon; // Added icon support

  Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon = Icons.category, // Default icon
  });

  // Create from JSON (e.g., from a database or API)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      icon: IconData(
        json['icon'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  // Create a copy with some fields changed
  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

