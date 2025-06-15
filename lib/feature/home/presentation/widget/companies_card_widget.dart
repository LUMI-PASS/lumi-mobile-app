import 'package:flutter/material.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';

class CompaniesCard extends StatefulWidget {
  final int index;
  final String? companyName;
  final String? companyLogo;
  final String? industry;
  final String? description;
  final int? employeeCount;
  final double? rating;
  final VoidCallback? onTap;

  const CompaniesCard({
    super.key,
    required this.index,
    this.companyName,
    this.companyLogo,
    this.industry,
    this.description,
    this.employeeCount,
    this.rating,
    this.onTap,
  });

  @override
  State<CompaniesCard> createState() => _CompaniesCardState();
}

class _CompaniesCardState extends State<CompaniesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockCompanies = [
    {
      'name': 'TechCorp',
      'industry': 'Technology',
      'description': 'Leading AI solutions provider',
      'employees': 1250,
      'rating': 4.8,
      'color': ChessColors.primaryDefault,
      'icon': Icons.computer,
    },
    {
      'name': 'FinanceFlow',
      'industry': 'Finance',
      'description': 'Digital banking solutions',
      'employees': 890,
      'rating': 4.7,
      'color': ChessColors.successDefault,
      'icon': Icons.account_balance,
    },
    {
      'name': 'HealthTech',
      'industry': 'Healthcare',
      'description': 'Medical technology innovations',
      'employees': 650,
      'rating': 4.9,
      'color': ChessColors.warningBgStrong,
      'icon': Icons.medical_services,
    },
    {
      'name': 'EduSpace',
      'industry': 'Education',
      'description': 'Online learning platform',
      'employees': 420,
      'rating': 4.6,
      'color': ChessColors.warningDefault,
      'icon': Icons.school,
    },
    {
      'name': 'GreenEnergy',
      'industry': 'Energy',
      'description': 'Sustainable energy solutions',
      'employees': 780,
      'rating': 4.8,
      'color': Color(0xFF10B981),
      'icon': Icons.eco,
    },
  ];

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 16.0,
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
    final company = _mockCompanies[widget.index % _mockCompanies.length];

    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) => _hoverController.reverse(),
      onTapCancel: () => _hoverController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
              child: Material(
                elevation: _elevationAnimation.value,
                borderRadius: ChessRadius.radiusLg,
                shadowColor: company['color'].withOpacity(0.3),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: ChessRadius.radiusLg,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ChessColors.greyG800,
                        ChessColors.greyG700,
                      ],
                    ),
                    border: Border.all(
                      color: company['color'].withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: company['color'].withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: company['color'].withOpacity(0.05),
                          ),
                        ),
                      ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with logo and rating
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: company['color'].withOpacity(0.2),
                                    borderRadius: ChessRadius.radiusMd,
                                    border: Border.all(
                                      color: company['color'].withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    company['icon'],
                                    color: company['color'],
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ChessColors.greyG600.withOpacity(0.8),
                                    borderRadius: ChessRadius.radiusSm,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: ChessColors.warningBgStrong,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        company['rating'].toString(),
                                        style: context.textTheme.caption2Regular.copyWith(
                                          color: ChessColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Text(
                              widget.companyName ?? company['name'],
                              style: context.textTheme.caption1Regular.copyWith(
                                color: ChessColors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: company['color'].withOpacity(0.2),
                                borderRadius: ChessRadius.radiusSm,
                                border: Border.all(
                                  color: company['color'].withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.industry ?? company['industry'],
                                style: context.textTheme.caption2Regular.copyWith(
                                  color: company['color'],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Description
                            Text(
                              widget.description ?? company['description'],
                              style: context.textTheme.caption2Regular.copyWith(
                                color: ChessColors.greyG300,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                           const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  color: ChessColors.greyG400,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.employeeCount ?? company['employees']}+ xodimlar',
                                  style: context.textTheme.caption2Regular.copyWith(
                                    color: ChessColors.greyG400,
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
      ),
    );
  }
}