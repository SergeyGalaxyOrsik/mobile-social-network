class NoteEntity {
  final int? id;
  final String note;
  final String date;
  final String? image;

  const NoteEntity({
    this.id,
    required this.note,
    required this.date,
    this.image,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'note': note, 'date': date};
    if (id != null) {
      map['id'] = id;
    }
    if (image != null) {
      map['image'] = image;
    }
    return map;
  }

  factory NoteEntity.fromMap(Map<String, dynamic> map) {
    return NoteEntity(
      id: map['id'],
      note: map['note'],
      date: map['date'],
      image: map['image'],
    );
  }
}
