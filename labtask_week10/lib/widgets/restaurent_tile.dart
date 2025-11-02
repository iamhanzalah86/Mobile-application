import 'package:flutter/material.dart';

class RestaurantTile extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;

  const RestaurantTile({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(
            restaurant['icon'] as IconData,
            color: Colors.white,
          ),
        ),
        title: Text(
          restaurant['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${restaurant['type']} • ${restaurant['time']}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                restaurant['rating'] as String,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

