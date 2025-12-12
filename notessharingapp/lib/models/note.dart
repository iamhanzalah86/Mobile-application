class Note {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final String category;
  final bool isPrivate;
  final String userId;
  final String? userName;
  final String? imageUrl;
  final DateTime? createdAt;
  final int? likes;
  final int? views;
  final int? downloads;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.category,
    required this.isPrivate,
    required this.userId,
    this.userName,
    this.imageUrl,
    this.createdAt,
    this.likes,
    this.views,
    this.downloads,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      category: json['category'] ?? '',
      isPrivate: json['isPrivate'] ?? false,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? json['username'],
      imageUrl: json['imageUrl'] ?? json['fileUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      downloads: json['downloads'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'imageUrl': imageUrl ?? fileUrl,
      'category': category,
      'isPrivate': isPrivate,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt?.toIso8601String(),
      'likes': likes,
      'views': views,
      'downloads': downloads,
    };
  }
}