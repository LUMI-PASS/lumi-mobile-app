part of 'book_cubit.dart';

sealed class BookState {
  const BookState();
}

class BookLoadingState extends BookState {
  const BookLoadingState();
}

class BookLoadedState extends BookState {
  final BookData book;
  const BookLoadedState(this.book);
}

class BookErrorState extends BookState {
  const BookErrorState();
}
