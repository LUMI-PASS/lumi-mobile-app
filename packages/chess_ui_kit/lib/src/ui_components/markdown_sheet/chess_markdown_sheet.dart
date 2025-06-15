import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChessMarkdownSheet extends StatelessWidget {
  final String text;
  final String sheetTitle;
  final String asset;

  const ChessMarkdownSheet({
    super.key,
    required this.text,
    required this.sheetTitle,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return ChessLinkedText(
      text: text,
      onLinkTap: () => showPolicySheet(
        context,
        asset: asset,
        sheetTitle: sheetTitle,
      ),
    );
  }

  static void showPolicySheet(
    BuildContext context, {
    required String asset,
    required String sheetTitle,
  }) async {
    final loadMarkdown = DefaultAssetBundle.of(context).loadString(asset);

    loadMarkdown.then(
      (data) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: ChessColors.greyG900,
        builder: (_) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Text(sheetTitle, style: context.textTheme.caption1Medium.copyWith(color: ChessColors.greyG40)),
              const SizedBox(height: 8.0),
              const Divider(),
              Expanded(child: Markdown(data: data)),
            ],
          ),
        ),
      ),
    );
  }
}
