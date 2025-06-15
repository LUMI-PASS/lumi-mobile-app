import 'package:auto_route/annotations.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.greyG900,
      appBar: AppBar(
        backgroundColor: ChessColors.greyG900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: ChessColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Yangi muhokama",
          style: context.textTheme.title3Bold.copyWith(
            color: ChessColors.white,
            fontSize: 18,
          ),
        ),
        actions: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _canPost() ? _publishPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canPost()
                    ? ChessColors.primaryDefault
                    : ChessColors.greyG600,
                foregroundColor: ChessColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: ChessRadius.radiusMd,
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ChessColors.white,
                  ),
                ),
              )
                  : Text(
                "Joylash",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ChessColors.primaryDefault.withOpacity(0.3),
                    child: Text(
                      "XA",
                      style: TextStyle(
                        color: ChessColors.primaryDefault,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Xasan Aliyev",
                        style: context.textTheme.bodyMedium.copyWith(
                          color: ChessColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Hammaga ko'rinadi",
                        style: context.textTheme.bodyMedium.copyWith(
                          color: ChessColors.greyG400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title Input
              Container(
                decoration: BoxDecoration(
                  color: ChessColors.greyG800.withOpacity(0.6),
                  borderRadius: ChessRadius.radiusMd,
                  border: Border.all(
                    color: _titleFocus.hasFocus
                        ? ChessColors.primaryDefault.withOpacity(0.5)
                        : ChessColors.greyG600,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  style: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Muhokama mavzusi...",
                    hintStyle: TextStyle(
                      color: ChessColors.greyG400,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const SizedBox(height: 16),

              // Content Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ChessColors.greyG800.withOpacity(0.6),
                    borderRadius: ChessRadius.radiusMd,
                    border: Border.all(
                      color: _contentFocus.hasFocus
                          ? ChessColors.primaryDefault.withOpacity(0.5)
                          : ChessColors.greyG600,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _contentController,
                    focusNode: _contentFocus,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: context.textTheme.bodyMedium.copyWith(
                      color: ChessColors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Fikrlaringizni baham ko'ring...\n\nBu yerda siz:\n• Savollar berishingiz\n• Tajribangizni ulashishingiz\n• Maslahat berishingiz mumkin",
                      hintStyle: TextStyle(
                        color: ChessColors.greyG400,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  bool _canPost() {
    return _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty &&
        !_isPosting;
  }

  Future<void> _publishPost() async {
    setState(() {
      _isPosting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isPosting = false;
    });

    // Navigate back with success
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Muhokama muvaffaqiyatli joylandi!",
          style: TextStyle(color: ChessColors.white),
        ),
        backgroundColor: ChessColors.primaryDefault,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ChessRadius.radiusMd,
        ),
      ),
    );
  }
}
