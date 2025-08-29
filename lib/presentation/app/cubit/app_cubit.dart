import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'app_state.dart';

@injectable
class AppCubit extends BaseCubit<AppBuildable, AppListenable> {
  AppCubit(this._repo) : super(const AppBuildable()) {
    // _repo.getFirebaseToken();
  }

  final AuthRepository _repo;


  // void firebaseInit() {
  //   _repo.firebaseInit();
  // }
}
