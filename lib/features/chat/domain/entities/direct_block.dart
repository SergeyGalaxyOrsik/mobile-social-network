import 'package:equatable/equatable.dart';

class DirectBlock extends Equatable {
  const DirectBlock({
    required this.userId,
    required this.blockedAt,
  });

  final String userId;
  final String blockedAt;

  @override
  List<Object?> get props => [userId, blockedAt];
}
