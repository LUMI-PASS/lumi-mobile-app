// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_base_url_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppBaseUrlState {
  String get baseUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppBaseUrlStateCopyWith<AppBaseUrlState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppBaseUrlStateCopyWith<$Res> {
  factory $AppBaseUrlStateCopyWith(
          AppBaseUrlState value, $Res Function(AppBaseUrlState) then) =
      _$AppBaseUrlStateCopyWithImpl<$Res, AppBaseUrlState>;
  @useResult
  $Res call({String baseUrl});
}

/// @nodoc
class _$AppBaseUrlStateCopyWithImpl<$Res, $Val extends AppBaseUrlState>
    implements $AppBaseUrlStateCopyWith<$Res> {
  _$AppBaseUrlStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseUrl = null,
  }) {
    return _then(_value.copyWith(
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppBaseUrlStateImplCopyWith<$Res>
    implements $AppBaseUrlStateCopyWith<$Res> {
  factory _$$AppBaseUrlStateImplCopyWith(_$AppBaseUrlStateImpl value,
          $Res Function(_$AppBaseUrlStateImpl) then) =
      __$$AppBaseUrlStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String baseUrl});
}

/// @nodoc
class __$$AppBaseUrlStateImplCopyWithImpl<$Res>
    extends _$AppBaseUrlStateCopyWithImpl<$Res, _$AppBaseUrlStateImpl>
    implements _$$AppBaseUrlStateImplCopyWith<$Res> {
  __$$AppBaseUrlStateImplCopyWithImpl(
      _$AppBaseUrlStateImpl _value, $Res Function(_$AppBaseUrlStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseUrl = null,
  }) {
    return _then(_$AppBaseUrlStateImpl(
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AppBaseUrlStateImpl extends _AppBaseUrlState {
  _$AppBaseUrlStateImpl({this.baseUrl = ''}) : super._();

  @override
  @JsonKey()
  final String baseUrl;

  @override
  String toString() {
    return 'AppBaseUrlState(baseUrl: $baseUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppBaseUrlStateImpl &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, baseUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppBaseUrlStateImplCopyWith<_$AppBaseUrlStateImpl> get copyWith =>
      __$$AppBaseUrlStateImplCopyWithImpl<_$AppBaseUrlStateImpl>(
          this, _$identity);
}

abstract class _AppBaseUrlState extends AppBaseUrlState {
  factory _AppBaseUrlState({final String baseUrl}) = _$AppBaseUrlStateImpl;
  _AppBaseUrlState._() : super._();

  @override
  String get baseUrl;
  @override
  @JsonKey(ignore: true)
  _$$AppBaseUrlStateImplCopyWith<_$AppBaseUrlStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
