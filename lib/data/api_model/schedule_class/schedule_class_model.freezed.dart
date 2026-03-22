// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_class_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduleClassModel _$ScheduleClassModelFromJson(Map<String, dynamic> json) {
  return _ScheduleClassModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleClassModel {
  bool? get success => throw _privateConstructorUsedError;
  ScheduleData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleClassModelCopyWith<ScheduleClassModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleClassModelCopyWith<$Res> {
  factory $ScheduleClassModelCopyWith(
          ScheduleClassModel value, $Res Function(ScheduleClassModel) then) =
      _$ScheduleClassModelCopyWithImpl<$Res, ScheduleClassModel>;
  @useResult
  $Res call({bool? success, ScheduleData? data});

  $ScheduleDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$ScheduleClassModelCopyWithImpl<$Res, $Val extends ScheduleClassModel>
    implements $ScheduleClassModelCopyWith<$Res> {
  _$ScheduleClassModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ScheduleData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ScheduleDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $ScheduleDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScheduleClassModelImplCopyWith<$Res>
    implements $ScheduleClassModelCopyWith<$Res> {
  factory _$$ScheduleClassModelImplCopyWith(_$ScheduleClassModelImpl value,
          $Res Function(_$ScheduleClassModelImpl) then) =
      __$$ScheduleClassModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, ScheduleData? data});

  @override
  $ScheduleDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$ScheduleClassModelImplCopyWithImpl<$Res>
    extends _$ScheduleClassModelCopyWithImpl<$Res, _$ScheduleClassModelImpl>
    implements _$$ScheduleClassModelImplCopyWith<$Res> {
  __$$ScheduleClassModelImplCopyWithImpl(_$ScheduleClassModelImpl _value,
      $Res Function(_$ScheduleClassModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_$ScheduleClassModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as ScheduleData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleClassModelImpl implements _ScheduleClassModel {
  const _$ScheduleClassModelImpl({this.success, this.data});

  factory _$ScheduleClassModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleClassModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final ScheduleData? data;

  @override
  String toString() {
    return 'ScheduleClassModel(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleClassModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleClassModelImplCopyWith<_$ScheduleClassModelImpl> get copyWith =>
      __$$ScheduleClassModelImplCopyWithImpl<_$ScheduleClassModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleClassModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleClassModel implements ScheduleClassModel {
  const factory _ScheduleClassModel(
      {final bool? success,
      final ScheduleData? data}) = _$ScheduleClassModelImpl;

  factory _ScheduleClassModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleClassModelImpl.fromJson;

  @override
  bool? get success;
  @override
  ScheduleData? get data;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleClassModelImplCopyWith<_$ScheduleClassModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleData _$ScheduleDataFromJson(Map<String, dynamic> json) {
  return _ScheduleData.fromJson(json);
}

/// @nodoc
mixin _$ScheduleData {
  @JsonKey(name: 'class_id')
  String? get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_id')
  String? get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'from_date')
  String? get fromDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_date')
  String? get toDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_slots')
  List<TimeSlot>? get timeSlots => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_slots')
  int? get totalSlots => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_slots')
  int? get availableSlots => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleDataCopyWith<ScheduleData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleDataCopyWith<$Res> {
  factory $ScheduleDataCopyWith(
          ScheduleData value, $Res Function(ScheduleData) then) =
      _$ScheduleDataCopyWithImpl<$Res, ScheduleData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'class_id') String? classId,
      @JsonKey(name: 'child_id') String? childId,
      @JsonKey(name: 'from_date') String? fromDate,
      @JsonKey(name: 'to_date') String? toDate,
      @JsonKey(name: 'time_slots') List<TimeSlot>? timeSlots,
      @JsonKey(name: 'total_slots') int? totalSlots,
      @JsonKey(name: 'available_slots') int? availableSlots});
}

/// @nodoc
class _$ScheduleDataCopyWithImpl<$Res, $Val extends ScheduleData>
    implements $ScheduleDataCopyWith<$Res> {
  _$ScheduleDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = freezed,
    Object? childId = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? timeSlots = freezed,
    Object? totalSlots = freezed,
    Object? availableSlots = freezed,
  }) {
    return _then(_value.copyWith(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as String?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSlots: freezed == timeSlots
          ? _value.timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>?,
      totalSlots: freezed == totalSlots
          ? _value.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleDataImplCopyWith<$Res>
    implements $ScheduleDataCopyWith<$Res> {
  factory _$$ScheduleDataImplCopyWith(
          _$ScheduleDataImpl value, $Res Function(_$ScheduleDataImpl) then) =
      __$$ScheduleDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'class_id') String? classId,
      @JsonKey(name: 'child_id') String? childId,
      @JsonKey(name: 'from_date') String? fromDate,
      @JsonKey(name: 'to_date') String? toDate,
      @JsonKey(name: 'time_slots') List<TimeSlot>? timeSlots,
      @JsonKey(name: 'total_slots') int? totalSlots,
      @JsonKey(name: 'available_slots') int? availableSlots});
}

/// @nodoc
class __$$ScheduleDataImplCopyWithImpl<$Res>
    extends _$ScheduleDataCopyWithImpl<$Res, _$ScheduleDataImpl>
    implements _$$ScheduleDataImplCopyWith<$Res> {
  __$$ScheduleDataImplCopyWithImpl(
      _$ScheduleDataImpl _value, $Res Function(_$ScheduleDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = freezed,
    Object? childId = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? timeSlots = freezed,
    Object? totalSlots = freezed,
    Object? availableSlots = freezed,
  }) {
    return _then(_$ScheduleDataImpl(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      fromDate: freezed == fromDate
          ? _value.fromDate
          : fromDate // ignore: cast_nullable_to_non_nullable
              as String?,
      toDate: freezed == toDate
          ? _value.toDate
          : toDate // ignore: cast_nullable_to_non_nullable
              as String?,
      timeSlots: freezed == timeSlots
          ? _value._timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>?,
      totalSlots: freezed == totalSlots
          ? _value.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int?,
      availableSlots: freezed == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleDataImpl implements _ScheduleData {
  const _$ScheduleDataImpl(
      {@JsonKey(name: 'class_id') this.classId,
      @JsonKey(name: 'child_id') this.childId,
      @JsonKey(name: 'from_date') this.fromDate,
      @JsonKey(name: 'to_date') this.toDate,
      @JsonKey(name: 'time_slots') final List<TimeSlot>? timeSlots,
      @JsonKey(name: 'total_slots') this.totalSlots,
      @JsonKey(name: 'available_slots') this.availableSlots})
      : _timeSlots = timeSlots;

  factory _$ScheduleDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleDataImplFromJson(json);

  @override
  @JsonKey(name: 'class_id')
  final String? classId;
  @override
  @JsonKey(name: 'child_id')
  final String? childId;
  @override
  @JsonKey(name: 'from_date')
  final String? fromDate;
  @override
  @JsonKey(name: 'to_date')
  final String? toDate;
  final List<TimeSlot>? _timeSlots;
  @override
  @JsonKey(name: 'time_slots')
  List<TimeSlot>? get timeSlots {
    final value = _timeSlots;
    if (value == null) return null;
    if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'total_slots')
  final int? totalSlots;
  @override
  @JsonKey(name: 'available_slots')
  final int? availableSlots;

  @override
  String toString() {
    return 'ScheduleData(classId: $classId, childId: $childId, fromDate: $fromDate, toDate: $toDate, timeSlots: $timeSlots, totalSlots: $totalSlots, availableSlots: $availableSlots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleDataImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            const DeepCollectionEquality()
                .equals(other._timeSlots, _timeSlots) &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      classId,
      childId,
      fromDate,
      toDate,
      const DeepCollectionEquality().hash(_timeSlots),
      totalSlots,
      availableSlots);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleDataImplCopyWith<_$ScheduleDataImpl> get copyWith =>
      __$$ScheduleDataImplCopyWithImpl<_$ScheduleDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleDataImplToJson(
      this,
    );
  }
}

abstract class _ScheduleData implements ScheduleData {
  const factory _ScheduleData(
          {@JsonKey(name: 'class_id') final String? classId,
          @JsonKey(name: 'child_id') final String? childId,
          @JsonKey(name: 'from_date') final String? fromDate,
          @JsonKey(name: 'to_date') final String? toDate,
          @JsonKey(name: 'time_slots') final List<TimeSlot>? timeSlots,
          @JsonKey(name: 'total_slots') final int? totalSlots,
          @JsonKey(name: 'available_slots') final int? availableSlots}) =
      _$ScheduleDataImpl;

  factory _ScheduleData.fromJson(Map<String, dynamic> json) =
      _$ScheduleDataImpl.fromJson;

  @override
  @JsonKey(name: 'class_id')
  String? get classId;
  @override
  @JsonKey(name: 'child_id')
  String? get childId;
  @override
  @JsonKey(name: 'from_date')
  String? get fromDate;
  @override
  @JsonKey(name: 'to_date')
  String? get toDate;
  @override
  @JsonKey(name: 'time_slots')
  List<TimeSlot>? get timeSlots;
  @override
  @JsonKey(name: 'total_slots')
  int? get totalSlots;
  @override
  @JsonKey(name: 'available_slots')
  int? get availableSlots;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleDataImplCopyWith<_$ScheduleDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) {
  return _TimeSlot.fromJson(json);
}

/// @nodoc
mixin _$TimeSlot {
  @JsonKey(name: 'schedule_id')
  String? get scheduleId => throw _privateConstructorUsedError;
  @JsonKey(name: 'for_date')
  String? get forDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  String? get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String? get endTime => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  @JsonKey(name: 'booked_count')
  int? get bookedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'empty_seats')
  int? get emptySeats => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_booking_conflict')
  bool? get isBookingConflict => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_available')
  bool? get isAvailable => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeSlotCopyWith<TimeSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSlotCopyWith<$Res> {
  factory $TimeSlotCopyWith(TimeSlot value, $Res Function(TimeSlot) then) =
      _$TimeSlotCopyWithImpl<$Res, TimeSlot>;
  @useResult
  $Res call(
      {@JsonKey(name: 'schedule_id') String? scheduleId,
      @JsonKey(name: 'for_date') String? forDate,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'end_time') String? endTime,
      int? capacity,
      @JsonKey(name: 'booked_count') int? bookedCount,
      @JsonKey(name: 'empty_seats') int? emptySeats,
      @JsonKey(name: 'is_booking_conflict') bool? isBookingConflict,
      @JsonKey(name: 'is_available') bool? isAvailable});
}

/// @nodoc
class _$TimeSlotCopyWithImpl<$Res, $Val extends TimeSlot>
    implements $TimeSlotCopyWith<$Res> {
  _$TimeSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = freezed,
    Object? forDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? capacity = freezed,
    Object? bookedCount = freezed,
    Object? emptySeats = freezed,
    Object? isBookingConflict = freezed,
    Object? isAvailable = freezed,
  }) {
    return _then(_value.copyWith(
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
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
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      bookedCount: freezed == bookedCount
          ? _value.bookedCount
          : bookedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      emptySeats: freezed == emptySeats
          ? _value.emptySeats
          : emptySeats // ignore: cast_nullable_to_non_nullable
              as int?,
      isBookingConflict: freezed == isBookingConflict
          ? _value.isBookingConflict
          : isBookingConflict // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAvailable: freezed == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeSlotImplCopyWith<$Res>
    implements $TimeSlotCopyWith<$Res> {
  factory _$$TimeSlotImplCopyWith(
          _$TimeSlotImpl value, $Res Function(_$TimeSlotImpl) then) =
      __$$TimeSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'schedule_id') String? scheduleId,
      @JsonKey(name: 'for_date') String? forDate,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'end_time') String? endTime,
      int? capacity,
      @JsonKey(name: 'booked_count') int? bookedCount,
      @JsonKey(name: 'empty_seats') int? emptySeats,
      @JsonKey(name: 'is_booking_conflict') bool? isBookingConflict,
      @JsonKey(name: 'is_available') bool? isAvailable});
}

/// @nodoc
class __$$TimeSlotImplCopyWithImpl<$Res>
    extends _$TimeSlotCopyWithImpl<$Res, _$TimeSlotImpl>
    implements _$$TimeSlotImplCopyWith<$Res> {
  __$$TimeSlotImplCopyWithImpl(
      _$TimeSlotImpl _value, $Res Function(_$TimeSlotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = freezed,
    Object? forDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? capacity = freezed,
    Object? bookedCount = freezed,
    Object? emptySeats = freezed,
    Object? isBookingConflict = freezed,
    Object? isAvailable = freezed,
  }) {
    return _then(_$TimeSlotImpl(
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
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
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      bookedCount: freezed == bookedCount
          ? _value.bookedCount
          : bookedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      emptySeats: freezed == emptySeats
          ? _value.emptySeats
          : emptySeats // ignore: cast_nullable_to_non_nullable
              as int?,
      isBookingConflict: freezed == isBookingConflict
          ? _value.isBookingConflict
          : isBookingConflict // ignore: cast_nullable_to_non_nullable
              as bool?,
      isAvailable: freezed == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeSlotImpl implements _TimeSlot {
  const _$TimeSlotImpl(
      {@JsonKey(name: 'schedule_id') this.scheduleId,
      @JsonKey(name: 'for_date') this.forDate,
      @JsonKey(name: 'start_time') this.startTime,
      @JsonKey(name: 'end_time') this.endTime,
      this.capacity,
      @JsonKey(name: 'booked_count') this.bookedCount,
      @JsonKey(name: 'empty_seats') this.emptySeats,
      @JsonKey(name: 'is_booking_conflict') this.isBookingConflict,
      @JsonKey(name: 'is_available') this.isAvailable});

  factory _$TimeSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSlotImplFromJson(json);

  @override
  @JsonKey(name: 'schedule_id')
  final String? scheduleId;
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
  final int? capacity;
  @override
  @JsonKey(name: 'booked_count')
  final int? bookedCount;
  @override
  @JsonKey(name: 'empty_seats')
  final int? emptySeats;
  @override
  @JsonKey(name: 'is_booking_conflict')
  final bool? isBookingConflict;
  @override
  @JsonKey(name: 'is_available')
  final bool? isAvailable;

  @override
  String toString() {
    return 'TimeSlot(scheduleId: $scheduleId, forDate: $forDate, startTime: $startTime, endTime: $endTime, capacity: $capacity, bookedCount: $bookedCount, emptySeats: $emptySeats, isBookingConflict: $isBookingConflict, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSlotImpl &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.forDate, forDate) || other.forDate == forDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.bookedCount, bookedCount) ||
                other.bookedCount == bookedCount) &&
            (identical(other.emptySeats, emptySeats) ||
                other.emptySeats == emptySeats) &&
            (identical(other.isBookingConflict, isBookingConflict) ||
                other.isBookingConflict == isBookingConflict) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      scheduleId,
      forDate,
      startTime,
      endTime,
      capacity,
      bookedCount,
      emptySeats,
      isBookingConflict,
      isAvailable);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      __$$TimeSlotImplCopyWithImpl<_$TimeSlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSlotImplToJson(
      this,
    );
  }
}

abstract class _TimeSlot implements TimeSlot {
  const factory _TimeSlot(
      {@JsonKey(name: 'schedule_id') final String? scheduleId,
      @JsonKey(name: 'for_date') final String? forDate,
      @JsonKey(name: 'start_time') final String? startTime,
      @JsonKey(name: 'end_time') final String? endTime,
      final int? capacity,
      @JsonKey(name: 'booked_count') final int? bookedCount,
      @JsonKey(name: 'empty_seats') final int? emptySeats,
      @JsonKey(name: 'is_booking_conflict') final bool? isBookingConflict,
      @JsonKey(name: 'is_available') final bool? isAvailable}) = _$TimeSlotImpl;

  factory _TimeSlot.fromJson(Map<String, dynamic> json) =
      _$TimeSlotImpl.fromJson;

  @override
  @JsonKey(name: 'schedule_id')
  String? get scheduleId;
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
  int? get capacity;
  @override
  @JsonKey(name: 'booked_count')
  int? get bookedCount;
  @override
  @JsonKey(name: 'empty_seats')
  int? get emptySeats;
  @override
  @JsonKey(name: 'is_booking_conflict')
  bool? get isBookingConflict;
  @override
  @JsonKey(name: 'is_available')
  bool? get isAvailable;
  @override
  @JsonKey(ignore: true)
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
