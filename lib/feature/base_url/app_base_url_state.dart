import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_base_url_state.freezed.dart';

@freezed
class AppBaseUrlState with _$AppBaseUrlState {
  AppBaseUrlState._();

  factory AppBaseUrlState({
    @Default('') String baseUrl,
  }) = _AppBaseUrlState;
}
