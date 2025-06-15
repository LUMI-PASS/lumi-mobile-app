import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/home/data/model/book/book_data.dart';
import 'package:founders_academy/feature/home/presentation/widget/book_widget.dart';
import 'package:founders_academy/feature/home/presentation/widget/group/home_items_group.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:flutter/material.dart';

class BookGroup extends StatelessWidget {
  final List<BookData> bookList;

  const BookGroup({
    required this.bookList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Kitoblar',
      onViewAllTap: () => context.router.push(const BookListRoute()),
      body: SizedBox(
        height: 218,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: bookList.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => EnhancedBookWidget(
            width: 108,
            book: bookList[index],
          ),
        ),
      ),
    );
  }
}
