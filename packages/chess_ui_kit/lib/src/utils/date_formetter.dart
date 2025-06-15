import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ChessIntl {
  static Future<void> initialize() => initializeDateFormatting("uz_UZ");
}

extension DateExtension on String {
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(DateTime.parse(this));

    if (difference.inDays == 0) {
      return 'Bugun';
    } else if (difference.inDays == 1) {
      return 'Kecha';
    } else if (difference.inDays < 3) {
      return '${difference.inDays} kun avval';
    } else {
      return DateFormat.yMMMMd("uz_UZ").format(DateTime.parse(this));
    }
  }
}
