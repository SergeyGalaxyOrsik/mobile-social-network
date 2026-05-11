import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/reference/data/models/reference_api_models.dart';

class ReferenceRemoteDataSource {
  ReferenceRemoteDataSource(this._dio);

  final Dio _dio;

  static int _clampLimit(int? limit) {
    if (limit == null) return 50;
    return limit.clamp(1, 100);
  }

  static int _clampPage(int? page) {
    if (page == null) return 1;
    return page < 1 ? 1 : page;
  }

  Future<ReferenceListResponseDto<CountryDto>> listCountries({
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reference/countries',
        queryParameters: <String, dynamic>{
          'page': _clampPage(page),
          'limit': _clampLimit(limit),
        },
      );
      return ReferenceListResponseDto.fromJson(
        response.data!,
        CountryDto.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ReferenceListResponseDto<CityDto>> listCities({
    int? page,
    int? limit,
    int? countryId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reference/cities',
        queryParameters: <String, dynamic>{
          'page': _clampPage(page),
          'limit': _clampLimit(limit),
          if (countryId != null) 'countryId': countryId,
        },
      );
      return ReferenceListResponseDto.fromJson(
        response.data!,
        CityDto.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ReferenceListResponseDto<LanguageDto>> listLanguages() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reference/languages',
      );
      return ReferenceListResponseDto.fromJson(
        response.data!,
        LanguageDto.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ReferenceListResponseDto<ThemeReferenceDto>> listThemes() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reference/themes',
      );
      return ReferenceListResponseDto.fromJson(
        response.data!,
        ThemeReferenceDto.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
