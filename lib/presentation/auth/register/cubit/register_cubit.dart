import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/data/api_model/register/register_model.dart';
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

  Future<void> register(ProfileModel registerModel) => callable(
        future: _repo.register(registerModel),
        buildOnStart: () => buildable.copyWith(isLoading: true),
        invokeOnData: (data) => const RegisterListenable(
          effect: RegisterEffect.main,
        ),

        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(isLoading: false),
      );
}
