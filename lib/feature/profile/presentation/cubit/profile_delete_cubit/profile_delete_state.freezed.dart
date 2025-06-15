// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_delete_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileDeleteState {
  bool get isDeleted => throw _privateConstructorUsedError;
  String get reasonType => throw _privateConstructorUsedError;
  TextFieldViewModel get reasonTextField => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileDeleteStateCopyWith<ProfileDeleteState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileDeleteStateCopyWith<$Res> {
  factory $ProfileDeleteStateCopyWith(
          ProfileDeleteState value, $Res Function(ProfileDeleteState) then) =
      _$ProfileDeleteStateCopyWithImpl<$Res, ProfileDeleteState>;
  @useResult
  $Res call(
      {bool isDeleted, String reasonType, TextFieldViewModel reasonTextField});

  $TextFieldViewModelCopyWith<$Res> get reasonTextField;
}

/// @nodoc
class _$ProfileDeleteStateCopyWithImpl<$Res, $Val extends ProfileDeleteState>
    implements $ProfileDeleteStateCopyWith<$Res> {
  _$ProfileDeleteStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDeleted = null,
    Object? reasonType = null,
    Object? reasonTextField = null,
  }) {
    return _then(_value.copyWith(
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      reasonType: null == reasonType
          ? _value.reasonType
          : reasonType // ignore: cast_nullable_to_non_nullable
              as String,
      reasonTextField: null == reasonTextField
          ? _value.reasonTextField
          : reasonTextField // ignore: cast_nullable_to_non_nullable
              as TextFieldViewModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TextFieldViewModelCopyWith<$Res> get reasonTextField {
    return $TextFieldViewModelCopyWith<$Res>(_value.reasonTextField, (value) {
      return _then(_value.copyWith(reasonTextField: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileDeleteStateImplCopyWith<$Res>
    implements $ProfileDeleteStateCopyWith<$Res> {
  factory _$$ProfileDeleteStateImplCopyWith(_$ProfileDeleteStateImpl value,
          $Res Function(_$ProfileDeleteStateImpl) then) =
      __$$ProfileDeleteStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isDeleted, String reasonType, TextFieldViewModel reasonTextField});

  @override
  $TextFieldViewModelCopyWith<$Res> get reasonTextField;
}

/// @nodoc
class __$$ProfileDeleteStateImplCopyWithImpl<$Res>
    extends _$ProfileDeleteStateCopyWithImpl<$Res, _$ProfileDeleteStateImpl>
    implements _$$ProfileDeleteStateImplCopyWith<$Res> {
  __$$ProfileDeleteStateImplCopyWithImpl(_$ProfileDeleteStateImpl _value,
      $Res Function(_$ProfileDeleteStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDeleted = null,
    Object? reasonType = null,
    Object? reasonTextField = null,
  }) {
    return _then(_$ProfileDeleteStateImpl(
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      reasonType: null == reasonType
          ? _value.reasonType
          : reasonType // ignore: cast_nullable_to_non_nullable
              as String,
      reasonTextField: null == reasonTextField
          ? _value.reasonTextField
          : reasonTextField // ignore: cast_nullable_to_non_nullable
              as TextFieldViewModel,
    ));
  }
}

/// @nodoc

class _$ProfileDeleteStateImpl extends _ProfileDeleteState {
  _$ProfileDeleteStateImpl(
      {this.isDeleted = false,
      this.reasonType = '',
      this.reasonTextField = const TextFieldViewModel()})
      : super._();

  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey()
  final String reasonType;
  @override
  @JsonKey()
  final TextFieldViewModel reasonTextField;

  @override
  String toString() {
    return 'ProfileDeleteState(isDeleted: $isDeleted, reasonType: $reasonType, reasonTextField: $reasonTextField)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileDeleteStateImpl &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.reasonType, reasonType) ||
                other.reasonType == reasonType) &&
            (identical(other.reasonTextField, reasonTextField) ||
                other.reasonTextField == reasonTextField));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isDeleted, reasonType, reasonTextField);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileDeleteStateImplCopyWith<_$ProfileDeleteStateImpl> get copyWith =>
      __$$ProfileDeleteStateImplCopyWithImpl<_$ProfileDeleteStateImpl>(
          this, _$identity);
}

abstract class _ProfileDeleteState extends ProfileDeleteState {
  factory _ProfileDeleteState(
      {final bool isDeleted,
      final String reasonType,
      final TextFieldViewModel reasonTextField}) = _$ProfileDeleteStateImpl;
  _ProfileDeleteState._() : super._();

  @override
  bool get isDeleted;
  @override
  String get reasonType;
  @override
  TextFieldViewModel get reasonTextField;
  @override
  @JsonKey(ignore: true)
  _$$ProfileDeleteStateImplCopyWith<_$ProfileDeleteStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
