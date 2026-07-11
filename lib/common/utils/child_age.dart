/// Age in whole years from an ISO `dob` (`2014-05-08`). Null when the date is
/// missing or unparseable — the API leaves `dob` empty for some children.
int? getAge(String? dob) {
  if (dob == null || dob.isEmpty) return null;
  try {
    final birthDate = DateTime.parse(dob);
    final now = DateTime.now();

    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age < 0 ? null : age;
  } catch (_) {
    return null;
  }
}

/// The inverse of [getAge] — the ISO birth date a child of [age] would have.
String dobForAge(int age) {
  final now = DateTime.now();
  final t = DateTime(now.year - age, now.month, now.day);
  return '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';
}
