part of 'profile_creation_cubit.dart';

sealed class ProfileCreationState {
  const ProfileCreationState();
}

class ProfileCreationInitialState extends ProfileCreationState {}

class ProfileCreationLoadingState extends ProfileCreationState {}

class ProfileCreationFinishedState extends ProfileCreationState {
  final ProfileData profileData;
  const ProfileCreationFinishedState(this.profileData);
}

class ProfileCreationErrorState extends ProfileCreationState {
  final ChessException exception;
  const ProfileCreationErrorState(this.exception);
}
