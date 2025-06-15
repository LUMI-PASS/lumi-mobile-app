import 'package:lumi_pass/feature/profile/data/model/profile_data.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitState extends ProfileState {
  const ProfileInitState();
}

class ProfileLoadedState extends ProfileState {
  final ProfileData profileData;
  bool isProfileUpdated;

  ProfileLoadedState(
    this.profileData, {
    this.isProfileUpdated = false,
  });
}

class ProfileLoggedOutState extends ProfileState {
  const ProfileLoggedOutState();
}

class ProfileErrorState extends ProfileState {
  const ProfileErrorState();
}
