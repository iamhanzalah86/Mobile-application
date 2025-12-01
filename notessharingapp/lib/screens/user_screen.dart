import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? username;

  UserProfileScreen({required this.userId, this.username});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isLoading = true;
  Map<String, dynamic>? userProfile;
  List<dynamic> userNotes = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userProv = Provider.of<UserProvider>(context, listen: false);

      // Fetch user profile and their notes
      await userProv.fetchUserProfile(widget.userId, auth.token!);

      setState(() {
        userProfile = userProv.currentUserProfile;
        userNotes = userProv.currentUserNotes;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    final isFollowing = userProfile?['isFollowing'] ?? false;

    try {
      if (isFollowing) {
        await userProv.unfollowUser(widget.userId, auth.token!);
      } else {
        await userProv.followUser(widget.userId, auth.token!);
      }

      // Refresh profile to update follow status
      await _loadUserProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update follow status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isOwnProfile = auth.userId == widget.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.black,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              userProfile?['name'] ?? widget.username ?? 'Profile',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Show options menu
                },
              ),
            ],
          ),

          // Profile Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userProfile?['profilePicture'] != null
                        ? NetworkImage(userProfile!['profilePicture'])
                        : null,
                    backgroundColor: Colors.grey[800],
                    child: userProfile?['profilePicture'] == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                        : null,
                  ),
                  SizedBox(height: 16),

                  // Username
                  Text(
                    userProfile?['name'] ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Email
                  Text(
                    userProfile?['email'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                        '${userNotes.length}',
                        'Posts',
                      ),
                      _buildStatColumn(
                        '${(userProfile?['followers'] as List<String>?)?.length ?? 0}',
                        'Followers',
                      ),
                      _buildStatColumn(
                        '${(userProfile?['following'] as List<String>?)?.length ?? 0}',
                        'Following',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Follow/Edit Button
                  if (isOwnProfile)
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to edit profile
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[700]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: userProfile?['isFollowing'] == true
                              ? Colors.grey[900]
                              : Colors.white,
                          foregroundColor: userProfile?['isFollowing'] == true
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: userProfile?['isFollowing'] == true
                                  ? Colors.grey[700]!
                                  : Colors.white,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          userProfile?['isFollowing'] == true ? 'Following' : 'Follow',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Divider
                  Divider(color: Colors.grey[900]),
                  SizedBox(height: 10),

                  // Posts Header
                  Row(
                    children: [
                      Icon(Icons.grid_on, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Posts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Posts Grid
          userNotes.isEmpty
              ? SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 64,
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : SliverPadding(
            padding: EdgeInsets.all(2),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final note = userNotes[index];
                  return _buildPostGridItem(note);
                },
                childCount: userNotes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPostGridItem(dynamic note) {
    return GestureDetector(
      onTap: () {
        // Navigate to note details
        print('Tapped on note: ${note['_id']}');
      },
      child: Container(
        color: Colors.grey[900],
        child: note['imageUrl'] != null
            ? Image.network(
          note['imageUrl'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey[700],
                size: 40,
              ),
            );
          },
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note,
                color: Colors.grey[600],
                size: 30,
              ),
              SizedBox(height: 4),
              if (note['title'] != null)
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    note['title'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}