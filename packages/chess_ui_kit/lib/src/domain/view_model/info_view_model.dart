import 'package:chess_ui_kit/src/domain/view_model/base_info_view_model.dart';

class InfoViewModel implements BaseInfoViewModel {
  @override
  final String id;
  @override
  final String name;
  final int? regionsId;
  final String? countryCode;
  final String? organizationType;

  InfoViewModel({
    required this.id,
    required this.name,
    this.countryCode,
    this.regionsId,
    this.organizationType,
  });

  factory InfoViewModel.fromJson(Map<String, dynamic> json) {
    return InfoViewModel(
      id: json['id'] is int ? json['id'].toString() : json['id'],
      name: json['name'],
      countryCode: json['country_code'],
      regionsId: json['regions_id'],
      organizationType: json['type'],
    );
  }
}
