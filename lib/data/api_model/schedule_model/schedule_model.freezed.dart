// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) {
  return _ScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleModel {
  bool? get success => throw _privateConstructorUsedError;
  List<ScheduleItem>? get data => throw _privateConstructorUsedError;
  int? get page => throw _privateConstructorUsedError;
  int? get pages => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  int? get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleModelCopyWith<ScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleModelCopyWith<$Res> {
  factory $ScheduleModelCopyWith(
          ScheduleModel value, $Res Function(ScheduleModel) then) =
      _$ScheduleModelCopyWithImpl<$Res, ScheduleModel>;
  @useResult
  $Res call(
      {bool? success,
      List<ScheduleItem>? data,
      int? page,
      int? pages,
      int? limit,
      int? total});
}

/// @nodoc
class _$ScheduleModelCopyWithImpl<$Res, $Val extends ScheduleModel>
    implements $ScheduleModelCopyWith<$Res> {
  _$ScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
    Object? page = freezed,
    Object? pages = freezed,
    Object? limit = freezed,
    Object? total = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<ScheduleItem>?,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      pages: freezed == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleModelImplCopyWith<$Res>
    implements $ScheduleModelCopyWith<$Res> {
  factory _$$ScheduleModelImplCopyWith(
          _$ScheduleModelImpl value, $Res Function(_$ScheduleModelImpl) then) =
      __$$ScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      List<ScheduleItem>? data,
      int? page,
      int? pages,
      int? limit,
      int? total});
}

/// @nodoc
class __$$ScheduleModelImplCopyWithImpl<$Res>
    extends _$ScheduleModelCopyWithImpl<$Res, _$ScheduleModelImpl>
    implements _$$ScheduleModelImplCopyWith<$Res> {
  __$$ScheduleModelImplCopyWithImpl(
      _$ScheduleModelImpl _value, $Res Function(_$ScheduleModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
    Object? page = freezed,
    Object? pages = freezed,
    Object? limit = freezed,
    Object? total = freezed,
  }) {
    return _then(_$ScheduleModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<ScheduleItem>?,
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      pages: freezed == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleModelImpl implements _ScheduleModel {
  const _$ScheduleModelImpl(
      {this.success,
      final List<ScheduleItem>? data,
      this.page,
      this.pages,
      this.limit,
      this.total})
      : _data = data;

  factory _$ScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleModelImplFromJson(json);

  @override
  final bool? success;
  final List<ScheduleItem>? _data;
  @override
  List<ScheduleItem>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? page;
  @override
  final int? pages;
  @override
  final int? limit;
  @override
  final int? total;

  @override
  String toString() {
    return 'ScheduleModel(success: $success, data: $data, page: $page, pages: $pages, limit: $limit, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pages, pages) || other.pages == pages) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success,
      const DeepCollectionEquality().hash(_data), page, pages, limit, total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      __$$ScheduleModelImplCopyWithImpl<_$ScheduleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleModel implements ScheduleModel {
  const factory _ScheduleModel(
      {final bool? success,
      final List<ScheduleItem>? data,
      final int? page,
      final int? pages,
      final int? limit,
      final int? total}) = _$ScheduleModelImpl;

  factory _ScheduleModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleModelImpl.fromJson;

  @override
  bool? get success;
  @override
  List<ScheduleItem>? get data;
  @override
  int? get page;
  @override
  int? get pages;
  @override
  int? get limit;
  @override
  int? get total;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleItem _$ScheduleItemFromJson(Map<String, dynamic> json) {
  return _ScheduleItem.fromJson(json);
}

/// @nodoc
mixin _$ScheduleItem {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'class')
  ScheduleClass? get scheduleClass => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_week')
  String? get dayOfWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'for_date')
  String? get forDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  String? get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String? get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String? get endDate => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'for_child')
  ScheduleChild? get forChild => throw _privateConstructorUsedError;
  @JsonKey(name: 'related_bookings')
  List<RelatedBooking>? get relatedBookings =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleItemCopyWith<ScheduleItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleItemCopyWith<$Res> {
  factory $ScheduleItemCopyWith(
          ScheduleItem value, $Res Function(ScheduleItem) then) =
      _$ScheduleItemCopyWithImpl<$Res, ScheduleItem>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'class') ScheduleClass? scheduleClass,
      @JsonKey(name: 'day_of_week') String? dayOfWeek,
      @JsonKey(name: 'for_date') String? forDate,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'end_time') String? endTime,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      int? capacity,
      String? status,
      String? notes,
      @JsonKey(name: 'for_child') ScheduleChild? forChild,
      @JsonKey(name: 'related_bookings') List<RelatedBooking>? relatedBookings,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});

  $ScheduleClassCopyWith<$Res>? get scheduleClass;
  $ScheduleChildCopyWith<$Res>? get forChild;
}

/// @nodoc
class _$ScheduleItemCopyWithImpl<$Res, $Val extends ScheduleItem>
    implements $ScheduleItemCopyWith<$Res> {
  _$ScheduleItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleClass = freezed,
    Object? dayOfWeek = freezed,
    Object? forDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? capacity = freezed,
    Object? status = freezed,
    Object? notes = freezed,
    Object? forChild = freezed,
    Object? relatedBookings = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleClass: freezed == scheduleClass
          ? _value.scheduleClass
          : scheduleClass // ignore: cast_nullable_to_non_nullable
              as ScheduleClass?,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String?,
      forDate: freezed == forDate
          ? _value.forDate
          : forDate // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      forChild: freezed == forChild
          ? _value.forChild
          : forChild // ignore: cast_nullable_to_non_nullable
              as ScheduleChild?,
      relatedBookings: freezed == relatedBookings
          ? _value.relatedBookings
          : relatedBookings // ignore: cast_nullable_to_non_nullable
              as List<RelatedBooking>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ScheduleClassCopyWith<$Res>? get scheduleClass {
    if (_value.scheduleClass == null) {
      return null;
    }

    return $ScheduleClassCopyWith<$Res>(_value.scheduleClass!, (value) {
      return _then(_value.copyWith(scheduleClass: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ScheduleChildCopyWith<$Res>? get forChild {
    if (_value.forChild == null) {
      return null;
    }

    return $ScheduleChildCopyWith<$Res>(_value.forChild!, (value) {
      return _then(_value.copyWith(forChild: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScheduleItemImplCopyWith<$Res>
    implements $ScheduleItemCopyWith<$Res> {
  factory _$$ScheduleItemImplCopyWith(
          _$ScheduleItemImpl value, $Res Function(_$ScheduleItemImpl) then) =
      __$$ScheduleItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'class') ScheduleClass? scheduleClass,
      @JsonKey(name: 'day_of_week') String? dayOfWeek,
      @JsonKey(name: 'for_date') String? forDate,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'end_time') String? endTime,
      @JsonKey(name: 'start_date') String? startDate,
      @JsonKey(name: 'end_date') String? endDate,
      int? capacity,
      String? status,
      String? notes,
      @JsonKey(name: 'for_child') ScheduleChild? forChild,
      @JsonKey(name: 'related_bookings') List<RelatedBooking>? relatedBookings,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});

  @override
  $ScheduleClassCopyWith<$Res>? get scheduleClass;
  @override
  $ScheduleChildCopyWith<$Res>? get forChild;
}

/// @nodoc
class __$$ScheduleItemImplCopyWithImpl<$Res>
    extends _$ScheduleItemCopyWithImpl<$Res, _$ScheduleItemImpl>
    implements _$$ScheduleItemImplCopyWith<$Res> {
  __$$ScheduleItemImplCopyWithImpl(
      _$ScheduleItemImpl _value, $Res Function(_$ScheduleItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleClass = freezed,
    Object? dayOfWeek = freezed,
    Object? forDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? capacity = freezed,
    Object? status = freezed,
    Object? notes = freezed,
    Object? forChild = freezed,
    Object? relatedBookings = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ScheduleItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleClass: freezed == scheduleClass
          ? _value.scheduleClass
          : scheduleClass // ignore: cast_nullable_to_non_nullable
              as ScheduleClass?,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String?,
      forDate: freezed == forDate
          ? _value.forDate
          : forDate // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      forChild: freezed == forChild
          ? _value.forChild
          : forChild // ignore: cast_nullable_to_non_nullable
              as ScheduleChild?,
      relatedBookings: freezed == relatedBookings
          ? _value._relatedBookings
          : relatedBookings // ignore: cast_nullable_to_non_nullable
              as List<RelatedBooking>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ScheduleItemImpl implements _ScheduleItem {
  const _$ScheduleItemImpl(
      {this.id,
      @JsonKey(name: 'class') this.scheduleClass,
      @JsonKey(name: 'day_of_week') this.dayOfWeek,
      @JsonKey(name: 'for_date') this.forDate,
      @JsonKey(name: 'start_time') this.startTime,
      @JsonKey(name: 'end_time') this.endTime,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      this.capacity,
      this.status,
      this.notes,
      @JsonKey(name: 'for_child') this.forChild,
      @JsonKey(name: 'related_bookings')
      final List<RelatedBooking>? relatedBookings,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _relatedBookings = relatedBookings;

  factory _$ScheduleItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleItemImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'class')
  final ScheduleClass? scheduleClass;
  @override
  @JsonKey(name: 'day_of_week')
  final String? dayOfWeek;
  @override
  @JsonKey(name: 'for_date')
  final String? forDate;
  @override
  @JsonKey(name: 'start_time')
  final String? startTime;
  @override
  @JsonKey(name: 'end_time')
  final String? endTime;
  @override
  @JsonKey(name: 'start_date')
  final String? startDate;
  @override
  @JsonKey(name: 'end_date')
  final String? endDate;
  @override
  final int? capacity;
  @override
  final String? status;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'for_child')
  final ScheduleChild? forChild;
  final List<RelatedBooking>? _relatedBookings;
  @override
  @JsonKey(name: 'related_bookings')
  List<RelatedBooking>? get relatedBookings {
    final value = _relatedBookings;
    if (value == null) return null;
    if (_relatedBookings is EqualUnmodifiableListView) return _relatedBookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ScheduleItem(id: $id, scheduleClass: $scheduleClass, dayOfWeek: $dayOfWeek, forDate: $forDate, startTime: $startTime, endTime: $endTime, startDate: $startDate, endDate: $endDate, capacity: $capacity, status: $status, notes: $notes, forChild: $forChild, relatedBookings: $relatedBookings, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scheduleClass, scheduleClass) ||
                other.scheduleClass == scheduleClass) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.forDate, forDate) || other.forDate == forDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.forChild, forChild) ||
                other.forChild == forChild) &&
            const DeepCollectionEquality()
                .equals(other._relatedBookings, _relatedBookings) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      scheduleClass,
      dayOfWeek,
      forDate,
      startTime,
      endTime,
      startDate,
      endDate,
      capacity,
      status,
      notes,
      forChild,
      const DeepCollectionEquality().hash(_relatedBookings),
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleItemImplCopyWith<_$ScheduleItemImpl> get copyWith =>
      __$$ScheduleItemImplCopyWithImpl<_$ScheduleItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleItemImplToJson(
      this,
    );
  }
}

abstract class _ScheduleItem implements ScheduleItem {
  const factory _ScheduleItem(
          {final String? id,
          @JsonKey(name: 'class') final ScheduleClass? scheduleClass,
          @JsonKey(name: 'day_of_week') final String? dayOfWeek,
          @JsonKey(name: 'for_date') final String? forDate,
          @JsonKey(name: 'start_time') final String? startTime,
          @JsonKey(name: 'end_time') final String? endTime,
          @JsonKey(name: 'start_date') final String? startDate,
          @JsonKey(name: 'end_date') final String? endDate,
          final int? capacity,
          final String? status,
          final String? notes,
          @JsonKey(name: 'for_child') final ScheduleChild? forChild,
          @JsonKey(name: 'related_bookings')
          final List<RelatedBooking>? relatedBookings,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$ScheduleItemImpl;

  factory _ScheduleItem.fromJson(Map<String, dynamic> json) =
      _$ScheduleItemImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'class')
  ScheduleClass? get scheduleClass;
  @override
  @JsonKey(name: 'day_of_week')
  String? get dayOfWeek;
  @override
  @JsonKey(name: 'for_date')
  String? get forDate;
  @override
  @JsonKey(name: 'start_time')
  String? get startTime;
  @override
  @JsonKey(name: 'end_time')
  String? get endTime;
  @override
  @JsonKey(name: 'start_date')
  String? get startDate;
  @override
  @JsonKey(name: 'end_date')
  String? get endDate;
  @override
  int? get capacity;
  @override
  String? get status;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'for_child')
  ScheduleChild? get forChild;
  @override
  @JsonKey(name: 'related_bookings')
  List<RelatedBooking>? get relatedBookings;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleItemImplCopyWith<_$ScheduleItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleClass _$ScheduleClassFromJson(Map<String, dynamic> json) {
  return _ScheduleClass.fromJson(json);
}

/// @nodoc
mixin _$ScheduleClass {
  String? get id => throw _privateConstructorUsedError;
  String? get branch => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  num? get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'trial_price')
  num? get trialPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_age')
  int? get minAge => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_age')
  int? get maxAge => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_photo')
  bool? get hasPhoto => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleClassCopyWith<ScheduleClass> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleClassCopyWith<$Res> {
  factory $ScheduleClassCopyWith(
          ScheduleClass value, $Res Function(ScheduleClass) then) =
      _$ScheduleClassCopyWithImpl<$Res, ScheduleClass>;
  @useResult
  $Res call(
      {String? id,
      String? branch,
      String? category,
      String? title,
      String? description,
      int? duration,
      num? price,
      @JsonKey(name: 'trial_price') num? trialPrice,
      @JsonKey(name: 'min_age') int? minAge,
      @JsonKey(name: 'max_age') int? maxAge,
      String? gender,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'has_photo') bool? hasPhoto});
}

/// @nodoc
class _$ScheduleClassCopyWithImpl<$Res, $Val extends ScheduleClass>
    implements $ScheduleClassCopyWith<$Res> {
  _$ScheduleClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? branch = freezed,
    Object? category = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? duration = freezed,
    Object? price = freezed,
    Object? trialPrice = freezed,
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? gender = freezed,
    Object? isActive = freezed,
    Object? hasPhoto = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num?,
      trialPrice: freezed == trialPrice
          ? _value.trialPrice
          : trialPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleClassImplCopyWith<$Res>
    implements $ScheduleClassCopyWith<$Res> {
  factory _$$ScheduleClassImplCopyWith(
          _$ScheduleClassImpl value, $Res Function(_$ScheduleClassImpl) then) =
      __$$ScheduleClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? branch,
      String? category,
      String? title,
      String? description,
      int? duration,
      num? price,
      @JsonKey(name: 'trial_price') num? trialPrice,
      @JsonKey(name: 'min_age') int? minAge,
      @JsonKey(name: 'max_age') int? maxAge,
      String? gender,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'has_photo') bool? hasPhoto});
}

/// @nodoc
class __$$ScheduleClassImplCopyWithImpl<$Res>
    extends _$ScheduleClassCopyWithImpl<$Res, _$ScheduleClassImpl>
    implements _$$ScheduleClassImplCopyWith<$Res> {
  __$$ScheduleClassImplCopyWithImpl(
      _$ScheduleClassImpl _value, $Res Function(_$ScheduleClassImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? branch = freezed,
    Object? category = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? duration = freezed,
    Object? price = freezed,
    Object? trialPrice = freezed,
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? gender = freezed,
    Object? isActive = freezed,
    Object? hasPhoto = freezed,
  }) {
    return _then(_$ScheduleClassImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num?,
      trialPrice: freezed == trialPrice
          ? _value.trialPrice
          : trialPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ScheduleClassImpl implements _ScheduleClass {
  const _$ScheduleClassImpl(
      {this.id,
      this.branch,
      this.category,
      this.title,
      this.description,
      this.duration,
      this.price,
      @JsonKey(name: 'trial_price') this.trialPrice,
      @JsonKey(name: 'min_age') this.minAge,
      @JsonKey(name: 'max_age') this.maxAge,
      this.gender,
      @JsonKey(name: 'is_active') this.isActive,
      @JsonKey(name: 'has_photo') this.hasPhoto});

  factory _$ScheduleClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleClassImplFromJson(json);

  @override
  final String? id;
  @override
  final String? branch;
  @override
  final String? category;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final int? duration;
  @override
  final num? price;
  @override
  @JsonKey(name: 'trial_price')
  final num? trialPrice;
  @override
  @JsonKey(name: 'min_age')
  final int? minAge;
  @override
  @JsonKey(name: 'max_age')
  final int? maxAge;
  @override
  final String? gender;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'has_photo')
  final bool? hasPhoto;

  @override
  String toString() {
    return 'ScheduleClass(id: $id, branch: $branch, category: $category, title: $title, description: $description, duration: $duration, price: $price, trialPrice: $trialPrice, minAge: $minAge, maxAge: $maxAge, gender: $gender, isActive: $isActive, hasPhoto: $hasPhoto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleClassImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.trialPrice, trialPrice) ||
                other.trialPrice == trialPrice) &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.hasPhoto, hasPhoto) ||
                other.hasPhoto == hasPhoto));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      branch,
      category,
      title,
      description,
      duration,
      price,
      trialPrice,
      minAge,
      maxAge,
      gender,
      isActive,
      hasPhoto);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleClassImplCopyWith<_$ScheduleClassImpl> get copyWith =>
      __$$ScheduleClassImplCopyWithImpl<_$ScheduleClassImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleClassImplToJson(
      this,
    );
  }
}

abstract class _ScheduleClass implements ScheduleClass {
  const factory _ScheduleClass(
      {final String? id,
      final String? branch,
      final String? category,
      final String? title,
      final String? description,
      final int? duration,
      final num? price,
      @JsonKey(name: 'trial_price') final num? trialPrice,
      @JsonKey(name: 'min_age') final int? minAge,
      @JsonKey(name: 'max_age') final int? maxAge,
      final String? gender,
      @JsonKey(name: 'is_active') final bool? isActive,
      @JsonKey(name: 'has_photo') final bool? hasPhoto}) = _$ScheduleClassImpl;

  factory _ScheduleClass.fromJson(Map<String, dynamic> json) =
      _$ScheduleClassImpl.fromJson;

  @override
  String? get id;
  @override
  String? get branch;
  @override
  String? get category;
  @override
  String? get title;
  @override
  String? get description;
  @override
  int? get duration;
  @override
  num? get price;
  @override
  @JsonKey(name: 'trial_price')
  num? get trialPrice;
  @override
  @JsonKey(name: 'min_age')
  int? get minAge;
  @override
  @JsonKey(name: 'max_age')
  int? get maxAge;
  @override
  String? get gender;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'has_photo')
  bool? get hasPhoto;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleClassImplCopyWith<_$ScheduleClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleChild _$ScheduleChildFromJson(Map<String, dynamic> json) {
  return _ScheduleChild.fromJson(json);
}

/// @nodoc
mixin _$ScheduleChild {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleChildCopyWith<ScheduleChild> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleChildCopyWith<$Res> {
  factory $ScheduleChildCopyWith(
          ScheduleChild value, $Res Function(ScheduleChild) then) =
      _$ScheduleChildCopyWithImpl<$Res, ScheduleChild>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      String? dob,
      String? gender});
}

/// @nodoc
class _$ScheduleChildCopyWithImpl<$Res, $Val extends ScheduleChild>
    implements $ScheduleChildCopyWith<$Res> {
  _$ScheduleChildCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleChildImplCopyWith<$Res>
    implements $ScheduleChildCopyWith<$Res> {
  factory _$$ScheduleChildImplCopyWith(
          _$ScheduleChildImpl value, $Res Function(_$ScheduleChildImpl) then) =
      __$$ScheduleChildImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'first_name') String? firstName,
      @JsonKey(name: 'last_name') String? lastName,
      String? dob,
      String? gender});
}

/// @nodoc
class __$$ScheduleChildImplCopyWithImpl<$Res>
    extends _$ScheduleChildCopyWithImpl<$Res, _$ScheduleChildImpl>
    implements _$$ScheduleChildImplCopyWith<$Res> {
  __$$ScheduleChildImplCopyWithImpl(
      _$ScheduleChildImpl _value, $Res Function(_$ScheduleChildImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
  }) {
    return _then(_$ScheduleChildImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ScheduleChildImpl implements _ScheduleChild {
  const _$ScheduleChildImpl(
      {this.id,
      @JsonKey(name: 'first_name') this.firstName,
      @JsonKey(name: 'last_name') this.lastName,
      this.dob,
      this.gender});

  factory _$ScheduleChildImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleChildImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'first_name')
  final String? firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  final String? dob;
  @override
  final String? gender;

  @override
  String toString() {
    return 'ScheduleChild(id: $id, firstName: $firstName, lastName: $lastName, dob: $dob, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleChildImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, firstName, lastName, dob, gender);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleChildImplCopyWith<_$ScheduleChildImpl> get copyWith =>
      __$$ScheduleChildImplCopyWithImpl<_$ScheduleChildImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleChildImplToJson(
      this,
    );
  }
}

abstract class _ScheduleChild implements ScheduleChild {
  const factory _ScheduleChild(
      {final String? id,
      @JsonKey(name: 'first_name') final String? firstName,
      @JsonKey(name: 'last_name') final String? lastName,
      final String? dob,
      final String? gender}) = _$ScheduleChildImpl;

  factory _ScheduleChild.fromJson(Map<String, dynamic> json) =
      _$ScheduleChildImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'first_name')
  String? get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  String? get dob;
  @override
  String? get gender;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleChildImplCopyWith<_$ScheduleChildImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RelatedBooking _$RelatedBookingFromJson(Map<String, dynamic> json) {
  return _RelatedBooking.fromJson(json);
}

/// @nodoc
mixin _$RelatedBooking {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'schedule_id')
  String? get scheduleId => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_id')
  String? get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_status')
  String? get bookingStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'charged_coin_amount')
  num? get chargedCoinAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_trial_booking')
  bool? get isTrialBooking => throw _privateConstructorUsedError;
  @JsonKey(name: 'attendance_status')
  String? get attendanceStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancelled_at')
  String? get cancelledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ticket_no')
  String? get ticketNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'ticket_date')
  String? get ticketDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RelatedBookingCopyWith<RelatedBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelatedBookingCopyWith<$Res> {
  factory $RelatedBookingCopyWith(
          RelatedBooking value, $Res Function(RelatedBooking) then) =
      _$RelatedBookingCopyWithImpl<$Res, RelatedBooking>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'schedule_id') String? scheduleId,
      @JsonKey(name: 'child_id') String? childId,
      @JsonKey(name: 'booking_status') String? bookingStatus,
      @JsonKey(name: 'charged_coin_amount') num? chargedCoinAmount,
      @JsonKey(name: 'is_trial_booking') bool? isTrialBooking,
      @JsonKey(name: 'attendance_status') String? attendanceStatus,
      @JsonKey(name: 'cancelled_at') String? cancelledAt,
      @JsonKey(name: 'ticket_no') String? ticketNo,
      @JsonKey(name: 'ticket_date') String? ticketDate,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$RelatedBookingCopyWithImpl<$Res, $Val extends RelatedBooking>
    implements $RelatedBookingCopyWith<$Res> {
  _$RelatedBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleId = freezed,
    Object? childId = freezed,
    Object? bookingStatus = freezed,
    Object? chargedCoinAmount = freezed,
    Object? isTrialBooking = freezed,
    Object? attendanceStatus = freezed,
    Object? cancelledAt = freezed,
    Object? ticketNo = freezed,
    Object? ticketDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      chargedCoinAmount: freezed == chargedCoinAmount
          ? _value.chargedCoinAmount
          : chargedCoinAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      isTrialBooking: freezed == isTrialBooking
          ? _value.isTrialBooking
          : isTrialBooking // ignore: cast_nullable_to_non_nullable
              as bool?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketNo: freezed == ticketNo
          ? _value.ticketNo
          : ticketNo // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketDate: freezed == ticketDate
          ? _value.ticketDate
          : ticketDate // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelatedBookingImplCopyWith<$Res>
    implements $RelatedBookingCopyWith<$Res> {
  factory _$$RelatedBookingImplCopyWith(_$RelatedBookingImpl value,
          $Res Function(_$RelatedBookingImpl) then) =
      __$$RelatedBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'schedule_id') String? scheduleId,
      @JsonKey(name: 'child_id') String? childId,
      @JsonKey(name: 'booking_status') String? bookingStatus,
      @JsonKey(name: 'charged_coin_amount') num? chargedCoinAmount,
      @JsonKey(name: 'is_trial_booking') bool? isTrialBooking,
      @JsonKey(name: 'attendance_status') String? attendanceStatus,
      @JsonKey(name: 'cancelled_at') String? cancelledAt,
      @JsonKey(name: 'ticket_no') String? ticketNo,
      @JsonKey(name: 'ticket_date') String? ticketDate,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$RelatedBookingImplCopyWithImpl<$Res>
    extends _$RelatedBookingCopyWithImpl<$Res, _$RelatedBookingImpl>
    implements _$$RelatedBookingImplCopyWith<$Res> {
  __$$RelatedBookingImplCopyWithImpl(
      _$RelatedBookingImpl _value, $Res Function(_$RelatedBookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleId = freezed,
    Object? childId = freezed,
    Object? bookingStatus = freezed,
    Object? chargedCoinAmount = freezed,
    Object? isTrialBooking = freezed,
    Object? attendanceStatus = freezed,
    Object? cancelledAt = freezed,
    Object? ticketNo = freezed,
    Object? ticketDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$RelatedBookingImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      chargedCoinAmount: freezed == chargedCoinAmount
          ? _value.chargedCoinAmount
          : chargedCoinAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      isTrialBooking: freezed == isTrialBooking
          ? _value.isTrialBooking
          : isTrialBooking // ignore: cast_nullable_to_non_nullable
              as bool?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketNo: freezed == ticketNo
          ? _value.ticketNo
          : ticketNo // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketDate: freezed == ticketDate
          ? _value.ticketDate
          : ticketDate // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$RelatedBookingImpl implements _RelatedBooking {
  const _$RelatedBookingImpl(
      {this.id,
      @JsonKey(name: 'schedule_id') this.scheduleId,
      @JsonKey(name: 'child_id') this.childId,
      @JsonKey(name: 'booking_status') this.bookingStatus,
      @JsonKey(name: 'charged_coin_amount') this.chargedCoinAmount,
      @JsonKey(name: 'is_trial_booking') this.isTrialBooking,
      @JsonKey(name: 'attendance_status') this.attendanceStatus,
      @JsonKey(name: 'cancelled_at') this.cancelledAt,
      @JsonKey(name: 'ticket_no') this.ticketNo,
      @JsonKey(name: 'ticket_date') this.ticketDate,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$RelatedBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelatedBookingImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'schedule_id')
  final String? scheduleId;
  @override
  @JsonKey(name: 'child_id')
  final String? childId;
  @override
  @JsonKey(name: 'booking_status')
  final String? bookingStatus;
  @override
  @JsonKey(name: 'charged_coin_amount')
  final num? chargedCoinAmount;
  @override
  @JsonKey(name: 'is_trial_booking')
  final bool? isTrialBooking;
  @override
  @JsonKey(name: 'attendance_status')
  final String? attendanceStatus;
  @override
  @JsonKey(name: 'cancelled_at')
  final String? cancelledAt;
  @override
  @JsonKey(name: 'ticket_no')
  final String? ticketNo;
  @override
  @JsonKey(name: 'ticket_date')
  final String? ticketDate;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'RelatedBooking(id: $id, scheduleId: $scheduleId, childId: $childId, bookingStatus: $bookingStatus, chargedCoinAmount: $chargedCoinAmount, isTrialBooking: $isTrialBooking, attendanceStatus: $attendanceStatus, cancelledAt: $cancelledAt, ticketNo: $ticketNo, ticketDate: $ticketDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelatedBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.chargedCoinAmount, chargedCoinAmount) ||
                other.chargedCoinAmount == chargedCoinAmount) &&
            (identical(other.isTrialBooking, isTrialBooking) ||
                other.isTrialBooking == isTrialBooking) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.ticketNo, ticketNo) ||
                other.ticketNo == ticketNo) &&
            (identical(other.ticketDate, ticketDate) ||
                other.ticketDate == ticketDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      scheduleId,
      childId,
      bookingStatus,
      chargedCoinAmount,
      isTrialBooking,
      attendanceStatus,
      cancelledAt,
      ticketNo,
      ticketDate,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RelatedBookingImplCopyWith<_$RelatedBookingImpl> get copyWith =>
      __$$RelatedBookingImplCopyWithImpl<_$RelatedBookingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelatedBookingImplToJson(
      this,
    );
  }
}

abstract class _RelatedBooking implements RelatedBooking {
  const factory _RelatedBooking(
          {final String? id,
          @JsonKey(name: 'schedule_id') final String? scheduleId,
          @JsonKey(name: 'child_id') final String? childId,
          @JsonKey(name: 'booking_status') final String? bookingStatus,
          @JsonKey(name: 'charged_coin_amount') final num? chargedCoinAmount,
          @JsonKey(name: 'is_trial_booking') final bool? isTrialBooking,
          @JsonKey(name: 'attendance_status') final String? attendanceStatus,
          @JsonKey(name: 'cancelled_at') final String? cancelledAt,
          @JsonKey(name: 'ticket_no') final String? ticketNo,
          @JsonKey(name: 'ticket_date') final String? ticketDate,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$RelatedBookingImpl;

  factory _RelatedBooking.fromJson(Map<String, dynamic> json) =
      _$RelatedBookingImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'schedule_id')
  String? get scheduleId;
  @override
  @JsonKey(name: 'child_id')
  String? get childId;
  @override
  @JsonKey(name: 'booking_status')
  String? get bookingStatus;
  @override
  @JsonKey(name: 'charged_coin_amount')
  num? get chargedCoinAmount;
  @override
  @JsonKey(name: 'is_trial_booking')
  bool? get isTrialBooking;
  @override
  @JsonKey(name: 'attendance_status')
  String? get attendanceStatus;
  @override
  @JsonKey(name: 'cancelled_at')
  String? get cancelledAt;
  @override
  @JsonKey(name: 'ticket_no')
  String? get ticketNo;
  @override
  @JsonKey(name: 'ticket_date')
  String? get ticketDate;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RelatedBookingImplCopyWith<_$RelatedBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
