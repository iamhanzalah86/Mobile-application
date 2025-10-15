import 'package:flutter/material.dart';
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> attractions = [
      {
        'name': 'Eiffel Tower',
        'image': 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=400',
      },
      {
        'name': 'Great Wall of China',
        'image': 'https://images.unsplash.com/photo-1508804185872-d7badad00f7d?w=400',
      },
      {
        'name': 'Taj Mahal',
        'image': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=400',
      },
      {
        'name': 'Statue of Liberty',
        'image': 'https://images.unsplash.com/photo-1601044772535-37e26e0c8c05?w=400',
      },
      {
        'name': 'Machu Picchu',
        'image': 'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=400',
      },
      {
        'name': 'Colosseum',
        'image': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: attractions.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    attractions[index]['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  attractions[index]['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}