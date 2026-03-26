enum PostVisibility {
  public,
  private,
  followers;

  static PostVisibility fromJson(String? value) {
    switch (value) {
      case 'private':
        return PostVisibility.private;
      case 'followers':
        return PostVisibility.followers;
      default:
        return PostVisibility.public;
    }
  }

  String toJson() => name;
}
