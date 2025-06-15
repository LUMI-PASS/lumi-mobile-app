import 'package:founders_academy/core/mixin/code_auto_fill_mixin.dart';
import 'package:founders_academy/core/mixin/permanent_subscription_mixin.dart';
import 'package:founders_academy/feature/auth/data/model/otp_data.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/otp/otp_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class OtpCubit extends ChessCubit<OtpState>
    with CodeAutoFillMixin, PermanentSubscriptionMixin {
  OtpCubit() : super(OtpState(otpData: OtpData(codeHash: '')));

  Future<void> init() async {
    listenForCode();

    //  Use below code, if you need app signature
    // final appKey = await getAppSignature;
    // Clipboard.setData(ClipboardData(text: appKey));

    addPermanentSubscription(
      codeUpdates.listen((code) {
        safeEmit(
          state.copyWith(
            otpTextField: state.otpTextField.copyWith(value: code),
          ),
        );
        listenForCode();
      }),
    );
  }

  @override
  void dispose() {
    unregisterListener();
    super.dispose();
  }
}
