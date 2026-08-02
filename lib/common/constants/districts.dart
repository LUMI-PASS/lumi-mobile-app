import 'package:easy_localization/easy_localization.dart';

/// A Tashkent district, as the search filter offers it.
///
/// [key] is the slug the backend stores on a branch and matches on — never a
/// display name, so a translation change can't break the filter. Mirrors
/// `src/constants/districts.ts` on the backend; the two lists must stay in step.
class TashkentDistrict {
  const TashkentDistrict(this.key, this._labelKey);

  final String key;
  final String _labelKey;

  /// Localized name, from `translations.csv`.
  String get label => _labelKey.tr();
}

/// The 12 districts, in the order the filter shows them (alphabetical by slug —
/// no district is more important than another, so anything else would imply a
/// ranking we don't have).
const List<TashkentDistrict> kTashkentDistricts = [
  TashkentDistrict('bektemir', 'district_bektemir'),
  TashkentDistrict('chilonzor', 'district_chilonzor'),
  TashkentDistrict('mirobod', 'district_mirobod'),
  TashkentDistrict('mirzo_ulugbek', 'district_mirzo_ulugbek'),
  TashkentDistrict('olmazor', 'district_olmazor'),
  TashkentDistrict('sergeli', 'district_sergeli'),
  TashkentDistrict('shayxontohur', 'district_shayxontohur'),
  TashkentDistrict('uchtepa', 'district_uchtepa'),
  TashkentDistrict('yakkasaroy', 'district_yakkasaroy'),
  TashkentDistrict('yangihayot', 'district_yangihayot'),
  TashkentDistrict('yashnobod', 'district_yashnobod'),
  TashkentDistrict('yunusobod', 'district_yunusobod'),
];
