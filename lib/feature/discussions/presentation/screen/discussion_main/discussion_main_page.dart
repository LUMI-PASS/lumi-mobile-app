import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:founders_academy/routing/app_router.gr.dart';

@RoutePage()
class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({super.key});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.greyG900,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            surfaceTintColor: ChessColors.greyG800,
            backgroundColor: ChessColors.greyG900,
            expandedHeight: 48,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              centerTitle: false,
              title: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: ChessColors.primaryDefault,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Muhokamalar",
                    style: context.textTheme.title3Bold.copyWith(
                      color: ChessColors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _CreatePostWidget(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList.separated(
              itemCount: _getMockDiscussions().length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final discussion = _getMockDiscussions()[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _fadeAnimation,
                      curve: Interval(
                        index * 0.1,
                        1.0,
                        curve: Curves.easeOutBack,
                      ),
                    )),
                    child: _DiscussionCard(discussion: discussion),
                  ),
                );
              },
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  List<DiscussionModel> _getMockDiscussions() {
    return [
      DiscussionModel(
        id: "1",
        title: "Muhokamalar",
        content:
            "Founders School dasturi bilan bog'liq barcha masalalar uchun Muhokama maydoniga xush kelibsiz!\n\nBu yerda siz quyidagi imkoniyatlarga ega bo'lasiz:\n\n• Startup tushunchalari, vositalari va strategiyalari haqida savollar berish va fikr almashish\n\n• Haftalik kurs ...",
        author: "Founders School",
        authorAvatar: "FS",
        timeAgo: "Pinned",
        isExpanded: false,
        isPinned: true,
        likesCount: 45,
        commentsCount: 12,
        sharesCount: 8,
      ),
      DiscussionModel(
        id: "2",
        title: "Boshqalardan farqi",
        content:
            "Startup dunyosida muvaffaqiyat qozonish uchun nimalar kerak? O'z tajribangiz bilan ulashing.",
        author: "Aziz Karimov",
        authorAvatar: "AK",
        timeAgo: "2 soat oldin",
        isExpanded: false,
        isPinned: false,
        likesCount: 23,
        commentsCount: 7,
        sharesCount: 3,
      ),
      DiscussionModel(
        id: "3",
        title: "Investor topish strategiyalari",
        content:
            "Qanday qilib to'g'ri investorni topish mumkin? Pitch deck tayyorlashda qanday narsalarga e'tibor berish kerak?",
        author: "Nilufar Abdullayeva",
        authorAvatar: "NA",
        timeAgo: "5 soat oldin",
        isExpanded: false,
        isPinned: false,
        likesCount: 34,
        commentsCount: 15,
        sharesCount: 6,
      ),
      DiscussionModel(
        id: "4",
        title: "Team building tajribasi",
        content:
            "Startup jamoasini qurish va rivojlantirishda qanday usullar samarali? Sifatli kadlrlar qanday topiladi?",
        author: "Bobur Umarov",
        authorAvatar: "BU",
        timeAgo: "1 kun oldin",
        isExpanded: false,
        isPinned: false,
        likesCount: 19,
        commentsCount: 9,
        sharesCount: 2,
      ),
    ];
  }
}

class _CreatePostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(const AddPostRoute()),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ChessColors.greyG800.withOpacity(0.6),
          borderRadius: ChessRadius.radiusMd,
          border: Border.all(
            color: ChessColors.primaryDefault.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: ChessColors.primaryDefault.withOpacity(0.3),
              child: Text(
                "XA",
                style: TextStyle(
                  color: ChessColors.primaryDefault,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: ChessColors.greyG700.withOpacity(0.5),
                  borderRadius: ChessRadius.radiusSm,
                  border: Border.all(
                    color: ChessColors.greyG600,
                    width: 1,
                  ),
                ),
                child: Text(
                  "Muhokama boshlash...",
                  style: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.greyG400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ChessColors.primaryDefault.withOpacity(0.2),
                borderRadius: ChessRadius.radiusSm,
              ),
              child: Icon(
                Icons.add,
                color: ChessColors.primaryDefault,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscussionCard extends StatefulWidget {
  final DiscussionModel discussion;

  const _DiscussionCard({required this.discussion});

  @override
  State<_DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<_DiscussionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) => _hoverController.reverse(),
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
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
              borderRadius: ChessRadius.radiusMd,
              border: Border.all(
                color: widget.discussion.isPinned
                    ? ChessColors.primaryDefault.withOpacity(0.4)
                    : ChessColors.primaryDefault.withOpacity(0.2),
                width: widget.discussion.isPinned ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ChessColors.greyG900.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                if (widget.discussion.isPinned)
                  BoxShadow(
                    color: ChessColors.primaryDefault.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: widget.discussion.isPinned
                            ? ChessColors.primaryDefault.withOpacity(0.3)
                            : ChessColors.greyG600,
                        child: Text(
                          widget.discussion.authorAvatar,
                          style: TextStyle(
                            color: widget.discussion.isPinned
                                ? ChessColors.primaryDefault
                                : ChessColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.discussion.author,
                                  style: context.textTheme.bodyMedium.copyWith(
                                    color: ChessColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                if (widget.discussion.isPinned) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ChessColors.primaryDefault,
                                      borderRadius: ChessRadius.radiusSm,
                                    ),
                                    child: Text(
                                      "PINNED",
                                      style: TextStyle(
                                        color: ChessColors.white,
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              widget.discussion.timeAgo,
                              style: context.textTheme.bodyMedium.copyWith(
                                color: ChessColors.greyG400,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            color: ChessColors.greyG400,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.more_vert,
                            color: ChessColors.greyG400,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  if (widget.discussion.title.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.discussion.title,
                          style: context.textTheme.title1Regular.copyWith(
                            color: ChessColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                  // Content
                  Text(
                    _isExpanded || widget.discussion.content.length <= 120
                        ? widget.discussion.content
                        : "${widget.discussion.content.substring(0, 120)}...",
                    style: context.textTheme.bodyMedium.copyWith(
                      color: ChessColors.greyG200,
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),

                  // See more button
                  if (widget.discussion.content.length > 120)
                    Column(
                      children: [
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Text(
                            _isExpanded ? "Ko'proq ko'rish" : "Kamroq ko'rish",
                            style: TextStyle(
                              color: ChessColors.primaryDefault,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Interaction buttons
                  Row(
                    children: [
                      _InteractionButton(
                        icon: Icons.thumb_up_outlined,
                        count: widget.discussion.likesCount.toString(),
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _InteractionButton(
                        icon: Icons.chat_bubble_outline,
                        count: widget.discussion.commentsCount.toString(),
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _InteractionButton(
                        icon: Icons.share_outlined,
                        count: widget.discussion.sharesCount.toString(),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String count;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ChessColors.greyG700.withOpacity(0.5),
          borderRadius: ChessRadius.radiusSm,
          border: Border.all(
            color: ChessColors.greyG600,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: ChessColors.greyG300,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                color: ChessColors.greyG300,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscussionModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorAvatar;
  final String timeAgo;
  final bool isExpanded;
  final bool isPinned;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;

  DiscussionModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorAvatar,
    required this.timeAgo,
    required this.isExpanded,
    required this.isPinned,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
  });
}
