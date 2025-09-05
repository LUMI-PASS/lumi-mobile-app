import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'children_state.dart';

@injectable
class ChildrenCubit extends BaseCubit<ChildrenBuildable, ChildrenListenable> {
  ChildrenCubit(this._repo) : super(const ChildrenBuildable());
  final HomeRepository _repo;

  Future<void> getChildren() {
    return callable(
      future: _repo.getChildren(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      // invokeOnData: (data) => ChildrenListenable(
      //   effect: data ? ChildrenEffect.verify : ChildrenEffect.reg,
      // ),
      buildOnData: (data) {
        return buildable.copyWith(childrenList: data);
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

// void changePhoneState(bool isMatched) {
//   build((buildable) => buildable.copyWith(isSelected: isMatched));
// }
}
