// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AttendanceBuildable {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isDetailLoading => throw _privateConstructorUsedError;
  List<ChildModel>? get children => throw _privateConstructorUsedError;
  ChildModel? get selectedChild => throw _privateConstructorUsedError;
  List<AttendanceRecord> get records => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AttendanceBuildableCopyWith<AttendanceBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceBuildableCopyWith<$Res> {
  factory $AttendanceBuildableCopyWith(
          AttendanceBuildable value, $Res Function(AttendanceBuildable) then) =
      _$AttendanceBuildableCopyWithImpl<$Res, AttendanceBuildable>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isDetailLoading,
      List<ChildModel>? children,
      ChildModel? selectedChild,
      List<AttendanceRecord> records});

  $ChildModelCopyWith<$Res>? get selectedChild;
}

/// @nodoc
class _$AttendanceBuildableCopyWithImpl<$Res, $Val extends AttendanceBuildable>
    implements $AttendanceBuildableCopyWith<$Res> {
  _$AttendanceBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isDetailLoading = null,
    Object? children = freezed,
    Object? selectedChild = freezed,
    Object? records = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isDetailLoading: null == isDetailLoading
          ? _value.isDetailLoading
          : isDetailLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      children: freezed == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildModel>?,
      selectedChild: freezed == selectedChild
          ? _value.selectedChild
          : selectedChild // ignore: cast_nullable_to_non_nullable
              as ChildModel?,
      records: null == records
          ? _value.records
          : records // ignore: cast_nullable_to_non_nullable
              as List<AttendanceRecord>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ChildModelCopyWith<$Res>? get selectedChild {
    if (_value.selectedChild == null) {
      return null;
    }

    return $ChildModelCopyWith<$Res>(_value.selectedChild!, (value) {
      return _then(_value.copyWith(selectedChild: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AttendanceBuildableImplCopyWith<$Res>
    implements $AttendanceBuildableCopyWith<$Res> {
  factory _$$AttendanceBuildableImplCopyWith(_$AttendanceBuildableImpl value,
          $Res Function(_$AttendanceBuildableImpl) then) =
      __$$AttendanceBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isDetailLoading,
      List<ChildModel>? children,
      ChildModel? selectedChild,
      List<AttendanceRecord> records});

  @override
  $ChildModelCopyWith<$Res>? get selectedChild;
}

/// @nodoc
class __$$AttendanceBuildableImplCopyWithImpl<$Res>
    extends _$AttendanceBuildableCopyWithImpl<$Res, _$AttendanceBuildableImpl>
    implements _$$AttendanceBuildableImplCopyWith<$Res> {
  __$$AttendanceBuildableImplCopyWithImpl(_$AttendanceBuildableImpl _value,
      $Res Function(_$AttendanceBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isDetailLoading = null,
    Object? children = freezed,
    Object? selectedChild = freezed,
    Object? records = null,
  }) {
    return _then(_$AttendanceBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isDetailLoading: null == isDetailLoading
          ? _value.isDetailLoading
          : isDetailLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      children: freezed == children
          ? _value._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<ChildModel>?,
      selectedChild: freezed == selectedChild
          ? _value.selectedChild
          : selectedChild // ignore: cast_nullable_to_non_nullable
              as ChildModel?,
      records: null == records
          ? _value._records
          : records // ignore: cast_nullable_to_non_nullable
              as List<AttendanceRecord>,
    ));
  }
}

/// @nodoc

class _$AttendanceBuildableImpl implements _AttendanceBuildable {
  const _$AttendanceBuildableImpl(
      {this.isLoading = false,
      this.isDetailLoading = false,
      final List<ChildModel>? children,
      this.selectedChild,
      final List<AttendanceRecord> records = const []})
      : _children = children,
        _records = records;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isDetailLoading;
  final List<ChildModel>? _children;
  @override
  List<ChildModel>? get children {
    final value = _children;
    if (value == null) return null;
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final ChildModel? selectedChild;
  final List<AttendanceRecord> _records;
  @override
  @JsonKey()
  List<AttendanceRecord> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  String toString() {
    return 'AttendanceBuildable(isLoading: $isLoading, isDetailLoading: $isDetailLoading, children: $children, selectedChild: $selectedChild, records: $records)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isDetailLoading, isDetailLoading) ||
                other.isDetailLoading == isDetailLoading) &&
            const DeepCollectionEquality().equals(other._children, _children) &&
            (identical(other.selectedChild, selectedChild) ||
                other.selectedChild == selectedChild) &&
            const DeepCollectionEquality().equals(other._records, _records));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isDetailLoading,
      const DeepCollectionEquality().hash(_children),
      selectedChild,
      const DeepCollectionEquality().hash(_records));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceBuildableImplCopyWith<_$AttendanceBuildableImpl> get copyWith =>
      __$$AttendanceBuildableImplCopyWithImpl<_$AttendanceBuildableImpl>(
          this, _$identity);
}

abstract class _AttendanceBuildable implements AttendanceBuildable {
  const factory _AttendanceBuildable(
      {final bool isLoading,
      final bool isDetailLoading,
      final List<ChildModel>? children,
      final ChildModel? selectedChild,
      final List<AttendanceRecord> records}) = _$AttendanceBuildableImpl;

  @override
  bool get isLoading;
  @override
  bool get isDetailLoading;
  @override
  List<ChildModel>? get children;
  @override
  ChildModel? get selectedChild;
  @override
  List<AttendanceRecord> get records;
  @override
  @JsonKey(ignore: true)
  _$$AttendanceBuildableImplCopyWith<_$AttendanceBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AttendanceListenable {
  AttendanceEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AttendanceListenableCopyWith<AttendanceListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceListenableCopyWith<$Res> {
  factory $AttendanceListenableCopyWith(AttendanceListenable value,
          $Res Function(AttendanceListenable) then) =
      _$AttendanceListenableCopyWithImpl<$Res, AttendanceListenable>;
  @useResult
  $Res call({AttendanceEffect effect});
}

/// @nodoc
class _$AttendanceListenableCopyWithImpl<$Res,
        $Val extends AttendanceListenable>
    implements $AttendanceListenableCopyWith<$Res> {
  _$AttendanceListenableCopyWithImpl(this._value, this._then);

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
              as AttendanceEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceListenableImplCopyWith<$Res>
    implements $AttendanceListenableCopyWith<$Res> {
  factory _$$AttendanceListenableImplCopyWith(_$AttendanceListenableImpl value,
          $Res Function(_$AttendanceListenableImpl) then) =
      __$$AttendanceListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AttendanceEffect effect});
}

/// @nodoc
class __$$AttendanceListenableImplCopyWithImpl<$Res>
    extends _$AttendanceListenableCopyWithImpl<$Res, _$AttendanceListenableImpl>
    implements _$$AttendanceListenableImplCopyWith<$Res> {
  __$$AttendanceListenableImplCopyWithImpl(_$AttendanceListenableImpl _value,
      $Res Function(_$AttendanceListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$AttendanceListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as AttendanceEffect,
    ));
  }
}

/// @nodoc

class _$AttendanceListenableImpl implements _AttendanceListenable {
  const _$AttendanceListenableImpl({required this.effect});

  @override
  final AttendanceEffect effect;

  @override
  String toString() {
    return 'AttendanceListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceListenableImplCopyWith<_$AttendanceListenableImpl>
      get copyWith =>
          __$$AttendanceListenableImplCopyWithImpl<_$AttendanceListenableImpl>(
              this, _$identity);
}

abstract class _AttendanceListenable implements AttendanceListenable {
  const factory _AttendanceListenable(
      {required final AttendanceEffect effect}) = _$AttendanceListenableImpl;

  @override
  AttendanceEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$AttendanceListenableImplCopyWith<_$AttendanceListenableImpl>
      get copyWith => throw _privateConstructorUsedError;
}
