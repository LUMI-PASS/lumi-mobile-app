import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    @JsonKey(name: "_id")
    String? id,
    String? fio,
    String? email,
    @JsonKey(name: "phone_number")
    String? phoneNumber,
    String? country,
    String? city,
    String? role,
    String? status,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
