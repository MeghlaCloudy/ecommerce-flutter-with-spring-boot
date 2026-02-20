
import 'package:shajgoj/core/constanst/app_constants.dart'; // যদি লাগে, না লাগলেও চলবে
 // এটা মিসিং ছিল!

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension NumExtension on num {
  String toPrice() {
    return "${AppConstants.currencySymbol}${toStringAsFixed(2)}";
  }
}
