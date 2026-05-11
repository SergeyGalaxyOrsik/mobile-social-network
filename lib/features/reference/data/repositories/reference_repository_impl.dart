import 'package:mobile_social_network/features/reference/data/datasources/reference_remote_datasource.dart';
import 'package:mobile_social_network/features/reference/data/models/reference_api_models.dart';
import 'package:mobile_social_network/features/reference/domain/entities/reference_entities.dart';
import 'package:mobile_social_network/features/reference/domain/repositories/reference_repository.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._remote);

  final ReferenceRemoteDataSource _remote;
  final Map<String, _CacheEntry<List<Object>>> _cache = {};

  static const _ttl = Duration(minutes: 15);

  Future<List<T>> _cached<T extends Object>(
    String key,
    Future<List<T>> Function() loader,
  ) async {
    final now = DateTime.now();
    final cached = _cache[key];
    if (cached != null && now.difference(cached.createdAt) < _ttl) {
      return cached.value.cast<T>();
    }
    final value = await loader();
    _cache[key] = _CacheEntry<List<Object>>(value, now);
    return value;
  }

  @override
  Future<List<Country>> getCountries({int page = 1, int limit = 50}) {
    return _cached('countries:$page:$limit', () async {
      final dto = await _remote.listCountries(page: page, limit: limit);
      return dto.items.map(_country).where((e) => e.id != 0).toList();
    });
  }

  @override
  Future<List<City>> getCities({int page = 1, int limit = 50, int? countryId}) {
    return _cached('cities:$page:$limit:${countryId ?? ''}', () async {
      final dto = await _remote.listCities(
        page: page,
        limit: limit,
        countryId: countryId,
      );
      return dto.items.map(_city).where((e) => e.id != 0).toList();
    });
  }

  @override
  Future<List<AppLanguage>> getLanguages() {
    return _cached('languages', () async {
      final dto = await _remote.listLanguages();
      return dto.items.map(_language).where((e) => e.code.isNotEmpty).toList();
    });
  }

  @override
  Future<List<AppThemeReference>> getThemes() {
    return _cached('themes', () async {
      final dto = await _remote.listThemes();
      return dto.items.map(_theme).where((e) => e.code.isNotEmpty).toList();
    });
  }

  Country _country(CountryDto dto) =>
      Country(id: dto.id, name: dto.name, code: dto.code);

  City _city(CityDto dto) =>
      City(id: dto.id, name: dto.name, countryId: dto.countryId);

  AppLanguage _language(LanguageDto dto) =>
      AppLanguage(code: dto.code, name: dto.name.isEmpty ? dto.code : dto.name);

  AppThemeReference _theme(ThemeReferenceDto dto) => AppThemeReference(
    code: dto.code,
    name: dto.name.isEmpty ? dto.code : dto.name,
  );
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.createdAt);

  final T value;
  final DateTime createdAt;
}
