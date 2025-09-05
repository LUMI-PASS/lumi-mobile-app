import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

@freezed
class ChildModel with _$ChildModel {
  const factory ChildModel({
    String? id,
    @JsonKey(name: "first_name") String? firstName,
    @JsonKey(name: "last_name") String? lastName,
    @JsonKey(name: "phone_number") String? phoneNumber,
    String? dob,
    String? gender,
    String? type,
    @JsonKey(name: "child_age_type") String? childAgeType,
    String? city,
    String? district,
    @JsonKey(name: "is_verified") bool? isVerified,
    @JsonKey(name: "has_photo") bool? hasPhoto,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
    @JsonKey(name: "deleted_at") String? deletedAt,
    dynamic parent,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}
