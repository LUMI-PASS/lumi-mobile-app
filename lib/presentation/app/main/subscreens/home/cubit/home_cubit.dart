import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'home_state.dart';
import 'package:location/location.dart';

@injectable
class HomeCubit extends BaseCubit<HomeBuildable, HomeListenable> {
  HomeCubit(this._repo) : super(const HomeBuildable());
  final HomeRepository _repo;

  Future<void> getHome() async {
    Location location = const Location();
    // try{
    //   final bool _serviceEnabled = await location.requestPermission();
    //
    //   if(_serviceEnabled){
    //     final Position? position = await location.getCurrentLocation();
    //     if (position != null) {
    //       print(position.latitude);
    //       print(position.longitude);
    //     }
    //   }
    // }catch(e){
    //   print("error: $e");
    // }
    return callable(
      future: _repo.getHome(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      // invokeOnData: (data) => HomeListenable(
      //   effect: data ? HomeEffect.verify : HomeEffect.reg,
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

  Future<void> getCategories() async {
    // Location location = const Location();
    return callable(
      future: _repo.getAllCategories(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      // invokeOnData: (data) => HomeListenable(
      //   effect: data ? HomeEffect.verify : HomeEffect.reg,
      // ),
      buildOnData: (data) {
        return buildable.copyWith(categories: data);
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

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
