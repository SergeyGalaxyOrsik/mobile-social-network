import 'package:mobile_social_network/features/auth/data/models/auth_user_view_dto.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

extension AuthUserViewDtoMapper on AuthUserViewDto {
  UserEntity toEntity() {
    return UserEntity(
      id: userId,
      email: email,
      username: username,
      avatarUrl: avatarUrl,
    );
  }
}
