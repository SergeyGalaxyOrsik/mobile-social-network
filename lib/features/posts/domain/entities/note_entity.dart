/// Сущность заметки (доменный слой).
class NoteEntity {
  final int? id;
  final String title;
  final String description;
  final String date;

  const NoteEntity({
    this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'date': date,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory NoteEntity.fromMap(Map<String, dynamic> map) {
    return NoteEntity(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
    );
  }
}
