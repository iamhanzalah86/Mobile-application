import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
//import '../widgets/note_card.dart';
import 'upload_note_screen.dart';
import '../utils/dowloads.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 0;
  List<dynamic> followingUsers = []; // Will store users you follow

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    notesProvider.fetchFeed(auth.token ?? '');
    _fetchFollowingUsers();
  }

  Future<void> _fetchFollowingUsers() async {
    // TODO: Implement API call to fetch following users
    // Example:
    // final auth = Provider.of<AuthProvider>(context, listen: false);
    // final response = await http.get(
    //   Uri.parse('YOUR_API/users/following'),
    //   headers: {'Authorization': 'Bearer ${auth.token}'},
    // );
    // if (response.statusCode == 200) {
    //   setState(() {
    //     followingUsers = json.decode(response.body);
    //   });
    // }

    // For now, it will remain empty until you follow someone
    setState(() {
      followingUsers = [];
    });
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // Already on Home
    } else if (index == 1) {
      // Search
      Navigator.pushNamed(context, '/search');
    } else if (index == 2) {
      // Upload (Center button)
      Navigator.pushNamed(context, '/upload');
    } else if (index == 3) {
      // Profile
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.white),
                        onPressed: () => Navigator.pushNamed(context, '/search'),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          // Navigate to notifications
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stories Row - Only show if you follow users
            if (followingUsers.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: followingUsers.length + 1, // +1 for "Your story"
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Your story
                      return _buildStoryAvatar(
                        'You',
                        auth.userId?.profilePicture ?? 'https://i.pravatar.cc/150?img=1',
                        isYourStory: true,
                      );
                    }
                    final user = followingUsers[index - 1];
                    return _buildStoryAvatar(
                      user['username'] ?? '@user',
                      user['profilePicture'] ?? 'https://i.pravatar.cc/150?img=$index',
                    );
                  },
                ),
              ),

            if (followingUsers.isNotEmpty) SizedBox(height: 8),

            // Feed
            Expanded(
              child: notesProvider.loading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
                  : notesProvider.notes.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Follow users to see their posts here',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Find People to Follow'),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                backgroundColor: Colors.grey[900],
                color: Colors.white,
                onRefresh: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  await notesProvider.fetchFeed(auth.token ?? '');
                  await _fetchFollowingUsers();
                },
                child: ListView.builder(
                  itemCount: notesProvider.notes.length,
                  itemBuilder: (context, index) {
                    final note = notesProvider.notes[index];
                    return _buildFeedPost(note);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildStoryAvatar(String username, String imageUrl, {bool isYourStory = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.orange, Colors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              padding: EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (_, __) {},
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedPost(dynamic note) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to user profile
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) => UserProfileScreen(userId: note.userId)
                    // ));
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: note.userProfilePicture != null
                        ? NetworkImage(note.userProfilePicture!)
                        : null,
                    backgroundColor: Colors.grey[800],
                    child: note.userProfilePicture == null
                        ? Icon(Icons.person, size: 16, color: Colors.grey[400])
                        : null,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to user profile
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.userName ?? 'Unknown User',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _getTimeAgo(note.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Show post options
                  },
                ),
              ],
            ),
          ),

          // Post Image
          GestureDetector(
            onTap: () {
              print("Note opened: ${note.id}");
              // Navigate to note details
            },
            child: Container(
              width: double.infinity,
              height: 350,
              color: Colors.grey[900],
              child: note.imageUrl != null
                  ? Image.network(
                note.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.grey[700],
                    ),
                  );
                },
              )
                  : Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          // Post Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle like
                  },
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border, color: Colors.white, size: 24),
                      SizedBox(width: 6),
                      Text(
                        '${note.likes ?? 0}',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    // Handle comment
                  },
                  child: Row(
                    children: [
                      Icon(Icons.mode_comment_outlined, color: Colors.white, size: 24),
                      SizedBox(width: 6),
                      Text(
                        '${note.comments ?? 0}',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    // Handle share/reply
                  },
                  child: Row(
                    children: [
                      Icon(Icons.reply, color: Colors.white, size: 24),
                      SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post Caption
          if (note.description != null && note.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                note.description!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(dynamic createdAt) {
    if (createdAt == null) return 'Just now';

    try {
      final DateTime dateTime = createdAt is DateTime
          ? createdAt
          : DateTime.parse(createdAt.toString());
      final Duration diff = DateTime.now().difference(dateTime);

      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return 'Just now';
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.grey[900]!, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.search, 'Search', 1),
              _buildCenterUploadButton(),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavBarTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 26,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterUploadButton() {
    return GestureDetector(
      onTap: () => _onNavBarTap(2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }
}

extension on String? {
  get profilePicture => null;
}