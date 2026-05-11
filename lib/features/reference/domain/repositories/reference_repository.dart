import 'package:mobile_social_network/features/reference/domain/entities/reference_entities.dart';

abstract class ReferenceRepository {
  Future<List<Country>> getCountries({int page = 1, int limit = 50});

  Future<List<City>> getCities({int page = 1, int limit = 50, int? countryId});

  Future<List<AppLanguage>> getLanguages();

  Future<List<AppThemeReference>> getThemes();
}
