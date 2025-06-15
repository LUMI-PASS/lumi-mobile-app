import 'package:lumi_pass/feature/home/data/model/book/book_data.dart';
import 'package:lumi_pass/feature/home/data/model/pagination/pagination_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'books_response.g.dart';

@JsonSerializable()
class BooksResponse {
  @JsonKey(name: 'data')
  final List<BookData>? books;

  @JsonKey(name: 'pagination')
  final PaginationData paginationData;

  const BooksResponse({
    required this.paginationData,
    this.books,
  });

  factory BooksResponse.fromJson(Map<String, dynamic> json) =>
      _$BooksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BooksResponseToJson(this);
}

@JsonSerializable()
class BookResponse {
  @JsonKey(name: 'data')
  final BookData? book;

  const BookResponse({this.book});

  factory BookResponse.fromJson(Map<String, dynamic> json) =>
      _$BookResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookResponseToJson(this);
}
