abstract class AfishaRegistrationState {}

class AfishaRegistrationInitial extends AfishaRegistrationState {}

class AfishaRegistrationLoading extends AfishaRegistrationState {}

class AfishaRegistrationSuccess extends AfishaRegistrationState {}

class AfishaRegistrationError extends AfishaRegistrationState {
  final String message;

  AfishaRegistrationError(this.message);
}
