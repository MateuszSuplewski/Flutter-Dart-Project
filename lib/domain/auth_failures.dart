abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = "Brak połączenia z siecią"]);
}

class InvalidCredentialsFailure extends Failure {
  InvalidCredentialsFailure([super.message = "Niepoprawny email lub hasło"]);
}

class UnknownFailure extends Failure {
  UnknownFailure([super.message = "Nieznany błąd"]);
}
