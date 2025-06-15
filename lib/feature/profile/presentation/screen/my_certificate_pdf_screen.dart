import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

@RoutePage()
class MyCertificatePdfScreen extends StatefulWidget {
  final String bookName;
  final String bookUrl;

  const MyCertificatePdfScreen({
    required this.bookName,
    required this.bookUrl,
    super.key,
  });

  @override
  MyCertificatePdfScreenState createState() => MyCertificatePdfScreenState();
}

class MyCertificatePdfScreenState extends State<MyCertificatePdfScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
          widget.bookName,
        ),
        actions: [
          IconButton(
            icon: ChessUiKitAssets.icons.general.download01.svg(
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                ChessColors.primaryDefault,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () async {
              try {
                // Get the directory to save the file.
                Directory directory;

                if (Platform.isAndroid) {
                  directory = await getExternalStorageDirectory() ??
                      await getApplicationDocumentsDirectory();
                } else if (Platform.isIOS) {
                  directory = await getApplicationDocumentsDirectory();
                } else {
                  // For other platforms, use the current directory.
                  directory = await getApplicationDocumentsDirectory();
                }

                String sanitizedFileName =
                    widget.bookName.replaceAll(RegExp(r'[^\w\s]+'), '');
                String filePath = '${directory.path}/$sanitizedFileName.pdf';

                // Check if file exists, if so, delete it
                File file = File(filePath);
                if (await file.exists()) {
                  await file.delete();
                }

                // Download the file
                Dio dio = Dio();
                await dio.download(widget.bookUrl, filePath);

                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Fayl yuklandi: ${directory.path}')),
                // );

                // Open the file
                await OpenFilex.open(filePath);
              } catch (e) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Yuklashda xatolik yuz berdi: $e')),
                // );
              }
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.bookUrl,
        canShowPaginationDialog: false,
      ),
    );
  }
}
