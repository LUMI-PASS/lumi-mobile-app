import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_delete/profile_delete_reason_data.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_delete_cubit/profile_delete_cubit.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_delete_cubit/profile_delete_state.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfileDeleteScreen extends StatefulWidget {
  const ProfileDeleteScreen({super.key});

  @override
  State<ProfileDeleteScreen> createState() => _ProfileDeleteScreenState();
}

class _ProfileDeleteScreenState extends State<ProfileDeleteScreen> {
  final _textFocusNode = FocusNode();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileDeleteCubit>(),
      child: BlocConsumer<ProfileDeleteCubit, ProfileDeleteState>(
        listener: (context, state) {
          if (state.isDeleted) {
            context.router.replaceAll(
              [
                const UnauthorizedContainerRoute(),
              ],
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: ChessColors.greyG20,
            appBar: AppBar(
              backgroundColor: ChessColors.greyG20,
              title: Text(
                "Hisobni o'chirish",
                style: context.textTheme.bodyMedium.copyWith(
                  color: ChessColors.greyG900,
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: GestureDetector(
                  onTap: context.router.pop,
                  child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nima uchun hisobingizni o'chirayotganizni ayta olasizmi?",
                    style: context.textTheme.headlineSemibold,
                  ),
                  const SizedBox(height: 20),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Foydalanmayapman",
                      style: context.textTheme.subheadlineRegular,
                    ),
                    value: 'not_using',
                    groupValue: state.reasonType,
                    activeColor: ChessColors.primaryDefault,
                    onChanged: (value) {
                      context
                          .read<ProfileDeleteCubit>()
                          .updateSelectedValue(value ?? "");
                    },
                  ),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Ilovani bildirishnomalari ko'p",
                      style: context.textTheme.subheadlineRegular,
                    ),
                    value: 'too_many_notifications',
                    groupValue: state.reasonType,
                    activeColor: ChessColors.primaryDefault,
                    onChanged: (value) {
                      context
                          .read<ProfileDeleteCubit>()
                          .updateSelectedValue(value ?? "");
                    },
                  ),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Texnik muammolar mavjud",
                      style: context.textTheme.subheadlineRegular,
                    ),
                    value: 'technical_issues',
                    groupValue: state.reasonType,
                    activeColor: ChessColors.primaryDefault,
                    onChanged: (value) {
                      context
                          .read<ProfileDeleteCubit>()
                          .updateSelectedValue(value ?? "");
                    },
                  ),
                  RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Boshqa",
                      style: context.textTheme.subheadlineRegular,
                    ),
                    value: 'other',
                    groupValue: state.reasonType,
                    activeColor: ChessColors.primaryDefault,
                    onChanged: (value) {
                      context
                          .read<ProfileDeleteCubit>()
                          .updateSelectedValue(value ?? "");
                    },
                  ),
                  if (state.reasonType.isNotEmpty)
                    ChessTextField(
                      onChanged: (text) {
                        context
                            .read<ProfileDeleteCubit>()
                            .updateTextValue(_textController.text);
                      },
                      height: 150,
                      maxLines: 5,
                      focusNode: _textFocusNode,
                      controller: _textController,
                      placeholder: "Shikoyatingizni tushuntiring",
                    ),
                  const SizedBox(height: 20),
                  const Spacer(),
                  ChessButton.primary(
                    onPressed: state.reasonType.isNotEmpty &&
                            _textController.text.isNotEmpty
                        ? () {
                            final reason = ProfileDeleteReasonData(
                              type: state.reasonType,
                              body: _textController.text,
                            );
                            _showDialog(
                              context,
                              () => context
                                  .read<ProfileDeleteCubit>()
                                  .profileDelete(reason),
                            );
                          }
                        : null,
                    label: "Hisobni o'chirish",
                    borderRadius: 16,
                    textStyle: context.textTheme.bodyMedium.copyWith(
                      color: ChessColors.white,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDialog(BuildContext context, VoidCallback onConfirm) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => ChessIosDialog(
          title: "Hisobni o'chirish",
          message: "Haqiqatan ham hisobni o'chirmoqchimisiz?",
          onConfirmTap: () {
            onConfirm();
            context.router.pop();
          },
          onBackTap: context.router.pop,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => ChessAndroidDialog(
          title: "Hisobni o'chirish",
          message: "Haqiqatan ham hisobni o'chirmoqchimisiz",
          onConfirmTap: () {
            onConfirm();
            context.router.pop();
          },
          onBackTap: context.router.pop,
        ),
      );
    }
  }
}
