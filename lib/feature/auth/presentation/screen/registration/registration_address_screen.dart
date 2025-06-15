import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/profile_creation/profile_creation_cubit.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/registration/registration_cubit.dart';
import 'package:founders_academy/feature/auth/presentation/cubit/registration/registration_state.dart';
import 'package:founders_academy/feature/auth/shared/screen/registration_wrapper_screen.dart';
import 'package:founders_academy/feature/auth/shared/widget/selector_field.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RegistrationAddressScreen extends StatelessWidget {
  const RegistrationAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationCubit, RegistrationState>(
      builder: (context, state) {
        return RegistrationWrapperScreen(
          title: 'Manzil',
          subtitle: 'Manzilingizni doir ma\'lumotlarni kiriting',
          body: _BodyContent(state),
          primaryButtonLabel: 'Davom etish',
          onPrimaryButtonTap: state.isAddressDetailsExist
              ? () => _onNextButtonTap(context, state: state)
              : null,
        );
      },
    );
  }

  void _onNextButtonTap(
    BuildContext context, {
    required RegistrationState state,
  }) {
    if (!state.addressCountry!.isUzbekistan) {
      final cubit = context.read<ProfileCreationCubit>();
      final user = state.getUserDetails;
      user.education = null;
      cubit.createProfile(user);
      cubit.stream.listen((state) {
        if (state is ProfileCreationFinishedState) {
          context.router.replaceAll([const RegistrationSuccessRoute()]);
        }
      });
    } else {
      context.router.push(const RegistrationEducationRoute());
    }
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
        AddressSelector.country(
          title: "Mamlakatni tanlang",
          textStyle: context.textTheme.bodyRegular,
          onItemSelect: cubit.onCountrySelected,
          selectedCountry: state.addressCountry,
          builder: (context) => SelectorField(
            placeholder: "Mamlakat",
            value: state.addressCountry?.name,
          ),
        ),
        if (state.addressCountry != null) ...[
          const SizedBox(height: 10),
          AddressSelector.region(
            countryId: state.addressCountry?.id,
            title: "Hududni tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onAddressRegionSelected,
            selectedRegion: state.addressRegion,
            builder: (context) => SelectorField(
              placeholder: "Hudud",
              value: state.addressRegion?.name,
            ),
          ),
        ],
        if (state.isRegionExist) ...[
          const SizedBox(height: 10),
          AddressSelector.district(
            regionId: state.addressRegion?.id,
            title: "Tumanni tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onAddressDistrictSelected,
            selectedDistrict: state.addressDistrict,
            builder: (context) => SelectorField(
              placeholder: "Tuman",
              value: state.addressDistrict?.name,
            ),
          ),
        ],
        if (state.isDistrictExist) ...[
          const SizedBox(height: 10),
          AddressSelector.neighborhood(
            districtId: state.addressDistrict?.id,
            title: "Mahallani tanlang",
            textStyle: context.textTheme.bodyRegular,
            onItemSelect: cubit.onNeighborhoodSelected,
            selectedNeighborhood: state.addressNeighborhood,
            builder: (context) => SelectorField(
              placeholder: "Mahalla",
              value: state.addressNeighborhood?.name,
            ),
          ),
        ]
      ],
    );
  }
}
