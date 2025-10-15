import 'package:flutter/material.dart';
class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> destinations = [
      {
        'name': 'Paris, France',
        'description': 'The City of Light, famous for the Eiffel Tower, Louvre Museum, and romantic Seine River.',
        'image': 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=400',
      },
      {
        'name': 'Tokyo, Japan',
        'description': 'A vibrant metropolis blending ancient temples with modern technology and delicious cuisine.',
        'image': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400',
      },
      {
        'name': 'New York, USA',
        'description': 'The city that never sleeps, home to Times Square, Central Park, and the Statue of Liberty.',
        'image': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400',
      },
      {
        'name': 'Dubai, UAE',
        'description': 'A luxurious desert oasis featuring Burj Khalifa, stunning beaches, and world-class shopping.',
        'image': 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400',
      },
      {
        'name': 'London, England',
        'description': 'Historic city with Big Ben, Buckingham Palace, and a rich cultural heritage.',
        'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400',
      },
      {
        'name': 'Rome, Italy',
        'description': 'The Eternal City, showcasing the Colosseum, Vatican, and incredible Italian cuisine.',
        'image': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
      },
      {
        'name': 'Barcelona, Spain',
        'description': 'Artistic city famous for Gaudí architecture, beautiful beaches, and vibrant culture.',
        'image': 'https://images.unsplash.com/photo-1562883676-8c7feb83f09b?w=400',
      },
      {
        'name': 'Sydney, Australia',
        'description': 'Coastal paradise known for the Opera House, Harbor Bridge, and stunning beaches.',
        'image': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400',
      },
      {
        'name': 'Istanbul, Turkey',
        'description': 'Where East meets West, featuring magnificent mosques, bazaars, and Bosphorus views.',
        'image': 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=400',
      },
      {
        'name': 'Bali, Indonesia',
        'description': 'Tropical paradise with lush rice terraces, ancient temples, and pristine beaches.',
        'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  destinations[index]['image']!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destinations[index]['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      destinations[index]['description']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}