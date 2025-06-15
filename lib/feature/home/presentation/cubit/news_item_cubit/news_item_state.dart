import 'package:founders_academy/feature/home/data/model/news/news_data.dart';

sealed class NewsItemState {
  const NewsItemState();
}

class NewsItemLoadingState extends NewsItemState {
  const NewsItemLoadingState();
}

class NewsItemLoadedState extends NewsItemState {
  final NewsData newsData;
  const NewsItemLoadedState(this.newsData);
}

class NewsItemErrorState extends NewsItemState {
  const NewsItemErrorState();
}
