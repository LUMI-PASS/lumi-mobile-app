import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_field_view_model.freezed.dart';

@freezed
class TextFieldViewModel with _$TextFieldViewModel {
  const factory TextFieldViewModel({
    @Default('') String initialValue,
    @Default(true) bool isValidValue,
    @Default('Malumot kiritilishi shart') String invalidMessage,
    @Default('') String hintText,
    @Default('') String value,
    @Default(true) bool enabled,
    int? maxLength,
  }) = _TextFieldViewModel;
}
