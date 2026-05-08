class Note {
  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String title;
  final String body;
  final DateTime createdAt;

  factory Note.fromMap(Map<String, dynamic> row) {
    return Note(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      body: row['body'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    );
  }
}
