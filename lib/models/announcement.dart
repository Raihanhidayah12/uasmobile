class Announcement {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;

  Announcement({required this.id, required this.title, required this.content, required this.createdAt});

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
        id: map['id'],
        title: map['title'],
        content: map['content'],
        createdAt: DateTime.parse(map['created_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}
