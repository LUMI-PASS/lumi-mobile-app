import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/profile/data/model/my_certificate/my_certificate_data.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/my_certificate_cubit/my_certificate_cubit.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/my_certificate_cubit/my_certificate_state.dart';
import 'package:founders_academy/feature/profile/presentation/widget/empty_widget.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class MyCertificateScreen extends StatefulWidget {
  const MyCertificateScreen({super.key});

  @override
  State<MyCertificateScreen> createState() => _MyCertificateScreenState();
}

class _MyCertificateScreenState extends State<MyCertificateScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('uz', null);
    Intl.defaultLocale = 'uz';
  }

  void _showAppSignatureDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? signature = prefs.getString('app_signature');

    if (signature != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: ChessColors.greyG800,
            title: Text('App Signature'),
            content: Text(signature),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case where the signature is not available
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('App Signature'),
            content: Text('Signature not found'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: context.router.pop,
            child: ChessUiKitAssets.icons.general.arrowLeft.svg(
              fit: BoxFit.none,
              color: ChessColors.white,
            ),
          ),
          centerTitle: true,
          scrolledUnderElevation: 0.0,
          title: GestureDetector(
            onLongPress: () {
              _showAppSignatureDialog(context);
            },
            child: Text(
              "Sertifikatlar",
              style: context.textTheme.headlineSemibold.copyWith(
                color: ChessColors.greyG10,
              ),
            ),
          ),
        ),
        body: BlocProvider(
          create: (context) => getIt<MyCertificateCubit>()..init(),
          child: BlocBuilder<MyCertificateCubit, MyCertificateState>(
            builder: (context, state) {
              return switch (state) {
                MyCertificateInitState() => const Center(
                    child: ChessCircularProgressIndicator(),
                  ),
                MyCertificateLoadedState() => state.myCertificateData.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.myCertificateData.length,
                        itemBuilder: (context, index) {
                          return _BodyContent(
                              myCertificateData:
                                  state.myCertificateData[index]);
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                      )
                    : const EmptyCertificateCenter(),
                MyCertificateErrorState() => const SizedBox.expand(),
              };
            },
          ),
        ));
  }
}

class _BodyContent extends StatefulWidget {
  final MyCertificateData myCertificateData;

  const _BodyContent({required this.myCertificateData});

  @override
  State<_BodyContent> createState() => _BodyContentState();
}

String formatUzbekDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  String formattedDate = DateFormat("y 'yil' d MMMM ", 'uz').format(parsedDate);
  return formattedDate;
}

class _BodyContentState extends State<_BodyContent> {
  @override
  Widget build(BuildContext context) {
    String formattedDate =
        formatUzbekDate(widget.myCertificateData.finishDate ?? "");
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context.router.push(
              MyCertificatePdfRoute(
                bookName: widget.myCertificateData.courseTitle ?? "",
                bookUrl:
                    "${state.baseUrl}${widget.myCertificateData.certificate}",
              ),
            );
            // print("${state.baseUrl}${widget.myCertificateData.certificate}");
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: ChessShadows.shadowLg,
              color: ChessColors.white,
              borderRadius: ChessRadius.radiusSm,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image(),
                  const SizedBox(height: 16),
                  Text(
                    "${widget.myCertificateData.courseTitle} sertifikati",
                    style: context.textTheme.headlineSemibold.copyWith(
                      color: ChessColors.greyG90,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ChessUiKitAssets.icons.course.timeQuarterPass.svg(
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          ChessColors.greyG200,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${formattedDate}da yakunlandi",
                        style: context.textTheme.footnoteRegular.copyWith(
                          color: ChessColors.greyG200,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget image() {
    return ChessUiKitAssets.icons.course.certificate2.image(
      height: 66,
      width: 85,
    );
  }
}
