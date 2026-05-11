class Country {
  const Country({required this.id, required this.name, this.code});

  final int id;
  final String name;
  final String? code;
}

class City {
  const City({required this.id, required this.name, this.countryId});

  final int id;
  final String name;
  final int? countryId;
}

class AppLanguage {
  const AppLanguage({required this.code, required this.name});

  final String code;
  final String name;
}

class AppThemeReference {
  const AppThemeReference({required this.code, required this.name});

  final String code;
  final String name;
}
