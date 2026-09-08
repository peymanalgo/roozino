import 'package:shamsi_date/shamsi_date.dart';

String toPersianDigits(String value) {
  const englishDigits = '0123456789';
  const persianDigits = '۰۱۲۳۴۵۶۷۸۹';

  var result = value;

  for (var i = 0; i < englishDigits.length; i++) {
    result = result.replaceAll(englishDigits[i], persianDigits[i]);
  }

  return result;
}

String formatPersianDate(DateTime? date) {
  if (date == null) {
    return 'بدون تاریخ';
  }

  final jalali = Jalali.fromDateTime(date);

  const monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  final day = toPersianDigits(jalali.day.toString());

  final month = monthNames[jalali.month - 1];

  final year = toPersianDigits(jalali.year.toString());

  return '$day $month $year';
}
