import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';

part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ProfileModel({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    String? country,
    String? city,
    String? district,
    String? gender,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}
