// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OtpState {
  bool get isLoading => throw _privateConstructorUsedError;
  OtpData get otpData => throw _privateConstructorUsedError;
  TextFieldViewModel get otpTextField => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OtpStateCopyWith<OtpState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpStateCopyWith<$Res> {
  factory $OtpStateCopyWith(OtpState value, $Res Function(OtpState) then) =
      _$OtpStateCopyWithImpl<$Res, OtpState>;
  @useResult
  $Res call({bool isLoading, OtpData otpData, TextFieldViewModel otpTextField});

  $TextFieldViewModelCopyWith<$Res> get otpTextField;
}

/// @nodoc
class _$OtpStateCopyWithImpl<$Res, $Val extends OtpState>
    implements $OtpStateCopyWith<$Res> {
  _$OtpStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? otpData = null,
    Object? otpTextField = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      otpData: null == otpData
          ? _value.otpData
          : otpData // ignore: cast_nullable_to_non_nullable
              as OtpData,
      otpTextField: null == otpTextField
          ? _value.otpTextField
          : otpTextField // ignore: cast_nullable_to_non_nullable
              as TextFieldViewModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TextFieldViewModelCopyWith<$Res> get otpTextField {
    return $TextFieldViewModelCopyWith<$Res>(_value.otpTextField, (value) {
      return _then(_value.copyWith(otpTextField: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OtpStateImplCopyWith<$Res>
    implements $OtpStateCopyWith<$Res> {
  factory _$$OtpStateImplCopyWith(
          _$OtpStateImpl value, $Res Function(_$OtpStateImpl) then) =
      __$$OtpStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, OtpData otpData, TextFieldViewModel otpTextField});

  @override
  $TextFieldViewModelCopyWith<$Res> get otpTextField;
}

/// @nodoc
class __$$OtpStateImplCopyWithImpl<$Res>
    extends _$OtpStateCopyWithImpl<$Res, _$OtpStateImpl>
    implements _$$OtpStateImplCopyWith<$Res> {
  __$$OtpStateImplCopyWithImpl(
      _$OtpStateImpl _value, $Res Function(_$OtpStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? otpData = null,
    Object? otpTextField = null,
  }) {
    return _then(_$OtpStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      otpData: null == otpData
          ? _value.otpData
          : otpData // ignore: cast_nullable_to_non_nullable
              as OtpData,
      otpTextField: null == otpTextField
          ? _value.otpTextField
          : otpTextField // ignore: cast_nullable_to_non_nullable
              as TextFieldViewModel,
    ));
  }
}

/// @nodoc

class _$OtpStateImpl extends _OtpState {
  _$OtpStateImpl(
      {this.isLoading = false,
      required this.otpData,
      this.otpTextField = const TextFieldViewModel()})
      : super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final OtpData otpData;
  @override
  @JsonKey()
  final TextFieldViewModel otpTextField;

  @override
  String toString() {
    return 'OtpState(isLoading: $isLoading, otpData: $otpData, otpTextField: $otpTextField)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.otpData, otpData) || other.otpData == otpData) &&
            (identical(other.otpTextField, otpTextField) ||
                other.otpTextField == otpTextField));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, otpData, otpTextField);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpStateImplCopyWith<_$OtpStateImpl> get copyWith =>
      __$$OtpStateImplCopyWithImpl<_$OtpStateImpl>(this, _$identity);
}

abstract class _OtpState extends OtpState {
  factory _OtpState(
      {final bool isLoading,
      required final OtpData otpData,
      final TextFieldViewModel otpTextField}) = _$OtpStateImpl;
  _OtpState._() : super._();

  @override
  bool get isLoading;
  @override
  OtpData get otpData;
  @override
  TextFieldViewModel get otpTextField;
  @override
  @JsonKey(ignore: true)
  _$$OtpStateImplCopyWith<_$OtpStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
