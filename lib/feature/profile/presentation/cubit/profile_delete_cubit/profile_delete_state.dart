import 'package:lumi_pass/feature/shared/presentation/text_field_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_delete_state.freezed.dart';

@freezed
class ProfileDeleteState with _$ProfileDeleteState {
  ProfileDeleteState._();

  factory ProfileDeleteState({
    @Default(false) bool isDeleted,
    @Default('') String reasonType,
    @Default(TextFieldViewModel()) TextFieldViewModel reasonTextField,
  }) = _ProfileDeleteState;
}
