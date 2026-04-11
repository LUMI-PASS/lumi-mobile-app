// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) {
  return _AttendanceRecord.fromJson(json);
}

/// @nodoc
mixin _$AttendanceRecord {
  @JsonKey(name: "booking_id")
  String? get bookingId => throw _privateConstructorUsedError;
  @JsonKey(name: "attendance_status")
  String? get attendanceStatus => throw _privateConstructorUsedError;
  @JsonKey(name: "booking_status")
  String? get bookingStatus => throw _privateConstructorUsedError;
  @JsonKey(name: "class_name")
  String? get className => throw _privateConstructorUsedError;
  @JsonKey(name: "category_title")
  String? get categoryTitle => throw _privateConstructorUsedError;
  @JsonKey(name: "branch_title")
  String? get branchTitle => throw _privateConstructorUsedError;
  @JsonKey(name: "schedule_date")
  String? get scheduleDate => throw _privateConstructorUsedError;
  @JsonKey(name: "start_time")
  String? get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: "end_time")
  String? get endTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AttendanceRecordCopyWith<AttendanceRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceRecordCopyWith<$Res> {
  factory $AttendanceRecordCopyWith(
          AttendanceRecord value, $Res Function(AttendanceRecord) then) =
      _$AttendanceRecordCopyWithImpl<$Res, AttendanceRecord>;
  @useResult
  $Res call(
      {@JsonKey(name: "booking_id") String? bookingId,
      @JsonKey(name: "attendance_status") String? attendanceStatus,
      @JsonKey(name: "booking_status") String? bookingStatus,
      @JsonKey(name: "class_name") String? className,
      @JsonKey(name: "category_title") String? categoryTitle,
      @JsonKey(name: "branch_title") String? branchTitle,
      @JsonKey(name: "schedule_date") String? scheduleDate,
      @JsonKey(name: "start_time") String? startTime,
      @JsonKey(name: "end_time") String? endTime});
}

/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res, $Val extends AttendanceRecord>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = freezed,
    Object? attendanceStatus = freezed,
    Object? bookingStatus = freezed,
    Object? className = freezed,
    Object? categoryTitle = freezed,
    Object? branchTitle = freezed,
    Object? scheduleDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
  }) {
    return _then(_value.copyWith(
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryTitle: freezed == categoryTitle
          ? _value.categoryTitle
          : categoryTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      branchTitle: freezed == branchTitle
          ? _value.branchTitle
          : branchTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleDate: freezed == scheduleDate
          ? _value.scheduleDate
          : scheduleDate // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceRecordImplCopyWith<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  factory _$$AttendanceRecordImplCopyWith(_$AttendanceRecordImpl value,
          $Res Function(_$AttendanceRecordImpl) then) =
      __$$AttendanceRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "booking_id") String? bookingId,
      @JsonKey(name: "attendance_status") String? attendanceStatus,
      @JsonKey(name: "booking_status") String? bookingStatus,
      @JsonKey(name: "class_name") String? className,
      @JsonKey(name: "category_title") String? categoryTitle,
      @JsonKey(name: "branch_title") String? branchTitle,
      @JsonKey(name: "schedule_date") String? scheduleDate,
      @JsonKey(name: "start_time") String? startTime,
      @JsonKey(name: "end_time") String? endTime});
}

/// @nodoc
class __$$AttendanceRecordImplCopyWithImpl<$Res>
    extends _$AttendanceRecordCopyWithImpl<$Res, _$AttendanceRecordImpl>
    implements _$$AttendanceRecordImplCopyWith<$Res> {
  __$$AttendanceRecordImplCopyWithImpl(_$AttendanceRecordImpl _value,
      $Res Function(_$AttendanceRecordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = freezed,
    Object? attendanceStatus = freezed,
    Object? bookingStatus = freezed,
    Object? className = freezed,
    Object? categoryTitle = freezed,
    Object? branchTitle = freezed,
    Object? scheduleDate = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
  }) {
    return _then(_$AttendanceRecordImpl(
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryTitle: freezed == categoryTitle
          ? _value.categoryTitle
          : categoryTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      branchTitle: freezed == branchTitle
          ? _value.branchTitle
          : branchTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleDate: freezed == scheduleDate
          ? _value.scheduleDate
          : scheduleDate // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceRecordImpl implements _AttendanceRecord {
  const _$AttendanceRecordImpl(
      {@JsonKey(name: "booking_id") this.bookingId,
      @JsonKey(name: "attendance_status") this.attendanceStatus,
      @JsonKey(name: "booking_status") this.bookingStatus,
      @JsonKey(name: "class_name") this.className,
      @JsonKey(name: "category_title") this.categoryTitle,
      @JsonKey(name: "branch_title") this.branchTitle,
      @JsonKey(name: "schedule_date") this.scheduleDate,
      @JsonKey(name: "start_time") this.startTime,
      @JsonKey(name: "end_time") this.endTime});

  factory _$AttendanceRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceRecordImplFromJson(json);

  @override
  @JsonKey(name: "booking_id")
  final String? bookingId;
  @override
  @JsonKey(name: "attendance_status")
  final String? attendanceStatus;
  @override
  @JsonKey(name: "booking_status")
  final String? bookingStatus;
  @override
  @JsonKey(name: "class_name")
  final String? className;
  @override
  @JsonKey(name: "category_title")
  final String? categoryTitle;
  @override
  @JsonKey(name: "branch_title")
  final String? branchTitle;
  @override
  @JsonKey(name: "schedule_date")
  final String? scheduleDate;
  @override
  @JsonKey(name: "start_time")
  final String? startTime;
  @override
  @JsonKey(name: "end_time")
  final String? endTime;

  @override
  String toString() {
    return 'AttendanceRecord(bookingId: $bookingId, attendanceStatus: $attendanceStatus, bookingStatus: $bookingStatus, className: $className, categoryTitle: $categoryTitle, branchTitle: $branchTitle, scheduleDate: $scheduleDate, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceRecordImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.categoryTitle, categoryTitle) ||
                other.categoryTitle == categoryTitle) &&
            (identical(other.branchTitle, branchTitle) ||
                other.branchTitle == branchTitle) &&
            (identical(other.scheduleDate, scheduleDate) ||
                other.scheduleDate == scheduleDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookingId,
      attendanceStatus,
      bookingStatus,
      className,
      categoryTitle,
      branchTitle,
      scheduleDate,
      startTime,
      endTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      __$$AttendanceRecordImplCopyWithImpl<_$AttendanceRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceRecordImplToJson(
      this,
    );
  }
}

abstract class _AttendanceRecord implements AttendanceRecord {
  const factory _AttendanceRecord(
          {@JsonKey(name: "booking_id") final String? bookingId,
          @JsonKey(name: "attendance_status") final String? attendanceStatus,
          @JsonKey(name: "booking_status") final String? bookingStatus,
          @JsonKey(name: "class_name") final String? className,
          @JsonKey(name: "category_title") final String? categoryTitle,
          @JsonKey(name: "branch_title") final String? branchTitle,
          @JsonKey(name: "schedule_date") final String? scheduleDate,
          @JsonKey(name: "start_time") final String? startTime,
          @JsonKey(name: "end_time") final String? endTime}) =
      _$AttendanceRecordImpl;

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) =
      _$AttendanceRecordImpl.fromJson;

  @override
  @JsonKey(name: "booking_id")
  String? get bookingId;
  @override
  @JsonKey(name: "attendance_status")
  String? get attendanceStatus;
  @override
  @JsonKey(name: "booking_status")
  String? get bookingStatus;
  @override
  @JsonKey(name: "class_name")
  String? get className;
  @override
  @JsonKey(name: "category_title")
  String? get categoryTitle;
  @override
  @JsonKey(name: "branch_title")
  String? get branchTitle;
  @override
  @JsonKey(name: "schedule_date")
  String? get scheduleDate;
  @override
  @JsonKey(name: "start_time")
  String? get startTime;
  @override
  @JsonKey(name: "end_time")
  String? get endTime;
  @override
  @JsonKey(ignore: true)
  _$$AttendanceRecordImplCopyWith<_$AttendanceRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
