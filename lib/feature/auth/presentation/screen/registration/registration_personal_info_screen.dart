import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/profile_creation/profile_creation_cubit.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/registration/registration_cubit.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/registration/registration_state.dart';
import 'package:founders_academy/feature/auth/shared/screen/registration_wrapper_screen.dart';
import 'package:founders_academy/feature/profile/data/model/profile_data.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RegistrationPersonalInfoScreen extends StatelessWidget {
  const RegistrationPersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCreationCubit, ProfileCreationState>(
      listener: (context, state) {
        if (state is ProfileCreationFinishedState) {
          context.router.push(const RegistrationSuccessRoute());
        }
      },
      child: BlocBuilder<RegistrationCubit, RegistrationState>(
        builder: (context, state) {
          return RegistrationWrapperScreen(
            body: _BodyContent(state),
            title: "Shaxsiy ma'lumotlar",
            subtitle: "Shaxsiy ma'lumotlaringizni kiriting",
            primaryButtonLabel: "Ro'yxatdan o'tish",
            leadingIcon: const Icon(Icons.close, color: ChessColors.white),
            onPrimaryButtonTap: state.isPersonalInfoValid
                ? () async {
              final profileData = state.getUserDetails;
              profileData.education = null;
              _onUserCreate(context, profileData: profileData);
            }
                : null,
          );
        },
      ),
    );
  }

  void _onUserCreate(BuildContext context, {required ProfileData profileData}) {
    context.read<ProfileCreationCubit>().createProfile(profileData);
  }
}

class _BodyContent extends StatefulWidget {
  final RegistrationState state;

  const _BodyContent(this.state);

  @override
  State<_BodyContent> createState() => _BodyContentState();
}

class _BodyContentState extends State<_BodyContent>
    with TickerProviderStateMixin {
  final _nameFocusNode = FocusNode();
  final _surnameFocusNode = FocusNode();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  late AnimationController _fieldAnimationController;
  late Animation<double> _nameFieldAnimation;
  late Animation<double> _surnameFieldAnimation;

  @override
  void initState() {
    super.initState();

    _fieldAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _nameFieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fieldAnimationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _surnameFieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fieldAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    // Start field animations with delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fieldAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fieldAnimationController.dispose();
    _nameFocusNode.dispose();
    _surnameFocusNode.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _nameFieldAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _nameFieldAnimation.value)),
              child: Opacity(
                opacity: _nameFieldAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()
                    ..scale(_nameFocusNode.hasFocus ? 1.02 : 1.0),
                  child: ChessTextField(
                    label: "Ism",
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    isValueValid: widget.state.nameTextField.isValidValue,
                    onChanged: cubit.onNameChanged,
                    errorMessage: widget.state.nameTextField.invalidMessage,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _surnameFieldAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _surnameFieldAnimation.value)),
              child: Opacity(
                opacity: _surnameFieldAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()
                    ..scale(_surnameFocusNode.hasFocus ? 1.02 : 1.0),
                  child: ChessTextField(
                    label: "Familya",
                    controller: _surnameController,
                    focusNode: _surnameFocusNode,
                    isValueValid: widget.state.surnameTextField.isValidValue,
                    onChanged: cubit.onSurnameChanged,
                    textInputAction: TextInputAction.done,
                    errorMessage: widget.state.surnameTextField.invalidMessage,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}