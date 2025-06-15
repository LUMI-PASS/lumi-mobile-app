import 'package:founders_academy/feature/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class CountryCubit extends ChessCubit<Country?> {
  CountryCubit() : super(null);

  bool get isLocalCountry => state?.isUzbekistan ?? true;

  UserType get userType =>
      isLocalCountry ? UserType.local : UserType.international;

  void setCountry(Country? country) => safeEmit(country);
}
