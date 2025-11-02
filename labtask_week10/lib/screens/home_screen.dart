import 'package:flutter/material.dart';
import 'restaurant_detail_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/restaurent_tile.dart';
import '../widgets/dish_card.dart';
import '../data/app_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverSafeArea with SliverAppBar - Stack concept
          _buildAppBar(),

          // Categories Section - ListView horizontal
          _buildCategoriesSection(),

          // Popular Restaurants - ListView with ListTile
          _buildRestaurantsHeader(),
          _buildRestaurantsList(context),

          // Featured Dishes - GridView with Stack
          _buildFeaturedDishesHeader(),
          _buildFeaturedDishesGrid(context),

          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  // SliverSafeArea with Stack in AppBar
  Widget _buildAppBar() {
    return SliverSafeArea(
      sliver: SliverAppBar(
        expandedHeight: 200,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: const Text('Food Delivery'),
          background: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.orange,
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    '🍕 Fast Delivery',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Categories - ListView horizontal
  Widget _buildCategoriesSection() {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const Text(
              'Categories',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppData.categories.length,
                itemBuilder: (context, index) {
                  final category = AppData.categories[index];
                  return CategoryCard(
                    emoji: category['emoji']!,
                    name: category['name']!,
                    color: category['color'] as Color,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _buildRestaurantsHeader() {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const Text(
              'Popular Restaurants',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  // ListView with ListTile
  Widget _buildRestaurantsList(BuildContext context) {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final restaurant = AppData.restaurants[index];
              return RestaurantTile(
                restaurant: restaurant,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantDetailScreen(
                        restaurantName: restaurant['name']!,
                      ),
                    ),
                  );
                },
              );
            },
            childCount: AppData.restaurants.length,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedDishesHeader() {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 20),
            const Text(
              'Featured Dishes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  // GridView.count with Stack
  Widget _buildFeaturedDishesGrid(BuildContext context) {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final dish = AppData.featuredDishes[index];
              return DishCard(
                dish: dish,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${dish['name']} to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
            childCount: AppData.featuredDishes.length,
          ),
        ),
      ),
    );
  }
}

