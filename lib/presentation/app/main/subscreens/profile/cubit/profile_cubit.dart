import 'package:flexobo/common/base/base_cubit.dart';
import 'package:flexobo/data/storage/storage.dart';
import 'package:injectable/injectable.dart';

import 'profile_state.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileBuildable, ProfileListenable> {
  ProfileCubit(this._storage) : super(const ProfileBuildable());
  final Storage _storage;

  Future<void> logout() => callable(
    future: _storage.logout(),
    buildOnStart: () => buildable.copyWith(isLoading: true),
    invokeOnData: (data) =>  const ProfileListenable(
     effect:  ProfileEffect.login,
    ),
    onErrorData: (error) => display.error(error),
    buildOnDone: () => buildable.copyWith(isLoading: false),
  );

}
