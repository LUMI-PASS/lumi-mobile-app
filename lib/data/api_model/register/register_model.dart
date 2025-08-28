import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_model.g.dart';

part 'register_model.freezed.dart';

@freezed
class RegisterModel with _$RegisterModel {
  const factory RegisterModel({
    @JsonKey(name: 'phone_number') String? phoneNumber,
    String? email,
    String? password,
    String? fio,
    String? codeHash,
    int? code,
  }) = _RegisterModel;

  factory RegisterModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterModelFromJson(json);
}
