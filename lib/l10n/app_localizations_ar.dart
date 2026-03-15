// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get authorName => 'سيمبري أشرف';

  @override
  String get appName => 'فخاخ الشطرنج';

  @override
  String get chessTraps => 'فخاخ الشطرنج';

  @override
  String get home => 'الرئيسية';

  @override
  String get traps => 'الفخاخ';

  @override
  String get favorite => 'المفضلة';

  @override
  String get training => 'التدريب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get trapOfTheDay => 'فخ اليوم';

  @override
  String get recentTraps => 'الفخاخ الأخيرة';

  @override
  String get exampleTrap => 'هجوم كبد المقلية';

  @override
  String get lastTimeChecked => 'آخر وقت للفحص';

  @override
  String get explore => 'استكشاف';

  @override
  String get viewAllTraps => 'عرض جميع الفخاخ';

  @override
  String get errorLoadingTraps => 'خطأ في تحميل الفخاخ';

  @override
  String get noTrapsFound => 'لم يتم العثور على فخاخ';

  @override
  String get theme => 'المظهر';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get openSourceLicense => 'رخصة المصدر المفتوح';

  @override
  String get usedPackages => 'الحزم المستخدمة';

  @override
  String get developer => 'المطور';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String masteredTraps(Object count, Object percentage) {
    return '$count فخاخ متقنة ($percentage%)';
  }

  @override
  String get english => 'الإنجليزية';
}
