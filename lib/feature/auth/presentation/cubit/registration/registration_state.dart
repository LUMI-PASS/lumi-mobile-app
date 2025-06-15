import 'package:lumi_pass/feature/profile/data/model/profile_data.dart';
import 'package:lumi_pass/feature/shared/presentation/text_field_view_model.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_state.freezed.dart';

@freezed
class RegistrationState with _$RegistrationState {
  RegistrationState._();

  factory RegistrationState({
    @Default(TextFieldViewModel()) TextFieldViewModel nameTextField,
    @Default(TextFieldViewModel()) TextFieldViewModel surnameTextField,
    Country? addressCountry,
    Region? addressRegion,
    District? addressDistrict,
    Neighborhood? addressNeighborhood,
    EducationType? educationType,
    Region? educationRegion,
    District? educationDistrict,
    School? school,
    College? college,
    University? university,
  }) = _RegistrationState;

  late final bool isPersonalInfoValid =
      nameTextField.value.isNotEmpty && surnameTextField.value.isNotEmpty;

  late final bool isRegionExist =
      (addressCountry?.isUzbekistan ?? false) && addressRegion != null;

  late final bool isDistrictExist =
      (addressCountry?.isUzbekistan ?? false) && addressDistrict != null;

  late final bool isUniversity =
      ((educationType?.isUniversity ?? false) && educationRegion != null);

  late final bool isSchool =
      ((educationType?.isSchool ?? false) && educationDistrict != null);

  late final bool isCollege =
      ((educationType?.isCollege ?? false) && educationDistrict != null);

  late final bool showEducationDistrict =
      educationRegion != null && !(educationType?.isUniversity ?? false);

  bool get isAddressDetailsExist {
    final currentCountry = addressCountry;
    if (currentCountry == null) return false;

    final bool isLocalAddressExist = addressRegion != null &&
        addressDistrict != null &&
        addressNeighborhood != null;

    final bool isInternationalAddressExist = addressRegion != null;

    return currentCountry.isUzbekistan
        ? isLocalAddressExist
        : isInternationalAddressExist;
  }

  bool get isEducationDetailsExist {
    if (educationType == null) return false;

    final isUniversity = (educationType?.isUniversity ?? false);

    final isSchoolOrCollege = (educationType?.isCollege ?? false) ||
        (educationType?.isSchool ?? false);

    bool isHighDegree =
        isUniversity && educationRegion != null && university != null;

    bool isSchoolDegree = isSchoolOrCollege &&
        educationRegion != null &&
        educationDistrict != null &&
        (school != null || college != null);

    return isHighDegree || isSchoolDegree;
  }

  ProfileData get getUserDetails {
    return ProfileData(
      firstName: nameTextField.value,
      lastName: surnameTextField.value,
      // address: _getAddressDetails,
      // education: _getEducationDetails,
    );
  }

  // AddressData get _getAddressDetails {
  //   return AddressData(
  //     country: addressCountry?.name,
  //     region: addressRegion?.name,
  //     district: addressDistrict?.name,
  //     neighborhood: addressNeighborhood?.name,
  //   );
  // }

  // EducationData get _getEducationDetails {
  //   String? organization;
  //
  //   if (school != null) organization = school?.name ?? "";
  //   if (college != null) organization = college?.name ?? "";
  //   if (university != null) organization = university?.name ?? "";
  //
  //   return EducationData(
  //     type: educationType?.type,
  //     region: educationRegion?.name,
  //     district: educationDistrict?.name,
  //     organization: organization,
  //   );
  // }
}

extension ResetFields on RegistrationState {
  RegistrationState resetAddressDistrictState() {
    return copyWith(addressNeighborhood: null);
  }

  RegistrationState resetAddressCountryState() {
    return copyWith(
      addressRegion: null,
      addressDistrict: null,
      addressNeighborhood: null,
    );
  }

  RegistrationState resetAddressRegionState() {
    return copyWith(addressDistrict: null, addressNeighborhood: null);
  }

  RegistrationState resetEducationTypeState() {
    return copyWith(
      educationRegion: null,
      educationDistrict: null,
      school: null,
      college: null,
      university: null,
    );
  }

  RegistrationState resetEducationRegionState() {
    return copyWith(
      educationDistrict: null,
      school: null,
      college: null,
      university: null,
    );
  }

  RegistrationState resetEducationDistrictState() {
    return copyWith(school: null, college: null, university: null);
  }

  RegistrationState resetSchoolState() {
    return copyWith(college: null, university: null);
  }

  RegistrationState resetCollegeState() {
    return copyWith(school: null, university: null);
  }

  RegistrationState resetUniversityState() {
    return copyWith(school: null, college: null);
  }
}
