import 'package:flutter/material.dart';
import 'package:notessharingapp/screens/user_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'user_screen.dart';
import '../utils/dowloads.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool hasSearched = false;

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        hasSearched = false;
      });
      return;
    }

    setState(() {
      hasSearched = true;
    });

    try {
      print('🚀 Starting search from SearchScreen');
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      print('🔑 Auth token exists: ${auth.token != null}');

      if (auth.token != null) {
        await userProv.searchUsers(query, auth.token!);
        print('✅ Search completed in SearchScreen');
      } else {
        print('❌ No auth token available');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login again')),
        );
      }
    } catch (e) {
      print('❌ Error in SearchScreen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        hasSearched = false;
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {});
                  // Debounce search - wait for user to stop typing
                  Future.delayed(Duration(milliseconds: 500), () {
                    if (value == _searchController.text) {
                      searchUsers(value);
                    }
                  });
                },
                onSubmitted: (value) {
                  searchUsers(value);
                },
              ),
            ),
          ),

          // Results
          Expanded(
            child: userProv.loading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Searching...',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
                : userProv.error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      userProv.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        searchUsers(_searchController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
                : hasSearched && userProv.searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : !hasSearched
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Search for users',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find people to follow',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: userProv.searchResults.length,
              itemBuilder: (context, index) {
                final user = userProv.searchResults[index];
                return _buildUserCard(user, userProv, auth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user, UserProvider userProv, AuthProvider auth) {
    final bool isFollowing = user['isFollowing'] ?? false;
    final String userId = user['_id'] ?? user['id'] ?? '';
    final String username = user['username'] ?? 'Unknown';
    final String email = user['email'] ?? user['name'] ?? '';
    final String? profilePicture = user['profilePicture'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(

        children: [
          // Profile Picture
          GestureDetector(
            onTap: () {
              // Navigate to user profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    userId: userId,
                    username: username,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 28,
              backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                  ? NetworkImage(profilePicture)
                  : null,
              backgroundColor: Colors.grey[800],
              child: profilePicture == null || profilePicture.isEmpty
                  ? Icon(Icons.person, color: Colors.grey[400], size: 28)
                  : null,
            ),
          ),
          SizedBox(width: 12),

          // User Info
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to user profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(
                      userId: userId,
                      username: username,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Follow/Unfollow Button
          SizedBox(
            width: 100,
            height: 36,
            child: ElevatedButton(
              onPressed: userProv.loading
                  ? null
                  : () async {
                if (isFollowing) {
                  await userProv.unfollowUser(userId, auth.token!);
                } else {
                  await userProv.followUser(userId, auth.token!);
                }
                // Refresh search results to update follow status
                if (_searchController.text.isNotEmpty) {
                  await searchUsers(_searchController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[900] : Colors.white,
                foregroundColor: isFollowing ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isFollowing ? Colors.grey[700]! : Colors.white,
                  ),
                ),
                elevation: 0,
              ),
              child: userProv.loading
                  ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isFollowing ? Colors.white : Colors.black,
                ),
              )
                  : Text(
                isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}