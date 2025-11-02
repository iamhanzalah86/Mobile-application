import 'package:flutter/material.dart';

class AppData {
  // Categories Data
  static final List<Map<String, dynamic>> categories = [
    {'emoji': '🍔', 'name': 'Burgers', 'color': Colors.red},
    {'emoji': '🍕', 'name': 'Pizza', 'color': Colors.orange},
    {'emoji': '🍜', 'name': 'Noodles', 'color': Colors.yellow},
    {'emoji': '🍰', 'name': 'Desserts', 'color': Colors.pink},
    {'emoji': '☕', 'name': 'Coffee', 'color': Colors.brown},
    {'emoji': '🥗', 'name': 'Salads', 'color': Colors.green},
  ];

  // Restaurants Data
  static final List<Map<String, dynamic>> restaurants = [
    {
      'name': 'Burger House',
      'type': 'Fast Food',
      'rating': '4.5',
      'time': '20-30 min',
      'icon': Icons.fastfood
    },
    {
      'name': 'Pizza Palace',
      'type': 'Italian',
      'rating': '4.8',
      'time': '25-35 min',
      'icon': Icons.local_pizza
    },
    {
      'name': 'Sushi Master',
      'type': 'Japanese',
      'rating': '4.7',
      'time': '30-40 min',
      'icon': Icons.restaurant
    },
    {
      'name': 'Taco Town',
      'type': 'Mexican',
      'rating': '4.6',
      'time': '15-25 min',
      'icon': Icons.lunch_dining
    },
  ];

  // Featured Dishes Data
  static final List<Map<String, String>> featuredDishes = [
    {'name': 'Cheeseburger', 'price': '\Rs 899/-', 'emoji': '🍔'},
    {'name': 'Margherita Pizza', 'price': '\Rs 999/-', 'emoji': '🍕'},
    {'name': 'Pad Thai', 'price': '\Rs 1099/-', 'emoji': '🍜'},
    {'name': 'Chocolate Cake', 'price': '\Rs 499/-', 'emoji': '🍰'},
  ];

  // Popular Items Data
  static final List<Map<String, String>> popularItems = [
    {'name': 'Classic Burger', 'price': '\Rs 899/-', 'emoji': '🍔'},
    {'name': 'Cheese Pizza', 'price': '\Rs 999/-', 'emoji': '🍕'},
    {'name': 'French Fries', 'price': '\Rs 1099/-', 'emoji': '🍟'},
    {'name': 'Ice Cream', 'price': '\Rs 299/-', 'emoji': '🍦'},
    {'name': 'Chicken Wings', 'price': '\Rs 699/-', 'emoji': '🍗'},
    {'name': 'Soft Drink', 'price': '\Rs 199/-', 'emoji': '🥤'},
  ];

  // Menu Emojis
  static final List<String> menuEmojis = [
    '🍔', '🍕', '🍟', '🌭', '🥪', '🌮',
    '🍝', '🍜', '🍲', '🥗', '🍣', '🍱',
    '🍛', '🍤', '🍗', '🥙', '🧆', '🍦'
  ];
}