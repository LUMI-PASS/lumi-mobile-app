import 'package:chess_ui_kit/src/ui_components/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class AfishaShimmerContent extends StatelessWidget {
  const AfishaShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        children: const [
          AfishaShimmer(),
          AfishaShimmer(),
        ],
      ),
    );
  }
}

class GrandmasterGroupShimmerContent extends StatelessWidget {
  const GrandmasterGroupShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemCount: 3,
          itemBuilder: (context, index) => const GrandmasterGroupShimmer()),
    );
  }
}

class ReviewMatchesGroupShimmerContent extends StatelessWidget {
  const ReviewMatchesGroupShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 144,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shrinkWrap: true,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: 3,
        itemBuilder: (context, index) => const ReviewMatchesGroupShimmer(),
      ),
    );
  }
}

class NewsGroupShimmerContent extends StatelessWidget {
  const NewsGroupShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
      shrinkWrap: true,
      children: const [NewsGroupShimmer(), NewsGroupShimmer()],
    );
  }
}

class BookGroupShimmerContent extends StatelessWidget {
  const BookGroupShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shrinkWrap: true,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: 3,
        itemBuilder: (context, index) => const BookGroupShimmer(),
      ),
    );
  }
}
