import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';

abstract class HomeRepository {
  Future<HomeModel> getHome();

  Future<List<ChildModel>> getChildren();

  Future<void> addChild(ChildModel childModel);

  Future<void> updateChild(ChildModel childModel, String parentId);

  Future<HomForUser> getProfileData();

  Future<List<ScheduleItem>> getScheduleList();

  Future<List<Tariff>> getTariffs();

  Future<bool> updateUser(HomForUser user);
}
