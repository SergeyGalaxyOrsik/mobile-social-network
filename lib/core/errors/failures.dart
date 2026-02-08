/// Базовый класс для ошибок доменного слоя (Clean Architecture).
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ошибка сервера']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Ошибка кэша']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Ошибка валидации']);
}
