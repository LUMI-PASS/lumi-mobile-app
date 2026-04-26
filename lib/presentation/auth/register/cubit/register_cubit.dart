import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends BaseCubit<RegisterBuildable, RegisterListenable> {
  RegisterCubit(this._repo) : super(const RegisterBuildable());
  final AuthRepository _repo;

  void changeState(bool state) {
    build((buildable) => buildable.copyWith(isSelected: state));
  }

  void selectDistrict(String? district) {
    build((buildable) => buildable.copyWith(selectedDistrict: district));
  }

  Future<void> register(ProfileModel registerModel) => callable(
        future: _repo.register(
          phone: registerModel.phoneNumber ?? '',
          firstName: registerModel.firstName ?? '',
          lastName: registerModel.lastName ?? '',
        ),
        buildOnStart: () => buildable.copyWith(isLoading: true),
        invokeOnData: (data) => const RegisterListenable(
          effect: RegisterEffect.main,
        ),

        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(isLoading: false),
      );
}
