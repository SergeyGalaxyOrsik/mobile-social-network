class NoteEntity {
  final int? id;
  final String? userId;
  final String note;
  final String date;
  final String? image;

  const NoteEntity({
    this.id,
    this.userId,
    required this.note,
    required this.date,
    this.image,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'note': note, 'date': date};
    if (id != null) {
      map['id'] = id;
    }
    if (userId != null) {
      map['userId'] = userId;
    }
    if (image != null) {
      map['image'] = image;
    }
    return map;
  }

  factory NoteEntity.fromMap(Map<String, dynamic> map) {
    return NoteEntity(
      id: map['id'],
      userId: map['userId'],
      note: map['note'],
      date: map['date'],
      image: map['image'],
    );
  }
}
