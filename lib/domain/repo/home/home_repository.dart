import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';

abstract class HomeRepository {
  Future<HomeModel> getHome();

  Future<HomForUser> getProfileData();

  Future<List<ScheduleItem>> getScheduleList();
}
