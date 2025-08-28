import 'package:dio/dio.dart';
import 'package:flexobo/common/base/base_cubit.dart';
import 'package:flexobo/data/api_model/register/register_model.dart';
import 'package:flexobo/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends BaseCubit<RegisterBuildable, RegisterListenable> {
  RegisterCubit(this._repo) : super(const RegisterBuildable());
  final AuthRepository _repo;

  void changeState(bool state) {
    build((buildable) => buildable.copyWith(isSelected: state));
  }

  Future<void> register(RegisterModel registerModel) => callable(
        future: _repo.register(registerModel),
        buildOnStart: () => buildable.copyWith(isLoading: true),
        invokeOnData: (data) => const RegisterListenable(
          effect: RegisterEffect.main,
        ),
      onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(isLoading: false),
      );
}
