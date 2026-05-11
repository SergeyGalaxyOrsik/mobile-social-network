import 'auth_user_view_dto.dart';

class AuthTokensResponseDto {
  const AuthTokensResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUserViewDto user;

  factory AuthTokensResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: AuthUserViewDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };
}
