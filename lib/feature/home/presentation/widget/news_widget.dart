import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/news/news_data.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnhancedNewsWidget extends StatefulWidget {
  final NewsData newsData;
  final VoidCallback? onTap;

  const EnhancedNewsWidget({
    required this.newsData,
    this.onTap,
    super.key,
  });

  @override
  State<EnhancedNewsWidget> createState() => _EnhancedNewsWidgetState();
}

class _EnhancedNewsWidgetState extends State<EnhancedNewsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
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
            context.router.push(
              NewsDetailsRoute(id: widget.newsData.id),
            );
            FirebaseAnalytics.instance.logEvent(
              name: 'yangiliklar_event',
              parameters: {
                'param1': 'value1',
                'param2': 123,
              },
            ).then((value) {
              logger.e('Event successfully logged');
            }).catchError((error) {
              logger.e('Failed to log event: $error');
            });
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ChessColors.greyG800.withOpacity(0.8),
                      ChessColors.greyG700.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: ChessRadius.radiusLg,
                  border: Border.all(
                    color: ChessColors.primaryDefault.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ChessColors.greyG900.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: ChessColors.primaryDefault.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Enhanced News Image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: ChessRadius.radiusMd,
                          border: Border.all(
                            color: ChessColors.primaryDefault.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ChessColors.greyG900.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: ChessRadius.radiusMd,
                              child: ChessNetworkImage(
                                imageUrl: widget.newsData.imageUrl,
                                height: 80,
                                width: 120,
                                fit: BoxFit.cover,
                                baseUrl: state.baseUrl,
                              ),
                            ),

                            // News Badge
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: ChessColors.primaryDefault,
                                  borderRadius: ChessRadius.radiusSm,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ChessColors.primaryDefault
                                          .withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.article_outlined,
                                      color: ChessColors.white,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "NEWS",
                                      style: TextStyle(
                                        color: ChessColors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Enhanced News Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // News Title
                            Text(
                              widget.newsData.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.calloutMedium.copyWith(
                                color: ChessColors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Date and Reading Time
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        ChessColors.greyG700.withOpacity(0.6),
                                    borderRadius: ChessRadius.radiusSm,
                                    border: Border.all(
                                      color: ChessColors.primaryDefault
                                          .withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: ChessColors.greyG300,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.newsData.date.formattedDate,
                                        style: context.textTheme.footnoteRegular
                                            .copyWith(
                                          color: ChessColors.greyG300,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),

                                // Read More Indicator
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: ChessColors.primaryDefault
                                        .withOpacity(0.2),
                                    borderRadius: ChessRadius.radiusSm,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: ChessColors.primaryDefault,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Read indicator
                            Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  color: ChessColors.greyG400,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "O'qish uchun bosing",
                                  style: TextStyle(
                                    color: ChessColors.greyG400,
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
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
          ),
        );
      },
    );
  }
}
