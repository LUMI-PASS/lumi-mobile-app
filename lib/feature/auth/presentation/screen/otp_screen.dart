import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/feature/auth/data/model/otp_data.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/auth/auth_state.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/otp/otp_cubit.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/otp/otp_state.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/timer/timer_cubit.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

@RoutePage()
class OtpScreen extends StatefulWidget implements AutoRouteWrapper {
  final OtpData otpData;
  final UserType userType;

  const OtpScreen({
    super.key,
    required this.otpData,
    required this.userType,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerCubit(),
      child: this,
    );
  }

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerCubit = context.read<TimerCubit>();
    String emailCredential = "${widget.otpData.email} manziliga";
    String phoneCredential = "${widget.otpData.phoneNumber
        ?.getMaskedFormat} raqamiga";
    bool emailInUse = widget.otpData.email != null;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 72,
      textStyle:
      context.textTheme.title2Bold.copyWith(color: ChessColors.greyG900),
      decoration: BoxDecoration(
        color: ChessColors.greyG30,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return BlocConsumer<AuthCubit, AuthState>(
      listener: _authListener,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: context.router.pop,
              child: ChessUiKitAssets.icons.general.arrowLeft
                  .svg(fit: BoxFit.none, color: ChessColors.greyG10),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20).copyWith(top: 4),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        "Tasdiqlash kodi",
                        style: context.textTheme.largeTitle3Bold,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tasdiqlash kodini "
                            "${!emailInUse
                            ? phoneCredential
                            : emailCredential} "
                            "yuborildi.",
                        style: context.textTheme.subheadlineRegular,
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<OtpCubit, OtpState>(
                        builder: (context, otpState) {
                          return _PinputWidget(
                            otpState: otpState,
                            otpData: widget.otpData,
                            readOnly: state is AuthLoadingState,
                            defaultPinTheme: defaultPinTheme,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          children: [
                            if (state is AuthErrorState)
                              _IncorrectOtpMessage(state.exception.toString()),
                            if (state is AuthIncorrectOtpState)
                              const _IncorrectOtpMessage(
                                'Tasdiqlash kodi noto\'g\'ri. '
                                    'Iltimos, yana bir bor urinib ko\'ring.',
                              ),
                          ],
                        ),
                      ),
                      BlocBuilder<TimerCubit, String>(
                        builder: (context, timerState) {
                          String timerValue =
                          timerCubit.isProcessing ? timerState : timerCubit
                              .empty;

                          return ChessLinkedText(
                            onLinkTap: () => _onLinkTap(context, timerCubit),
                            text: "{Kodni qayta yuborish} $timerValue",
                            textStyle: context.textTheme.bodyMedium.copyWith(
                              color: timerCubit.isProcessing
                                  ? ChessColors.greyG70
                                  : ChessColors.greyG900,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _authListener(BuildContext context, AuthState state) {
    final router = context.router;

    if (state is AuthSignUpRequiredState) {
      router.push(const RegistrationContainerRoute());
    }

    if (state is AuthLoadedState) {
      router.replaceAll([const AuthorizedContainerRoute()]);
    }
  }

  void _onLinkTap(BuildContext context, TimerCubit cubit) async {
    if (!cubit.isProcessing) {
      await context
          .read<AuthCubit>()
          .sendOtp(
          widget.otpData.phoneNumber, widget.userType, widget.otpData.email);

      cubit.restartTimer();
    }
  }
}

class _IncorrectOtpMessage extends StatefulWidget {
  final String message;

  const _IncorrectOtpMessage(this.message);

  @override
  State<_IncorrectOtpMessage> createState() => _IncorrectOtpMessageState();
}

class _IncorrectOtpMessageState extends State<_IncorrectOtpMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    _shakeController.forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (_shakeAnimation.value < 0.5 ? _shakeAnimation.value : 1 -
                _shakeAnimation.value) *
                20 * (1 - _shakeAnimation.value),
            0,
          ),
          child: FadeTransition(
            opacity: _shakeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.subheadlineRegular.copyWith(
                    color: ChessColors.errorDefault,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PinputWidget extends StatefulWidget {
  final OtpState otpState;
  final OtpData otpData;
  final PinTheme defaultPinTheme;
  final bool readOnly;

  const _PinputWidget({
    required this.otpState,
    required this.otpData,
    required this.defaultPinTheme,
    this.readOnly = false,
  });

  @override
  State<_PinputWidget> createState() => _PinputWidgetState();
}

class _PinputWidgetState extends State<_PinputWidget>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final otpTextFieldValue = widget.otpState.otpTextField.value;

    if (otpTextFieldValue != _controller.text) {
      final value = widget.otpState.otpTextField.value;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (value.isEmpty) {
          _controller.clear();
        } else {
          _controller.text = value;
        }
      });
    }

    return Builder(builder: (context)
    {
      if (widget.readOnly) {
        return const ChessCircularProgressIndicator();
      } else {
        return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return Pinput(
                controller: _controller,
                length: 6,
                autofocus: true,
                readOnly: widget.readOnly,
                cursor: const ColoredBox(
                  color: ChessColors.primaryDefault,
                  child: SizedBox(height: 24, width: 3),
                ),
                onCompleted: (value) {
                  OtpData localOtpData = widget.otpData;
                  final currentAuthState = authState;
                  if (currentAuthState is AuthOtpSentState) {
                    localOtpData.updateCodeHash =
                        currentAuthState.otpData.codeHash;
                  }
                  final data = Map<String, dynamic>.from(localOtpData.toJson());
                  data["code"] = int.parse(value);

                  context.read<AuthCubit>().login(OtpData.fromJson(data));
                },
                defaultPinTheme: widget.defaultPinTheme,
                focusedPinTheme: widget.defaultPinTheme.copyDecorationWith(
                  color: ChessColors.greyG40,
                ),
              );

            });
      }
    }
    );}
}