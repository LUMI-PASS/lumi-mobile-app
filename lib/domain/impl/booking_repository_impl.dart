import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';
import 'package:lumi_pass/domain/repo/booking/booking_api.dart';

import '../../data/storage/storage.dart';
import '../repo/booking/booking_repository.dart';
import '../repo/home/home_api.dart';

@Injectable(as: BookingRepository)
class BookingRepositoryImpl extends BookingRepository {
  final BookingApi _api;
  final Storage _storage;

  BookingRepositoryImpl(this._api, this._storage);

  @override
  Future<List<Tariff>> getTariffs() {
    return _api.getTariffs().then((value) =>
        (value.data['data'] as List).map((e) => Tariff.fromJson(e)).toList());
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
        .then((value) => HomForUser.fromJson(value.data['data']['profile']));
  }

  @override
  Future<bool> updateUser(HomForUser user) async {
    try {
      await _api.updateProfileData(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<HomeModel> getChildren() {
    return _api.getChildren().then((value) => HomeModel.fromJson(value.data));
  }
}
