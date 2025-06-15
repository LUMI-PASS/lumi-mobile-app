part of 'book_list_cubit.dart';

sealed class BookListState {
  const BookListState();
}

class BookListLoadingState extends BookListState {
  const BookListLoadingState();
}

class BookListLoadedState extends BookListState {
  final List<BookData> bookList;
  final int page;
  final bool isNextPageLoading;
  final bool isNextPageAvailable;

  const BookListLoadedState({
    required this.bookList,
    required this.page,
    this.isNextPageLoading = false,
    this.isNextPageAvailable = true,
  });

  BookListLoadedState copyWith({
    List<BookData>? bookList,
    int? page,
    bool? isNextPageLoading,
    bool? isNextPageAvailable,
  }) {
    return BookListLoadedState(
      bookList: bookList ?? this.bookList,
      page: page ?? this.page,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
    );
  }
}

class BookListErrorState extends BookListState {
  const BookListErrorState();
}
