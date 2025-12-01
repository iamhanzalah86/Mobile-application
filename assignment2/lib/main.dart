import 'package:flutter/material.dart';

void main() {
  runApp(const TravelGuideApp());
}

class TravelGuideApp extends StatelessWidget {
  const TravelGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Guide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ListScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Guide'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Travel Guide',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Destinations'),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController destinationController = TextEditingController();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Travel Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800',
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Welcome Message Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'Welcome to Travel Guide! Your journey to discover amazing destinations around the world starts here. Explore breathtaking locations, plan your next adventure, and create unforgettable memories.',
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // RichText Travel Slogan
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 24),
                  children: [
                    TextSpan(
                      text: 'Explore ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    TextSpan(
                      text: 'the ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    TextSpan(
                      text: 'World ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    TextSpan(
                      text: 'with Us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // TextField for Destination
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                labelText: 'Enter Destination Name',
                hintText: 'e.g., Paris, Tokyo, New York',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ElevatedButton
            ElevatedButton(
              onPressed: () {
                print('Searching for: ${destinationController.text}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      destinationController.text.isEmpty
                          ? 'Please enter a destination!'
                          : 'Searching for ${destinationController.text}...',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Search Destination', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),

            // TextButton
            TextButton(
              onPressed: () {
                print('View all destinations button clicked');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Loading all destinations...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'View All Destinations',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// List Screen
class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> destinations = [
      {
        'name': 'Paris, France',
        'description': 'The City of Light, famous for the Eiffel Tower, Louvre Museum, and romantic Seine River.'
      },
      {
        'name': 'Tokyo, Japan',
        'description': 'A vibrant metropolis blending ancient temples with modern technology and delicious cuisine.'
      },
      {
        'name': 'New York, USA',
        'description': 'The city that never sleeps, home to Times Square, Central Park, and the Statue of Liberty.'
      },
      {
        'name': 'Dubai, UAE',
        'description': 'A luxurious desert oasis featuring Burj Khalifa, stunning beaches, and world-class shopping.'
      },
      {
        'name': 'London, England',
        'description': 'Historic city with Big Ben, Buckingham Palace, and a rich cultural heritage.'
      },
      {
        'name': 'Rome, Italy',
        'description': 'The Eternal City, showcasing the Colosseum, Vatican, and incredible Italian cuisine.'
      },
      {
        'name': 'Barcelona, Spain',
        'description': 'Artistic city famous for Gaudí architecture, beautiful beaches, and vibrant culture.'
      },
      {
        'name': 'Sydney, Australia',
        'description': 'Coastal paradise known for the Opera House, Harbor Bridge, and stunning beaches.'
      },
      {
        'name': 'Istanbul, Turkey',
        'description': 'Where East meets West, featuring magnificent mosques, bazaars, and Bosphorus views.'
      },
      {
        'name': 'Bali, Indonesia',
        'description': 'Tropical paradise with lush rice terraces, ancient temples, and pristine beaches.'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              destinations[index]['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                destinations[index]['description']!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}

// About Screen
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
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: attractions.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
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
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  attractions[index]['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}