import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

@RoutePage()
class BookPdfScreen extends StatelessWidget {
  final String bookName;
  final String bookUrl;

  const BookPdfScreen({
    required this.bookName,
    required this.bookUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ChessColors.greyG20,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: GestureDetector(
            onTap: context.router.pop,
            child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
              height: 24,
              width: 24,
            ),
          ),
        ),
        title: Text(
          bookName,
        ),
      ),
      body: SfPdfViewer.network(
        bookUrl,
        canShowPaginationDialog: false,
      ),
    );
  }
}
