class Note {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final String category;
  final bool isPrivate;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.category,
    required this.isPrivate,
    required this.userId,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['fileUrl'],
      category: json['category'],
      isPrivate: json['isPrivate'],
      userId: json['userId'],
    );
  }
}