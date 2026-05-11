class ReferenceListResponseDto<T> {
  const ReferenceListResponseDto({required this.items, required this.total});

  final List<T> items;
  final int total;

  factory ReferenceListResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final rawTotal = json['total'];
    return ReferenceListResponseDto<T>(
      items: rawItems.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      total: rawTotal is num ? rawTotal.toInt() : rawItems.length,
    );
  }
}

class CountryDto {
  const CountryDto({required this.id, required this.name, this.code});

  final int id;
  final String name;
  final String? code;

  factory CountryDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return CountryDto(
      id: rawId is num ? rawId.toInt() : 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
    );
  }
}

class CityDto {
  const CityDto({required this.id, required this.name, this.countryId});

  final int id;
  final String name;
  final int? countryId;

  factory CityDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawCountry = json['countryId'] ?? json['country_id'];
    return CityDto(
      id: rawId is num ? rawId.toInt() : 0,
      name: json['name'] as String? ?? '',
      countryId: rawCountry is num ? rawCountry.toInt() : null,
    );
  }
}

class LanguageDto {
  const LanguageDto({required this.code, required this.name});

  final String code;
  final String name;

  factory LanguageDto.fromJson(Map<String, dynamic> json) {
    return LanguageDto(
      code: json['code'] as String? ?? '',
      name:
          json['name'] as String? ??
          json['native_name'] as String? ??
          json['label'] as String? ??
          '',
    );
  }
}

class ThemeReferenceDto {
  const ThemeReferenceDto({required this.code, required this.name});

  final String code;
  final String name;

  factory ThemeReferenceDto.fromJson(Map<String, dynamic> json) {
    return ThemeReferenceDto(
      code: json['code'] as String? ?? '',
      name:
          json['name'] as String? ??
          json['label'] as String? ??
          json['code'] as String? ??
          '',
    );
  }
}
