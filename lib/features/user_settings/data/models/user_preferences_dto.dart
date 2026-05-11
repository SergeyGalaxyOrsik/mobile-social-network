class UserPreferencesDto {
  const UserPreferencesDto(this.values);

  final Map<String, dynamic> values;

  factory UserPreferencesDto.fromJson(Map<String, dynamic> json) {
    return UserPreferencesDto(Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(values);
}
