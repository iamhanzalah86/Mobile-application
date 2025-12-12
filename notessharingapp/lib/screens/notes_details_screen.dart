import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NoteDetailScreen extends StatefulWidget {
  final dynamic note;

  NoteDetailScreen({required this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool isDownloading = false;
  double downloadProgress = 0.0;

  Future<void> _downloadNote() async {
    // Request storage permission
    var status = await Permission.storage.request();

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required to download files')),
      );
      return;
    }

    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
    });

    try {
      // Get the file URL from the note
      String? fileUrl = widget.note['fileUrl'] ?? widget.note['imageUrl'];

      if (fileUrl == null || fileUrl.isEmpty) {
        throw Exception('No file URL available');
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create filename
      String fileName = widget.note['title'] ?? 'note_${DateTime.now().millisecondsSinceEpoch}';
      String fileExtension = fileUrl.split('.').last.split('?').first;
      String fullPath = '${directory!.path}/$fileName.$fileExtension';

      print('📥 Downloading to: $fullPath');

      // Download using Dio
      Dio dio = Dio();
      await dio.download(
        fileUrl,
        fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
            print('Download progress: ${(downloadProgress * 100).toStringAsFixed(0)}%');
          }
        },
      );

      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Downloaded successfully to Downloads folder'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

    } catch (e) {
      print('❌ Download error: $e');
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final title = note['title'] ?? 'Untitled';
    final description = note['description'] ?? '';
    final imageUrl = note['imageUrl'] ?? note['fileUrl'];
    final userName = note['userName'] ?? note['username'] ?? 'Unknown';
    final createdAt = note['createdAt'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
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
              title,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share functionality coming soon')),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // More options
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image/File Preview
                if (imageUrl != null)
                  Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.grey[900],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                size: 80,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'File Preview',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[900],
                    child: Center(
                      child: Icon(
                        Icons.note,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                // Note Details
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Author and Date
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[800],
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(width: 8),
                          Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Description
                      if (description.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                        ),

                      // Download Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: isDownloading ? null : _downloadNote,
                          icon: isDownloading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: downloadProgress,
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Icon(Icons.download, color: Colors.black),
                          label: Text(
                            isDownloading
                                ? 'Downloading ${(downloadProgress * 100).toStringAsFixed(0)}%'
                                : 'Download',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Stats
                      Row(
                        children: [
                          _buildStatItem(
                            Icons.favorite_border,
                            '${note['likes'] ?? 0}',
                            Colors.red,
                          ),
                          SizedBox(width: 24),
                          _buildStatItem(
                            Icons.visibility_outlined,
                            '${note['views'] ?? 0}',
                            Colors.blue,
                          ),
                          SizedBox(width: 24),
                          _buildStatItem(
                            Icons.download_outlined,
                            '${note['downloads'] ?? 0}',
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Just now';

    try {
      final DateTime dateTime = date is DateTime
          ? date
          : DateTime.parse(date.toString());
      final Duration diff = DateTime.now().difference(dateTime);

      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
      return 'Just now';
    } catch (e) {
      return 'Just now';
    }
  }
}