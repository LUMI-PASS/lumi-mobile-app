import 'package:lumi_pass/feature/auth/presentation/cubit/registration/registration_state.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class RegistrationCubit extends ChessCubit<RegistrationState> {
  RegistrationCubit() : super(RegistrationState());

  void onNameChanged(String value) {
    safeEmit(
      state.copyWith(
        nameTextField: state.nameTextField.copyWith(
          isValidValue: true,
          value: value,
        ),
      ),
    );
  }

  void onSurnameChanged(String value) {
    safeEmit(
      state.copyWith(
        surnameTextField: state.surnameTextField.copyWith(
          isValidValue: true,
          value: value,
        ),
      ),
    );
  }

  void onCountrySelected(Country? value) {
    safeEmit(state.copyWith(addressCountry: value).resetAddressCountryState());
  }

  void onAddressRegionSelected(Region? value) {
    safeEmit(state.copyWith(addressRegion: value).resetAddressRegionState());
  }

  void onAddressDistrictSelected(District? value) {
    safeEmit(
        state.copyWith(addressDistrict: value).resetAddressDistrictState());
  }

  void onNeighborhoodSelected(Neighborhood? value) {
    safeEmit(state.copyWith(addressNeighborhood: value));
  }

  void onEducationTypeSelected(EducationType? value) {
    safeEmit(state.copyWith(educationType: value).resetEducationTypeState());
  }

  void onEducationRegionSelected(Region? value) {
    safeEmit(
        state.copyWith(educationRegion: value).resetEducationRegionState());
  }

  void onEducationDistrictSelected(District? value) {
    safeEmit(
      state.copyWith(educationDistrict: value).resetEducationDistrictState(),
    );
  }

  void onSchoolSelected(School? value) {
    safeEmit(state.copyWith(school: value).resetSchoolState());
  }

  void onCollegeSelected(College? value) {
    safeEmit(state.copyWith(college: value).resetCollegeState());
  }

  void onUniversitySelected(University? value) {
    safeEmit(state.copyWith(university: value).resetUniversityState());
  }
}
