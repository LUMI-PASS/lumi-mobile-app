import 'package:lumi_pass/common/constants/constants.dart';

/// The served child photo. Only meaningful when `ChildModel.hasPhoto` is true —
/// the endpoint 404s otherwise. Same route the upload posts to.
String childPhotoUrl(String childId) =>
    '${Constants.baseUrl}assets/files/child-photo/$childId';
