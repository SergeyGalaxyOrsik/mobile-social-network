import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:mobile_social_network/core/network/internet_connectivity_state.dart';

class InternetConnectivityCubit extends Cubit<InternetConnectivityState> {
  InternetConnectivityCubit()
    : super(const InternetConnectivityState(isOnline: null)) {
    unawaited(_check());
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_check()));
  }

  static const _pollInterval = Duration(seconds: 5);

  final InternetConnection _connection = InternetConnection();
  Timer? _timer;

  Future<void> _check() async {
    if (isClosed) return;
    try {
      final status = await _connection.internetStatus;
      if (isClosed) return;
      _emitFromStatus(status);
    } catch (_) {
      if (isClosed) return;
      emit(const InternetConnectivityState(isOnline: false));
    }
  }

  void _emitFromStatus(InternetStatus status) {
    emit(
      InternetConnectivityState(isOnline: status == InternetStatus.connected),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
