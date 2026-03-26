import 'package:equatable/equatable.dart';

class PublishingTask extends Equatable {
  const PublishingTask({required this.id, required this.progress});

  final String id;
  final double progress;

  @override
  List<Object?> get props => [id, progress];
}
