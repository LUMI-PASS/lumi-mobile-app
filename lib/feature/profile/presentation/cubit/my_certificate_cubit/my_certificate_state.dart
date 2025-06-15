import 'package:founders_academy/feature/profile/data/model/my_certificate/my_certificate_data.dart';

sealed class MyCertificateState {
  const MyCertificateState();
}

class MyCertificateInitState extends MyCertificateState {
  const MyCertificateInitState();
}

class MyCertificateLoadedState extends MyCertificateState {
  final List<MyCertificateData> myCertificateData;

  MyCertificateLoadedState(this.myCertificateData);
}

class MyCertificateErrorState extends MyCertificateState {
  const MyCertificateErrorState();
}
