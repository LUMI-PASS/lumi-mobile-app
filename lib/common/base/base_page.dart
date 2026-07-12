import 'package:lumi_pass/common/base/base_builder.dart';
import 'package:lumi_pass/common/widget/error_view.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'base_listener.dart';
import 'base_state.dart';

abstract class BasePage<CUBIT extends Cubit<BaseState<BUILDABLE, LISTENABLE>>,
    BUILDABLE, LISTENABLE> extends StatefulWidget {
  const BasePage({super.key});

  Widget builder(BuildContext context, BUILDABLE state);

  void listener(BuildContext context, LISTENABLE state) {}

  void init(BuildContext context) {}

  void onFocusGained(BuildContext context) {}

  void dispose() {}

  void setState(VoidCallback fn) {}

  Widget loadable({
    required bool loading,
    required bool error,
    VoidCallback? retry,
    required Widget Function() builder,
  }) {
    if (loading) return const LoadingView();
    if (error) {
      return Builder(builder: (context) {
        return ErrorView(retry: () => retry == null ? init(context) : retry());
      });
    }
    return builder();
  }

  @override
  State<BasePage> createState() =>
      _BasePageState<CUBIT, BUILDABLE, LISTENABLE>();
}

class _BasePageState<CUBIT extends Cubit<BaseState<BUILDABLE, LISTENABLE>>,
    BUILDABLE, LISTENABLE> extends State<BasePage> {
  bool initialized = false;

  @override
  void dispose() {
    super.dispose();
    widget.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    widget.setState(fn);
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    bool lost = false;
    // No global tap GestureDetector here (the old KeyboardDismisser): MyApp is
    // a BasePage, so it would sit above the iOS 26 native UiKitView tab bar,
    // win the gesture arena on tap and cancel the bar's touches. Keyboard
    // dismissal is handled arena-free by the root Listener in main.dart.
    return BlocProvider<CUBIT>(
      create: (_) => getIt<CUBIT>(),
      child: Builder(
        builder: (context) {
          if (!initialized) {
            widget.init(context);
            initialized = true;
          }
          return FocusDetector(
            onFocusGained: () {
              if (!lost) return;
              widget.onFocusGained(context);
            },
            onFocusLost: () => lost = true,
            child: BaseListener<CUBIT, BUILDABLE, LISTENABLE>(
              listener: (listenable) => widget.listener(context, listenable),
              child: BaseBuilder<CUBIT, BUILDABLE, LISTENABLE>(
                  builder: widget.builder),
            ),
          );
        },
      ),
    );
  }
}
