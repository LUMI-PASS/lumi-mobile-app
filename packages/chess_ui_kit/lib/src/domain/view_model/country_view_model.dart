import 'package:chess_ui_kit/src/domain/view_model/base_info_view_model.dart';

class CountryViewModel implements BaseInfoViewModel {
  @override
  final String name;
  @override
  final String id;
  final String dialCode;
  final String flag;
  final String code;

  CountryViewModel({
    required this.name,
    required this.id,
    required this.dialCode,
    required this.flag,
    required this.code,
  });

  bool get isLocalCountry => code == "UZ";

  factory CountryViewModel.fromJson(Map<String, dynamic> json) {
    return CountryViewModel(
      name: json['name'],
      id: json['id'].toString(),
      dialCode: json['dial_code'],
      flag: json['flagPath'],
      code: json['code'],
    );
  }
}
