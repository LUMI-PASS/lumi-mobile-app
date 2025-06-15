import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ItemsListScreen extends StatelessWidget {
  final String title;
  final Widget body;

  const ItemsListScreen({
    required this.title,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: context.router.pop,
          child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
            height: 24,
            width: 24,
            fit: BoxFit.none,
            color: ChessColors.white
          ),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: context.textTheme.bodyMedium.copyWith(
            color: ChessColors.white,
          ),
        ),
      ),
      body: body,
    );
  }
}
