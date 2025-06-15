// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_field_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TextFieldViewModel {
  String get initialValue => throw _privateConstructorUsedError;
  bool get isValidValue => throw _privateConstructorUsedError;
  String get invalidMessage => throw _privateConstructorUsedError;
  String get hintText => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  int? get maxLength => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TextFieldViewModelCopyWith<TextFieldViewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextFieldViewModelCopyWith<$Res> {
  factory $TextFieldViewModelCopyWith(
          TextFieldViewModel value, $Res Function(TextFieldViewModel) then) =
      _$TextFieldViewModelCopyWithImpl<$Res, TextFieldViewModel>;
  @useResult
  $Res call(
      {String initialValue,
      bool isValidValue,
      String invalidMessage,
      String hintText,
      String value,
      bool enabled,
      int? maxLength});
}

/// @nodoc
class _$TextFieldViewModelCopyWithImpl<$Res, $Val extends TextFieldViewModel>
    implements $TextFieldViewModelCopyWith<$Res> {
  _$TextFieldViewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialValue = null,
    Object? isValidValue = null,
    Object? invalidMessage = null,
    Object? hintText = null,
    Object? value = null,
    Object? enabled = null,
    Object? maxLength = freezed,
  }) {
    return _then(_value.copyWith(
      initialValue: null == initialValue
          ? _value.initialValue
          : initialValue // ignore: cast_nullable_to_non_nullable
              as String,
      isValidValue: null == isValidValue
          ? _value.isValidValue
          : isValidValue // ignore: cast_nullable_to_non_nullable
              as bool,
      invalidMessage: null == invalidMessage
          ? _value.invalidMessage
          : invalidMessage // ignore: cast_nullable_to_non_nullable
              as String,
      hintText: null == hintText
          ? _value.hintText
          : hintText // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      maxLength: freezed == maxLength
          ? _value.maxLength
          : maxLength // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TextFieldViewModelImplCopyWith<$Res>
    implements $TextFieldViewModelCopyWith<$Res> {
  factory _$$TextFieldViewModelImplCopyWith(_$TextFieldViewModelImpl value,
          $Res Function(_$TextFieldViewModelImpl) then) =
      __$$TextFieldViewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String initialValue,
      bool isValidValue,
      String invalidMessage,
      String hintText,
      String value,
      bool enabled,
      int? maxLength});
}

/// @nodoc
class __$$TextFieldViewModelImplCopyWithImpl<$Res>
    extends _$TextFieldViewModelCopyWithImpl<$Res, _$TextFieldViewModelImpl>
    implements _$$TextFieldViewModelImplCopyWith<$Res> {
  __$$TextFieldViewModelImplCopyWithImpl(_$TextFieldViewModelImpl _value,
      $Res Function(_$TextFieldViewModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialValue = null,
    Object? isValidValue = null,
    Object? invalidMessage = null,
    Object? hintText = null,
    Object? value = null,
    Object? enabled = null,
    Object? maxLength = freezed,
  }) {
    return _then(_$TextFieldViewModelImpl(
      initialValue: null == initialValue
          ? _value.initialValue
          : initialValue // ignore: cast_nullable_to_non_nullable
              as String,
      isValidValue: null == isValidValue
          ? _value.isValidValue
          : isValidValue // ignore: cast_nullable_to_non_nullable
              as bool,
      invalidMessage: null == invalidMessage
          ? _value.invalidMessage
          : invalidMessage // ignore: cast_nullable_to_non_nullable
              as String,
      hintText: null == hintText
          ? _value.hintText
          : hintText // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      maxLength: freezed == maxLength
          ? _value.maxLength
          : maxLength // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$TextFieldViewModelImpl implements _TextFieldViewModel {
  const _$TextFieldViewModelImpl(
      {this.initialValue = '',
      this.isValidValue = true,
      this.invalidMessage = 'Malumot kiritilishi shart',
      this.hintText = '',
      this.value = '',
      this.enabled = true,
      this.maxLength});

  @override
  @JsonKey()
  final String initialValue;
  @override
  @JsonKey()
  final bool isValidValue;
  @override
  @JsonKey()
  final String invalidMessage;
  @override
  @JsonKey()
  final String hintText;
  @override
  @JsonKey()
  final String value;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final int? maxLength;

  @override
  String toString() {
    return 'TextFieldViewModel(initialValue: $initialValue, isValidValue: $isValidValue, invalidMessage: $invalidMessage, hintText: $hintText, value: $value, enabled: $enabled, maxLength: $maxLength)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextFieldViewModelImpl &&
            (identical(other.initialValue, initialValue) ||
                other.initialValue == initialValue) &&
            (identical(other.isValidValue, isValidValue) ||
                other.isValidValue == isValidValue) &&
            (identical(other.invalidMessage, invalidMessage) ||
                other.invalidMessage == invalidMessage) &&
            (identical(other.hintText, hintText) ||
                other.hintText == hintText) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.maxLength, maxLength) ||
                other.maxLength == maxLength));
  }

  @override
  int get hashCode => Object.hash(runtimeType, initialValue, isValidValue,
      invalidMessage, hintText, value, enabled, maxLength);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TextFieldViewModelImplCopyWith<_$TextFieldViewModelImpl> get copyWith =>
      __$$TextFieldViewModelImplCopyWithImpl<_$TextFieldViewModelImpl>(
          this, _$identity);
}

abstract class _TextFieldViewModel implements TextFieldViewModel {
  const factory _TextFieldViewModel(
      {final String initialValue,
      final bool isValidValue,
      final String invalidMessage,
      final String hintText,
      final String value,
      final bool enabled,
      final int? maxLength}) = _$TextFieldViewModelImpl;

  @override
  String get initialValue;
  @override
  bool get isValidValue;
  @override
  String get invalidMessage;
  @override
  String get hintText;
  @override
  String get value;
  @override
  bool get enabled;
  @override
  int? get maxLength;
  @override
  @JsonKey(ignore: true)
  _$$TextFieldViewModelImplCopyWith<_$TextFieldViewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
