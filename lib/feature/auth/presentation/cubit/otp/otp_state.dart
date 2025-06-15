import 'package:lumi_pass/feature/auth/data/model/otp_data.dart';
import 'package:lumi_pass/feature/shared/presentation/text_field_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_state.freezed.dart';

@freezed
class OtpState with _$OtpState {
  OtpState._();

  factory OtpState({
    @Default(false) bool isLoading,
    required OtpData otpData,
    @Default(TextFieldViewModel()) TextFieldViewModel otpTextField,
  }) = _OtpState;
}
