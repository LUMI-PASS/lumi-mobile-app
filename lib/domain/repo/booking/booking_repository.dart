import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';

abstract class BookingRepository {
  Future<List<Tariff>> getTariffs();

  Future<HomeModel> getChildren();

  Future<HomForUser> getProfileData();

  Future<List<ScheduleItem>> getScheduleList();

  Future<bool> updateUser(HomForUser user);
}
