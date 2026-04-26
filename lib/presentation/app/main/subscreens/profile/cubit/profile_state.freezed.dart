// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileBuildable {
  bool get isLoading => throw _privateConstructorUsedError;
  HomForUser? get user => throw _privateConstructorUsedError;
  List<ChildModel> get children => throw _privateConstructorUsedError;
  ParentTrialSummary? get trialSummary => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileBuildableCopyWith<ProfileBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileBuildableCopyWith<$Res> {
  factory $ProfileBuildableCopyWith(
          ProfileBuildable value, $Res Function(ProfileBuildable) then) =
      _$ProfileBuildableCopyWithImpl<$Res, ProfileBuildable>;
  @useResult
  $Res call(
      {bool isLoading,
      HomForUser? user,
      List<ChildModel> children,
      ParentTrialSummary? trialSummary});

  $HomForUserCopyWith<$Res>? get user;
  $ParentTrialSummaryCopyWith<$Res>? get trialSummary;
}

/// @nodoc
class _$ProfileBuildableCopyWithImpl<$Res, $Val extends ProfileBuildable>
    implements $ProfileBuildableCopyWith<$Res> {
  _$ProfileBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? user = freezed,
    Object? children = null,
    Object? trialSummary = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as HomForUser?,
      children: null == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildModel>,
      trialSummary: freezed == trialSummary
          ? _value.trialSummary
          : trialSummary // ignore: cast_nullable_to_non_nullable
              as ParentTrialSummary?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomForUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $HomForUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ParentTrialSummaryCopyWith<$Res>? get trialSummary {
    if (_value.trialSummary == null) {
      return null;
    }

    return $ParentTrialSummaryCopyWith<$Res>(_value.trialSummary!, (value) {
      return _then(_value.copyWith(trialSummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileBuildableImplCopyWith<$Res>
    implements $ProfileBuildableCopyWith<$Res> {
  factory _$$ProfileBuildableImplCopyWith(_$ProfileBuildableImpl value,
          $Res Function(_$ProfileBuildableImpl) then) =
      __$$ProfileBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      HomForUser? user,
      List<ChildModel> children,
      ParentTrialSummary? trialSummary});

  @override
  $HomForUserCopyWith<$Res>? get user;
  @override
  $ParentTrialSummaryCopyWith<$Res>? get trialSummary;
}

/// @nodoc
class __$$ProfileBuildableImplCopyWithImpl<$Res>
    extends _$ProfileBuildableCopyWithImpl<$Res, _$ProfileBuildableImpl>
    implements _$$ProfileBuildableImplCopyWith<$Res> {
  __$$ProfileBuildableImplCopyWithImpl(_$ProfileBuildableImpl _value,
      $Res Function(_$ProfileBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? user = freezed,
    Object? children = null,
    Object? trialSummary = freezed,
  }) {
    return _then(_$ProfileBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as HomForUser?,
      children: null == children
          ? _value._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildModel>,
      trialSummary: freezed == trialSummary
          ? _value.trialSummary
          : trialSummary // ignore: cast_nullable_to_non_nullable
              as ParentTrialSummary?,
    ));
  }
}

/// @nodoc

class _$ProfileBuildableImpl implements _ProfileBuildable {
  const _$ProfileBuildableImpl(
      {this.isLoading = false,
      this.user,
      final List<ChildModel> children = const [],
      this.trialSummary})
      : _children = children;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final HomForUser? user;
  final List<ChildModel> _children;
  @override
  @JsonKey()
  List<ChildModel> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  final ParentTrialSummary? trialSummary;

  @override
  String toString() {
    return 'ProfileBuildable(isLoading: $isLoading, user: $user, children: $children, trialSummary: $trialSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._children, _children) &&
            (identical(other.trialSummary, trialSummary) ||
                other.trialSummary == trialSummary));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, user,
      const DeepCollectionEquality().hash(_children), trialSummary);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileBuildableImplCopyWith<_$ProfileBuildableImpl> get copyWith =>
      __$$ProfileBuildableImplCopyWithImpl<_$ProfileBuildableImpl>(
          this, _$identity);
}

abstract class _ProfileBuildable implements ProfileBuildable {
  const factory _ProfileBuildable(
      {final bool isLoading,
      final HomForUser? user,
      final List<ChildModel> children,
      final ParentTrialSummary? trialSummary}) = _$ProfileBuildableImpl;

  @override
  bool get isLoading;
  @override
  HomForUser? get user;
  @override
  List<ChildModel> get children;
  @override
  ParentTrialSummary? get trialSummary;
  @override
  @JsonKey(ignore: true)
  _$$ProfileBuildableImplCopyWith<_$ProfileBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProfileListenable {
  ProfileEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileListenableCopyWith<ProfileListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileListenableCopyWith<$Res> {
  factory $ProfileListenableCopyWith(
          ProfileListenable value, $Res Function(ProfileListenable) then) =
      _$ProfileListenableCopyWithImpl<$Res, ProfileListenable>;
  @useResult
  $Res call({ProfileEffect effect});
}

/// @nodoc
class _$ProfileListenableCopyWithImpl<$Res, $Val extends ProfileListenable>
    implements $ProfileListenableCopyWith<$Res> {
  _$ProfileListenableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_value.copyWith(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ProfileEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileListenableImplCopyWith<$Res>
    implements $ProfileListenableCopyWith<$Res> {
  factory _$$ProfileListenableImplCopyWith(_$ProfileListenableImpl value,
          $Res Function(_$ProfileListenableImpl) then) =
      __$$ProfileListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProfileEffect effect});
}

/// @nodoc
class __$$ProfileListenableImplCopyWithImpl<$Res>
    extends _$ProfileListenableCopyWithImpl<$Res, _$ProfileListenableImpl>
    implements _$$ProfileListenableImplCopyWith<$Res> {
  __$$ProfileListenableImplCopyWithImpl(_$ProfileListenableImpl _value,
      $Res Function(_$ProfileListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$ProfileListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ProfileEffect,
    ));
  }
}

/// @nodoc

class _$ProfileListenableImpl implements _ProfileListenable {
  const _$ProfileListenableImpl({required this.effect});

  @override
  final ProfileEffect effect;

  @override
  String toString() {
    return 'ProfileListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileListenableImplCopyWith<_$ProfileListenableImpl> get copyWith =>
      __$$ProfileListenableImplCopyWithImpl<_$ProfileListenableImpl>(
          this, _$identity);
}

abstract class _ProfileListenable implements ProfileListenable {
  const factory _ProfileListenable({required final ProfileEffect effect}) =
      _$ProfileListenableImpl;

  @override
  ProfileEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$ProfileListenableImplCopyWith<_$ProfileListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
