import 'dart:io' if (dart.library.html) 'package:lumi_pass/common/stubs/io_stub.dart';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';
import 'package:lumi_pass/data/api_model/eligibility/eligibility_model.dart';
import 'package:lumi_pass/data/api_model/booking/booking_model.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'children_state.dart';

@injectable
class ChildrenCubit extends BaseCubit<ChildrenBuildable, ChildrenListenable> {
  ChildrenCubit(this._repo) : super(const ChildrenBuildable());
  final HomeRepository _repo;

  Future<void> getChildren() {
    return callable(
      future: _repo.getParentProfile(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (ParentProfileResult data) {
        // Merge trial data into children (same as webapp)
        final trialSummary = data.trialSummary;
        final trialByChildId = <String, TrialSummaryChild>{};
        if (trialSummary != null) {
          for (final entry in trialSummary.children) {
            if (entry.childId != null) {
              trialByChildId[entry.childId!] = entry;
            }
          }
        }

        final children = data.children.map((child) {
          final trial = trialByChildId[child.id];
          if (trial != null) {
            return child.copyWith(
              remainingTrials: trial.remainingTrials,
              coinsIntoUnlockCycle: trial.coinsIntoUnlockCycle,
              coinsToNextUnlock: trial.coinsToNextUnlock,
              nextUnlockAtTotalPaidCoins: trial.nextUnlockAtTotalPaidCoins,
              unlockThresholdCoin: trialSummary?.unlockThresholdCoin,
            );
          }
          return child;
        }).toList();

        return buildable.copyWith(
          childrenList: children,
          trialSummary: trialSummary,
          parentCity: data.parentCity ?? 'Tashkent',
          parentDistrict: data.parentDistrict ?? '',
        );
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

  Future<void> checkClassEligibility(String classId) {
    return callable(
      future: _repo.checkClassEligibility(classId),
      buildOnStart: () => buildable.copyWith(eligibilityLoading: true),
      buildOnData: (ClassEligibilityData data) {
        return buildable.copyWith(eligibilityData: data);
      },
      invokeOnData: (data) => const ChildrenListenable(
        effect: ChildrenEffect.eligibilityLoaded,
      ),
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
      buildOnDone: () => buildable.copyWith(eligibilityLoading: false),
    );
  }

  Future<void> createBooking(
      String scheduleId, String childId, String subscriptionId) {
    return callable(
      future: _repo.createBooking(scheduleId, childId, subscriptionId),
      buildOnStart: () => buildable.copyWith(bookingLoading: true),
      invokeOnData: (BookingResponse data) => ChildrenListenable(
        effect: ChildrenEffect.bookingSuccess,
        bookingId: data.id,
      ),
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        } else {
          display.error("Booking failed. Please try again.");
        }
      },
      buildOnDone: () => buildable.copyWith(bookingLoading: false),
    );
  }

  Future<void> getClassScheduleList(
      String childId, String fromDate, String toDate, String classId) {
    return callable(
      future: _repo.getCLassSchedules(childId, fromDate, toDate, classId),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (List<TimeSlot> data) {
        return buildable.copyWith(timeSlots: data);
      },
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          } else {
            display.error(error);
          }
        } else {
          display.error(error);
        }
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

  /// Save a child and, when one was picked, its photo — the two calls the
  /// child-details screen needs. A new child has to be created first, because
  /// the photo endpoint is keyed by child id.
  ///
  /// A failed photo upload does not fail the save: the name/age/gender are
  /// already persisted at that point, so we surface the error and still report
  /// success.
  Future<void> saveChild(
    ChildModel childModel,
    bool isUpdate,
    File? photo,
  ) async {
    build((buildable) => buildable.copyWith(buttonLoading: true));
    try {
      String? childId = childModel.id;
      if (isUpdate) {
        await _repo.updateChild(childModel, childModel.id!);
      } else {
        childId = await _repo.addChildAndGetId(childModel);
      }

      if (photo != null && childId != null) {
        try {
          await _repo.uploadChildPhoto(childId, photo);
        } catch (_) {
          display.error('photo_upload_failed'.tr());
        }
      }

      invoke(const ChildrenListenable(effect: ChildrenEffect.verify));
    } catch (error) {
      if (error is DioException &&
          (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502)) {
        display.error(Strings.serverErrorTryLater);
      } else {
        display.error(error);
      }
    } finally {
      build((buildable) => buildable.copyWith(buttonLoading: false));
    }
  }

  Future<void> deleteChild(String childId) {
    return callable(
      future: _repo.deleteChild(childId),
      buildOnStart: () => buildable.copyWith(buttonLoading: true),
      invokeOnData: (_) =>
          const ChildrenListenable(effect: ChildrenEffect.verify),
      onErrorData: (error) {
        if (error is DioException &&
            (error.response?.statusCode == 500 ||
                error.response?.statusCode == 502)) {
          display.error(Strings.serverErrorTryLater);
        } else {
          display.error(error);
        }
      },
      buildOnDone: () => buildable.copyWith(buttonLoading: false),
    );
  }

  /// Add child and get back the child ID (for stepper flow)
  Future<void> addChildAndGetId(ChildModel childModel) {
    return callable(
      future: _repo.addChildAndGetId(childModel),
      buildOnStart: () => buildable.copyWith(buttonLoading: true),
      buildOnData: (String childId) {
        return buildable.copyWith(newChildId: childId, currentStep: 1);
      },
      invokeOnData: (String childId) => const ChildrenListenable(
        effect: ChildrenEffect.childCreated,
      ),
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          } else {
            display.error(error);
          }
        }
      },
      buildOnDone: () => buildable.copyWith(buttonLoading: false),
    );
  }

  /// Upload child photo
  Future<void> uploadChildPhoto(String childId, File photo) {
    return callable(
      future: _repo.uploadChildPhoto(childId, photo),
      buildOnStart: () => buildable.copyWith(buttonLoading: true),
      invokeOnData: (_) => const ChildrenListenable(
        effect: ChildrenEffect.photoUploaded,
      ),
      onErrorData: (error) {
        if (error is DioException) {
          display.error("Failed to upload photo");
        }
        invoke(const ChildrenListenable(
          effect: ChildrenEffect.photoUploadError,
        ));
      },
      buildOnDone: () => buildable.copyWith(buttonLoading: false),
    );
  }

  void setStep(int step) {
    build((buildable) => buildable.copyWith(currentStep: step));
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

  void selectChild(String? childId) {
    build((buildable) => buildable.copyWith(selectedChildId: childId));
  }

  // Ticket booking selection methods
  void selectDate(DateTime date) {
    build((buildable) => buildable.copyWith(
          selectedDate: date,
          selectedTimeIndex: -1,
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
