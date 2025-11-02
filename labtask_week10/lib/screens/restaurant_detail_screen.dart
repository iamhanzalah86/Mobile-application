import 'package:flutter/material.dart';
import '../widgets/menu_item_card.dart';
import '../data/app_data.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String restaurantName;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverSafeArea with Stack in AppBar
          _buildAppBar(),

          // Menu Info - ListView with ListTile
          _buildRestaurantInfo(),

          // Popular Items Header
          _buildPopularItemsHeader(),

          // Popular Items - GridView.extent
          _buildPopularItemsGrid(),

          // Full Menu Header
          _buildFullMenuHeader(),

          // Full Menu - GridView.builder
          _buildFullMenuGrid(context),

          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverSafeArea(
      sliver: SliverAppBar(
        expandedHeight: 250,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(restaurantName),
          background: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.orange[300],
                child: const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 100,
                    color: Colors.white54,
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('4.5', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Open Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const ListTile(
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text('NEW BLUEAREA, ISLAMABAD'),
              contentPadding: EdgeInsets.zero,
            ),
            const ListTile(
              leading: Icon(Icons.access_time, color: Colors.blue),
              title: Text('Delivery: 25-35 min'),
              contentPadding: EdgeInsets.zero,
            ),
            const ListTile(
              leading: Icon(Icons.delivery_dining, color: Colors.green),
              title: Text('Free delivery on orders over \Rs 1500/='),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _buildPopularItemsHeader() {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const Text(
              'Popular Items',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  // GridView.extent
  Widget _buildPopularItemsGrid() {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = AppData.popularItems[index];
              return MenuItemCard(item: item);
            },
            childCount: AppData.popularItems.length,
          ),
        ),
      ),
    );
  }

  Widget _buildFullMenuHeader() {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 20),
            const Text(
              'Full Menu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  // GridView.builder
  Widget _buildFullMenuGrid(BuildContext context) {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added item ${index + 1} to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orange[200]!,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppData.menuEmojis[index],
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: AppData.menuEmojis.length,
          ),
        ),
      ),
    );
  }
}