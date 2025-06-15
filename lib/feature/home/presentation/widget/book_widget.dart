import 'dart:math' as logger;
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/home/data/model/book/book_data.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';

class EnhancedBookWidget extends StatefulWidget {
  final BookData book;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  const EnhancedBookWidget({
    required this.book,
    super.key,
    this.height,
    this.width,
    this.onTap,
  });

  @override
  State<EnhancedBookWidget> createState() => _EnhancedBookWidgetState();
}

class _EnhancedBookWidgetState extends State<EnhancedBookWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          onTap: () {
            widget.onTap?.call();
            context.router.push(BookDetailsRoute(id: widget.book.id));
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width ?? 130,
                decoration: BoxDecoration(
                  borderRadius: ChessRadius.radiusLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: ChessRadius.radiusLg,
                        border: Border.all(
                          color: ChessColors.primaryDefault.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ChessColors.greyG900.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: ChessRadius.radiusLg,
                            child: ChessNetworkImage(
                              imageUrl: widget.book.image,
                              height: widget.height ?? 160,
                              width: widget.width ?? 130,
                              fit: BoxFit.cover,
                              baseUrl: state.baseUrl,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: ChessRadius.radiusLg,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    ChessColors.greyG900.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ChessColors.greyG900.withOpacity(0.7),
                                borderRadius: ChessRadius.radiusSm,
                                border: Border.all(
                                  color: ChessColors.primaryDefault.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: ChessColors.primaryDefault,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.caption1Medium.copyWith(
                              color: ChessColors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(
                                Icons.auto_stories,
                                color: ChessColors.primaryDefault,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Kitob",
                                style: TextStyle(
                                  color: ChessColors.greyG400,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}