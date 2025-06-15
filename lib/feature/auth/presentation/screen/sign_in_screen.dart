import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/auth/auth_state.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/country/country_cubit.dart';
import 'package:lumi_pass/feature/home/data/model/notification/notification_data.dart';
import 'package:lumi_pass/feature/home/presentation/widget/banner/custom_notification_view.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SignInScreen extends StatefulWidget implements AutoRouteWrapper {
  const SignInScreen({super.key});

  @override
  Widget wrappedRoute(context) {
    return BlocProvider(
      create: (context) => CountryCubit(),
      child: this,
    );
  }

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

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
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countryCubit = context.read<CountryCubit>();

    return BlocBuilder<CountryCubit, Country?>(
      builder: (context, country) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24).copyWith(
                top: MediaQuery.of(context).padding.top,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     ChessUiKitAssets.images.logoPng
                          //         .image(width: 120, height: 120),
                          //   ],
                          // ),
                          // const SizedBox(height: 16),
                          Text(
                            "Kirish",
                            style: context.textTheme.largeTitle3Bold,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Telefon raqamingizni kiriting",
                            style: context.textTheme.subheadlineRegular,
                          ),
                          const SizedBox(height: 24),
                          ChessTextField.phone(
                            autofocus: true,
                            placeholder: "Telefon raqam",
                            focusNode: _phoneFocusNode,
                            controller: _phoneController,
                            onCountrySelect: countryCubit.setCountry,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: !countryCubit.isLocalCountry
                                ? Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      ChessTextField(
                                        showClearButton: true,
                                        label: "Email",
                                        placeholder: "name@email.uz",
                                        focusNode: _emailFocusNode,
                                        controller: _emailController,
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ChessButton.primary(
                        label: "Davom etish",
                        background: ChessColors.primaryDefault,
                        onPressed: () => _onPressed(countryCubit: countryCubit),
                      ),
                      const SizedBox(height: 16),
                      ChessMarkdownSheet(
                        sheetTitle: "Foydalanuvchi shartlari",
                        asset: ChessUiKitAssets.markdown.policy,
                        text: "Davom etish uchun siz {Foydalanuvchi shartlari} "
                            "ga rozi bo'lishingiz kerak",
                      ),
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

  Future<void> _onPressed({required CountryCubit countryCubit}) async {
    final authCubit = context.read<AuthCubit>();
    final router = context.router;

    await authCubit.sendOtp(
      _phoneController.text.formatPhone(countryCubit.state)!,
      countryCubit.userType,
      _emailController.text.trim(),
    );

    if (authCubit.state is AuthOtpSentState) {
      final state = authCubit.state as AuthOtpSentState;
      state.otpData.phoneNumber = _phoneController.text.isNotEmpty
          ? _phoneController.text.formatPhone(countryCubit.state)
          : null;

      state.otpData.email = _emailController.text.isNotEmpty
          ? _emailController.text.trim()
          : null;

      router.push(
        OtpRoute(otpData: state.otpData, userType: countryCubit.userType),
      );
      CustomNotificationManager.show(
          context: context,
          message: "Otp code: ${state.otpData.code}",
          type: DisplayType.success);
    }

    if (authCubit.state is AuthLoadedState) {
      router.replaceAll([const AuthorizedContainerRoute()]);
    }
  }
}
