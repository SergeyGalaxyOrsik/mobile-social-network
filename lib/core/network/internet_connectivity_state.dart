import 'package:equatable/equatable.dart';

class InternetConnectivityState extends Equatable {
  const InternetConnectivityState({this.isOnline});

  final bool? isOnline;

  bool get showOfflineBanner => isOnline == false;

  @override
  List<Object?> get props => [isOnline];
}
