import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

import 'schedule_state.dart';

/// Cubit that backs the Bookings tab (previously Calendar). One list item =
/// one order/transaction. Renamed internally: the class name stays as
/// `ScheduleCubit` so the generated DI config continues to compile without
/// a rebuild.
@injectable
class ScheduleCubit extends BaseCubit<ScheduleBuildable, ScheduleListenable> {
  ScheduleCubit(this._ordersApi) : super(const ScheduleBuildable());

  final OrdersApi _ordersApi;

  Future<void> loadBookings() {
    return callable(
      future: _ordersApi.getOrders(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (orders) => buildable.copyWith(
        orders: orders,
      ),
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          }
        }
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  /// Silent refresh (used on tab focus) — no spinner.
  Future<void> refreshSilently() async {
    try {
      final orders = await _ordersApi.getOrders();
      build((b) => b.copyWith(orders: orders));
    } catch (_) {}
  }
}
