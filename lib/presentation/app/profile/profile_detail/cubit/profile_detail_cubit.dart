import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/catalog_revision.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
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

  /// The words the form offers.
  ///
  /// Quiet on failure: with none to offer the form leaves the question out
  /// and saves the name as it always did.
  Future<void> loadInterestTopics() async {
    try {
      final topics = await _repo.getInterestTopics();
      if (isClosed) return;
      build((buildable) => buildable.copyWith(interestTopics: topics));
    } catch (_) {}
  }

  Future<void> updateProfile(HomForUser user) {
    return callable(
      future: _repo.updateUser(user),
      buildOnStart: () => buildable.copyWith(success: true),
      invokeOnData: (data) {
        final name = user.firstName ?? '';
        if (name.isNotEmpty) {
          displayNameNotifier.value = name;
          getIt<Storage>().parentName.set(name);
        }
        // The home feed's "for your children" row is built from the topics
        // just saved, so home re-reads it the next time it is on screen.
        markCatalogChanged();
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
