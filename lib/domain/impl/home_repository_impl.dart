import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';

import '../../data/storage/storage.dart';
import '../repo/home/home_api.dart';

@Injectable(as: HomeRepository)
class HomeRepositoryImpl extends HomeRepository {
  final HomeApi _api;
  final Storage _storage;
  String? parentId;

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
  Future<List<ChildModel>> getChildren() {
    return _api.getProfileData().then((value) {
      _storage.parentId.set(value.data['data']['profile']['id']);
      return (value.data['data']['children'] as List)
          .map((e) => ChildModel.fromJson(e))
          .toList();
    });
  }

  @override
  Future<void> addChild(ChildModel childModel) {
    return _api.addChild(childModel, _storage.parentId.call()!);
  }

  @override
  Future<void> updateChild(ChildModel childModel, String parentId) {
    return _api.updateChild(childModel, parentId);
  }

  @override
  Future<List<Tariff>> getTariffs() {
    return _api.getTariffs().then((value) {
      return (value.data['data'] as List)
          .map((e) => Tariff.fromJson(e))
          .toList();
    });
  }

  @override
  Future<List<HomCategory>> getAllCategories() {
    return _api.getCategories().then((value) {
      return (value.data['data'] as List)
          .map((e) => HomCategory.fromJson(e))
          .toList();
    });
  }

  @override
  Future<void> purchaseSubscription(String tariffId) {
    return _api.purchaseSubscription(tariffId);
  }

  @override
  Future<List<TimeSlot>> getCLassSchedules(
      String childId, String fromDate, String toDate, String classId) {
    return _api
        .getClassCategories(childId, fromDate, toDate, classId)
        .then((value) {
      return (value.data['data']['time_slots'] as List)
          .map((e) => TimeSlot.fromJson(e))
          .toList();
    });
  }
}
