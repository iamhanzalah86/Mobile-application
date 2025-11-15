import 'package:flutter/material.dart';

void main() => runApp(const ShoppingCartApp());

class ShoppingCartApp extends StatelessWidget {
  const ShoppingCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('My Shopping Cart')),
        body: const ShoppingCartScreen(),
      ),
    );
  }
}

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

// State Management with Stateful Widget - Managing cart items and total
class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int _itemCount = 0;
  int _totalPrice = 0;
  bool _isFavorite = false;

  // State management - Increment item count
  void _addItem(int price) {
    setState(() {
      _itemCount++;
      _totalPrice += price;
    });
  }

  // State management - Reset cart
  void _resetCart() {
    setState(() {
      _itemCount = 0;
      _totalPrice = 0;
    });
  }

  // State management - Toggle favorite
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Expanded Widget - Takes available space for product list
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Row & Column Layout - Product card with horizontal layout
                _buildProductCard(
                  'Laptop',
                  Icons.laptop,
                  Colors.blue,
                  1200,
                  context,
                ),

                _buildProductCard(
                  'Headphones',
                  Icons.headphones,
                  Colors.purple,
                  150,
                  context,
                ),

                _buildProductCard(
                  'Mouse',
                  Icons.mouse,
                  Colors.orange,
                  50,
                  context,
                ),

                _buildProductCard(
                  'Keyboard',
                  Icons.keyboard,
                  Colors.green,
                  80,
                  context,
                ),
              ],
            ),
          ),
        ),

        // Flexible Widget - Footer section that adapts to content
        Flexible(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row Layout - Cart summary with icon and text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_cart, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          'Items: $_itemCount',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // GestureDetector - Toggle favorite with tap
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Column Layout - Total price display
                Text(
                  'Total: \$$_totalPrice',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 10),

                // Row Layout - Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Buttons with onPressed - Checkout action
                    ElevatedButton(
                      onPressed: _itemCount > 0
                          ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checkout: $_itemCount items, Total: \$$_totalPrice'),
                          ),
                        );
                      }
                          : null,
                      child: const Text('Checkout'),
                    ),
                    // Buttons with onPressed - Reset cart
                    TextButton(
                      onPressed: _resetCart,
                      child: const Text('Clear Cart'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Product Card Widget using multiple concepts
  Widget _buildProductCard(
      String name,
      IconData icon,
      Color color,
      int price,
      BuildContext context,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // InkWell - Touchable feedback with ripple effect
          InkWell(
            onTap: () {
              _addItem(price);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name added to cart!')),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Stack & Positioned - Icon with background circle
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Icon(icon, color: color, size: 40),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Expanded - Takes remaining space for product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$$price',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    // Column Layout - Add button
                    const Icon(Icons.add_shopping_cart, color: Colors.blue),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}