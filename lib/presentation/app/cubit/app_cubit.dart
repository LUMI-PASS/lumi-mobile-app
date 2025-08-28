import 'package:flexobo/common/base/base_cubit.dart';
import 'package:flexobo/domain/repo/auth/auth_repository.dart';
import 'package:flexobo/presentation/profile/language/lang/language.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'app_state.dart';

@injectable
class AppCubit extends BaseCubit<AppBuildable, AppListenable> {
  AppCubit(this._repo) : super(const AppBuildable()) {
    _repo.getFirebaseToken();
  }

  final AuthRepository _repo;

  void selectLanguage(Language language) {
    build((buildable) => buildable.copyWith(language: language));
  }

  void firebaseInit() {
    _repo.firebaseInit();
  }
}
