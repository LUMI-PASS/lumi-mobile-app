import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/image_cubit/image_cubit.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/image_cubit/image_state.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/profile_cubit/profile_cubit.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/profile_cubit/profile_state.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

const _maxFileSize = 5242880;

@RoutePage()
class ProfileEditDetailScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String imageUrl;

  const ProfileEditDetailScreen({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageUrl,
    super.key,
  });

  @override
  State<ProfileEditDetailScreen> createState() =>
      _ProfileEditDetailScreenState();
}

class _ProfileEditDetailScreenState extends State<ProfileEditDetailScreen> {
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.firstName;
    _lastNameController.text = widget.lastName;
    _phoneNumberController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoadedState) {
          if (state.isProfileUpdated) {
            context.router.popUntilRouteWithName(
              ProfileRoute.name,
            );
          }
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();

        return Scaffold(

          appBar: AppBar(

            title: Text(
              "Mening ma'lumotlarim",
              style: context.textTheme.bodyMedium.copyWith(
                color: ChessColors.greyG10,
              ),
            ),
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: GestureDetector(
                onTap: context.router.pop,
                child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
                  height: 24,
                  width: 24,
                  color: ChessColors.white
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: GestureDetector(
                  onTap: () {
                    cubit.onSaveTap(
                      _firstNameController.text.trim(),
                      _lastNameController.text.trim(),
                    );
                  },
                  child: Text(
                    "Saqlash",
                    style: context.textTheme.subheadlineSemibold.copyWith(
                      color: ChessColors.primaryDefault,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24).copyWith(bottom: 16),
            child: Column(
              children: [
                _ProfilePhoto(widget.imageUrl),
                const SizedBox(height: 32),
                ChessTextField(
                  label: "Ism",
                  controller: _firstNameController,
                  focusNode: _firstNameFocusNode,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(
                      _lastNameFocusNode,
                    );
                  },
                ),
                const SizedBox(height: 16),
                ChessTextField(
                  label: "Familya",
                  controller: _lastNameController,
                  focusNode: _lastNameFocusNode,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(
                      _phoneNumberFocusNode,
                    );
                  },
                ),
                const SizedBox(height: 16),
                ChessTextField(
                  label: "Telefon Raqam",
                  focusNode: _phoneNumberFocusNode,
                  controller: _phoneNumberController,
                  readOnly: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  final String imageUrl;
  const _ProfilePhoto(this.imageUrl);

  Future<void> pickImage(ImageCubit cubit) async {
    try {
      final XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageTemporary = File(pickedFile.path);

        int fileSize = await imageTemporary.length();
        if (fileSize <= _maxFileSize) {
          cubit.uploadProfileImage(imageTemporary);
        }
      }
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ImageCubit>()..init(imageUrl),
      child: BlocConsumer<ImageCubit, ImageState>(
        listener: (context, state) {
          if (state is ImageLoadedState) {
            if (state.isImageUploaded) {
              context.read<ProfileCubit>().onImageUpdated(state.imageUrl);
            }
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => pickImage(context.read<ImageCubit>()),
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ChessColors.greyG20,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  switch (state) {
                    ImageLoadingState() => Container(
                        height: 80,
                        width: 80,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ChessColors.greyG40,
                        ),
                        child: const ChessCircularProgressIndicator()),
                    ImageLoadedState() => state.imageUrl.isNotEmpty
                        ? BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
                            builder: (context, baseUrlState) {
                              return Container(
                                height: 80,
                                width: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: ChessNetworkImage(
                                    imageUrl: state.imageUrl,
                                    fit: BoxFit.cover,
                                    baseUrl: baseUrlState.baseUrl,
                                  ),
                                ),
                              );
                            },
                          )
                        : CircleAvatar(
                            backgroundColor: ChessColors.white,
                            radius: 50,
                            child: Center(
                              child: ChessUiKitAssets.icons.profile.user.svg(
                                fit: BoxFit.cover,
                                height: 40,
                                width: 40,
                              ),
                            ),
                          ),
                    _ => CircleAvatar(
                        backgroundColor: ChessColors.white,
                        radius: 50,
                        child: Center(
                          child: ChessUiKitAssets.icons.profile.user.svg(
                            fit: BoxFit.cover,
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ),
                  },
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: ChessColors.primaryDefault,
                      child: ChessUiKitAssets.images.camere.svg(
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
