import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final int index;

  const CourseCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final courses = [
      {
        'title': 'Startup asoslari',
        'instructor': 'Aziz Abdukarimov',
        'students': '1,234',
        'rating': '4.8',
        'price': '299,000',
      },
      {
        'title': 'Biznes plan tuzish',
        'instructor': 'Nigora Saidova',
        'students': '856',
        'rating': '4.7',
        'price': '399,000',
      },
      {
        'title': 'Marketing strategiyalari',
        'instructor': 'Bobur Umarov',
        'students': '2,145',
        'rating': '4.9',
        'price': '449,000',
      },
    ];

    final course = courses[index % courses.length];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: ChessColors.greyG800.withOpacity(0.6),
        borderRadius: ChessRadius.radiusMd,
        border: Border.all(
          color: ChessColors.primaryDefault.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ChessColors.primaryDefault.withOpacity(0.3),
                  ChessColors.greyG700,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_filled,
                color: ChessColors.white,
                size: 32,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title']!,
                  style: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course['instructor']!,
                  style: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.greyG400,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 12,
                    ),
                    Text(
                      course['rating']!,
                      style: TextStyle(
                        color: ChessColors.greyG300,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "(${course['students']})",
                      style: TextStyle(
                        color: ChessColors.greyG400,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${course['price']} so'm",
                  style: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.primaryDefault,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
