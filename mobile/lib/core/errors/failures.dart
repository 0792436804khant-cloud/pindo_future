abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again later.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Cannot reach API server. Please verify Laravel is running.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication required. Please sign in.']);
}
