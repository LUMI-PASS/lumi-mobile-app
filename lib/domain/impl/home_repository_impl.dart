import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';

import '../../data/storage/storage.dart';
import '../repo/home/home_api.dart';

@Injectable(as: HomeRepository)
class HomeRepositoryImpl extends HomeRepository {
  final HomeApi _api;
  final Storage _storage;

  HomeRepositoryImpl(this._api, this._storage);

  @override
  Future<HomeModel> getHome() {
    return _api.getHome().then((value) => HomeModel.fromJson(value.data));
  }

  @override
  Future<List<ScheduleItem>> getScheduleList() {
    return _api
        .getSchedule()
        .then((value) => ScheduleModel.fromJson(value.data).data ?? []);
  }

  @override
  Future<HomForUser> getProfileData() {
    return _api
        .getProfileData()
        .then((value) => HomForUser.fromJson(value.data));
  }
}
