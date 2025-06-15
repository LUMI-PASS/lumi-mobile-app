import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/profile_creation/profile_creation_cubit.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/registration/registration_cubit.dart';
import 'package:lumi_pass/feature/auth/presentation/cubit/registration/registration_state.dart';
import 'package:lumi_pass/feature/auth/shared/screen/registration_wrapper_screen.dart';
import 'package:lumi_pass/feature/auth/shared/widget/selector_field.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_data.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RegistrationEducationScreen extends StatelessWidget {
  const RegistrationEducationScreen({super.key});

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
            title: 'Ta\'lim',
            subtitle: 'Ta\'limga doir ma\'lumotlaringizni kiriting',
            body: _BodyContent(state),
            primaryButtonLabel: 'Davom etish',
            secondaryButtonLabel: 'Hozir o\'qimayman',
            onSecondaryButtonTap: () async {
              final profileData = state.getUserDetails;
              profileData.education = null;
              _onUserCreate(context, profileData: profileData);
            },
            onPrimaryButtonTap: state.isEducationDetailsExist
                ? () async {
                    final profileData = state.getUserDetails;
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

class _BodyContent extends StatelessWidget {
  final RegistrationState state;

  const _BodyContent(this.state);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EducationSelector.educationType(
          title: "Tashkilot turini tanlang",
          textStyle: context.textTheme.bodyRegular,
          onTypeSelect: cubit.onEducationTypeSelected,
          selectedType: state.educationType,
          builder: (context) => SelectorField(
            placeholder: "Tashkilot turi",
            value: state.educationType?.name,
          ),
        ),
        if (state.educationType != null) ...[
          const SizedBox(height: 10),
          AddressSelector.region(
            countryId: state.addressCountry?.id,
            title: "Hududni tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onEducationRegionSelected,
            selectedRegion: state.educationRegion,
            builder: (context) => SelectorField(
              placeholder: "Hudud",
              value: state.educationRegion?.name,
            ),
          ),
        ],
        if (state.showEducationDistrict) ...[
          const SizedBox(height: 10),
          AddressSelector.district(
            regionId: state.educationRegion?.id,
            title: "Tumanni tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onEducationDistrictSelected,
            selectedDistrict: state.educationDistrict,
            builder: (context) => SelectorField(
              placeholder: "Tuman",
              value: state.educationDistrict?.name,
            ),
          ),
        ],
        if (state.isSchool) ...[
          const SizedBox(height: 10),
          EducationSelector.school(
            districtId: state.educationDistrict?.id,
            title: "Maktabni tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onSchoolSelected,
            selectedSchool: state.school,
            builder: (context) => SelectorField(
              placeholder: "Maktab",
              value: state.school?.name,
            ),
          ),
        ],
        if (state.isCollege) ...[
          const SizedBox(height: 10),
          EducationSelector.college(
            districtId: state.educationDistrict?.id,
            title: "Kollej yoki Litseyni tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onCollegeSelected,
            selectedCollege: state.college,
            builder: (context) => SelectorField(
              placeholder: "Kollej/Litsey",
              value: state.college?.name,
            ),
          ),
        ],
        if (state.isUniversity) ...[
          const SizedBox(height: 10),
          EducationSelector.university(
            regionId: state.educationRegion?.id,
            title: "Universitetni tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onUniversitySelected,
            selectedUniversity: state.university,
            builder: (context) => SelectorField(
              placeholder: "Universitet",
              value: state.university?.name,
            ),
          ),
        ]
      ],
    );
  }
}
