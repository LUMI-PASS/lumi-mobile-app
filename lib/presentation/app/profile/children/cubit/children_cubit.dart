import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'children_state.dart';

@injectable
class ChildrenCubit extends BaseCubit<ChildrenBuildable, ChildrenListenable> {
  ChildrenCubit(this._repo) : super(const ChildrenBuildable());
  final HomeRepository _repo;

  Future<void> getChildren() {
    return callable(
      future: _repo.getChildren(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (data) {
        return buildable.copyWith(childrenList: data);
      },
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  Future<void> getClassScheduleList(
      String childId, String fromDate, String toDate, String classId) {
    return callable(
      future: _repo.getCLassSchedules(childId, fromDate, toDate, classId),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (List<TimeSlot> data) {
        return buildable.copyWith(timeSlots: data); // Changed from slots to timeSlots
      },
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  Future<void> submit(ChildModel childModel, bool isUpdate) {
    return callable(
      future: isUpdate
          ? _repo.updateChild(childModel, childModel.id!)
          : _repo.addChild(childModel),
      buildOnStart: () => buildable.copyWith(buttonLoading: true),
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
        display.error(error);
      },
      invokeOnData: (data) =>
      const ChildrenListenable(effect: ChildrenEffect.verify),
      buildOnDone: () => buildable.copyWith(buttonLoading: false),
    );
  }

  void changeGender(String isMatched) {
    build((buildable) => buildable.copyWith(selectedGender: isMatched));
  }

  void setBirthDate(DateTime? isMatched) {
    build((buildable) => buildable.copyWith(selectedBirthDate: isMatched));
  }

  void selectIndex(int index) {
    build((buildable) => buildable.copyWith(selectedIndex: index));
  }

  // Ticket booking selection methods
  void selectDate(DateTime date) {
    build((buildable) => buildable.copyWith(
      selectedDate: date,
      selectedTimeIndex: -1, // Reset time selection when date changes
      selectedScheduleId: null,
    ));
  }

  void selectTimeSlot(int timeIndex, String scheduleId) {
    build((buildable) => buildable.copyWith(
      selectedTimeIndex: timeIndex,
      selectedScheduleId: scheduleId,
    ));
  }

  void resetTicketSelection() {
    build((buildable) => buildable.copyWith(
      selectedDate: null,
      selectedTimeIndex: -1,
      selectedScheduleId: null,
    ));
  }
}