class UserPreferences {
  const UserPreferences(this.values);

  final Map<String, dynamic> values;

  String? get theme => values['theme'] as String?;
  String? get language => values['language'] as String?;
  String? get timezone => values['timezone'] as String?;
  String? get profileVisibility => values['profileVisibility'] as String?;
  String? get postsVisibility => values['postsVisibility'] as String?;
  String? get messagesAllowed => values['messagesAllowed'] as String?;

  int? get cityId {
    final raw = values['cityId'];
    return raw is num ? raw.toInt() : null;
  }
}
