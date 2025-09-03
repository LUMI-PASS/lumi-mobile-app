import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'profile_detail_state.dart';

@injectable
class ProfileDetailCubit
    extends BaseCubit<ProfileDetailBuildable, ProfileDetailListenable> {
  ProfileDetailCubit(this._repo) : super(const ProfileDetailBuildable());
  final HomeRepository _repo;

  Future<void> getProfileDetail() {
    return callable(
      future: _repo.getProfileData(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      // invokeOnData: (data) => ProfileDetailListenable(
      //   effect: data ? ProfileDetailEffect.verify : ProfileDetailEffect.reg,
      // ),
      buildOnData: (data) {
        return buildable.copyWith(homeModel: data);
      },
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  Future<void> updateProfile(HomForUser user) {
    return callable(
      future: _repo.updateUser(user),
      buildOnStart: () => buildable.copyWith(success: true),
      invokeOnData: (data) {
        return const ProfileDetailListenable(
            effect: ProfileDetailEffect.verify);
      },
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(success: false),
    );
  }

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
