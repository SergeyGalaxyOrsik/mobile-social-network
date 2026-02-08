/// Базовый контракт для use case (Clean Architecture).
/// [Type] — возвращаемый тип, [Params] — параметры (или void).
/// Ошибки передаются через Failure (можно обернуть в Result/Either при необходимости).
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Для use case без параметров.
abstract class UseCaseNoParams<Type> {
  Future<Type> call();
}
