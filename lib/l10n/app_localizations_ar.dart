// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Trapster';

  @override
  String get chessTraps => 'Trapster';

  @override
  String get home => 'الرئيسية';

  @override
  String get traps => 'الفخاخ';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get trapOfTheDay => 'فخ اليوم';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get openSourceLicense => 'رخصة المصدر المفتوح';

  @override
  String get usedPackages => 'الحزم مفتوحة المصدر';

  @override
  String get randomTrap => 'فخ عشوائي';

  @override
  String get yourFavoriteChessTraps => 'فخاخك المفضلة';

  @override
  String get search => 'بحث';

  @override
  String get matchingTraps => 'الفخاخ المطابقة';

  @override
  String get resetBoard => 'إعادة ضبط الرقعة';

  @override
  String get noTrapsFoundForSequence => 'لم يتم العثور على فخاخ لهذا التسلسل';

  @override
  String get appearance => 'المظهر';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get about => 'حول';

  @override
  String get yourFavorites => 'مفضلاتك';

  @override
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فخاخ محفوظة',
      one: 'فخ واحد محفوظ',
      zero: 'لا توجد فخاخ محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get profileTitle => 'لاعب شطرنج';

  @override
  String get copyright => 'Trapster © 2026';

  @override
  String get clearFavoritesTitle => 'مسح المفضلة';

  @override
  String get clearFavoritesHint => 'لا يمكن التراجع عن هذا';

  @override
  String get clearFavoritesConfirm =>
      'هل أنت متأكد أنك تريد إزالة جميع الفخاخ المحفوظة من المفضلة؟';

  @override
  String get clearFavoritesCancel => 'إلغاء';

  @override
  String get clearFavoritesAction => 'مسح الكل';

  @override
  String get searchByName => 'بحث بالاسم';

  @override
  String get yourPersonalCollectionOfTacticalBrilliance =>
      'الفخاخ التي حفظتها.';

  @override
  String get noFavoriteYet => 'لا توجد مفضلات بعد';

  @override
  String get taptheHeartIconAction => 'اضغط على القلب في أي فخ لحفظه هنا.';

  @override
  String get exploreMore => 'استكشف المزيد';

  @override
  String get theory => 'نظرية';

  @override
  String get undo => 'تراجع';

  @override
  String get flip => 'اقلب';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get browseByOpening => 'تصفح حسب الافتتاحية';

  @override
  String get allTraps => 'جميع الفخاخ';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get featuredTrap => 'فخ مميز';

  @override
  String get startTraining => 'ابدأ التدريب';

  @override
  String get unlockedExtraMoves => 'تم فتح 5 نقلات إضافية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get watchAd => 'مشاهدة إعلان';

  @override
  String get trapCompleted => 'اكتمل الفخ. أحسنت اللعب!';

  @override
  String get relatedTraps => 'فخاخ ذات صلة';

  @override
  String get incorrectMove => 'ليست هذه النقلة. حاول مرة أخرى!';

  @override
  String get incorrectMoveWithHint => 'ليس تمامًا. إليك تلميحًا.';

  @override
  String get goBack => 'العودة';

  @override
  String get boardTheme => 'مظهر الرقعة';

  @override
  String get learnNow => 'تعلم الآن';

  @override
  String get avoidTrap => 'تجنّب الفخ';

  @override
  String get avoidModeActive => 'وضع التجنب: ابحث عن النقلة الآمنة.';

  @override
  String get blunderPrevented => 'أحسنت! لقد تجنبت الفخ.';

  @override
  String get findBetterMove => 'ابحث عن نقلة أكثر أمانًا.';

  @override
  String get play => 'العب';

  @override
  String get you_won => 'لقد فزت!';

  @override
  String get congratulations => 'تهانينا!';

  @override
  String get stockfish_won => 'فاز ستوكفيش';

  @override
  String get better_luck_next_time => 'حظًا أوفر في المرة القادمة.';

  @override
  String get you_resigned => 'لقد استسلمت';

  @override
  String get draw => 'تعادل';

  @override
  String get well_played => 'أحسنت اللعب!';

  @override
  String get close => 'إغلاق';

  @override
  String get play_again => 'العب مرة أخرى';

  @override
  String get opponent_strength => 'قوة الخصم';

  @override
  String get wins => 'انتصارات';

  @override
  String get draws => 'تعادلات';

  @override
  String get losses => 'هزائم';

  @override
  String get play_as => 'العب بـ';

  @override
  String get white => 'الأبيض';

  @override
  String get random => 'عشوائي';

  @override
  String get black => 'الأسود';

  @override
  String get start_game => 'ابدأ المباراة';

  @override
  String get thinking => 'يفكر…';

  @override
  String get your_turn => 'دورك';

  @override
  String get back_to_setup => 'مباراة جديدة';

  @override
  String get resign => 'استسلام';

  @override
  String get hint => 'تلميح';

  @override
  String get your_games => 'مبارياتك';

  @override
  String get moves => 'نقلات';

  @override
  String get first_move => 'أول نقلة';

  @override
  String get previous_move => 'النقلة السابقة';

  @override
  String get next_move => 'النقلة التالية';

  @override
  String get last_move => 'آخر نقلة';

  @override
  String get piecePawn => 'البيدق';

  @override
  String get pieceKnight => 'الحصان';

  @override
  String get pieceBishop => 'الفيل';

  @override
  String get pieceRook => 'الرخ';

  @override
  String get pieceQueen => 'الوزير';

  @override
  String get pieceKing => 'الملك';

  @override
  String get andSeparator => ' و ';

  @override
  String explainCheckmate(String piece) {
    return 'يعطي $piece كش مات!';
  }

  @override
  String explainSacrifice(String piece) {
    return 'يضحي بـ$piece لفتح الهجوم.';
  }

  @override
  String explainCapture(String piece, String captured) {
    return 'يأسر $piece $captured.';
  }

  @override
  String explainFork(String piece, String targets) {
    return 'يهاجم $piece $targets في شوكة.';
  }

  @override
  String explainCheck(String piece) {
    return 'يعطي $piece كش ويفرض الرد.';
  }

  @override
  String get explainCastleKingside => 'تبييت قصير يؤمّن الملك.';

  @override
  String get explainCastleQueenside => 'تبييت طويل.';

  @override
  String explainPromotion(String piece) {
    return 'يترقى إلى $piece.';
  }

  @override
  String explainDevelop(String piece) {
    return 'يطوّر $piece.';
  }

  @override
  String get you => 'أنت';

  @override
  String get daily_limit_reached => 'تم الوصول إلى الحد اليومي';

  @override
  String get limit_reached_body =>
      'لقد شاهدت فخاخك العشرة المجانية لهذا اليوم. شاهد إعلانًا قصيرًا لفتح جميع الفخاخ حتى الغد.';

  @override
  String get no_traps_in_group => 'لا توجد فخاخ لهذا الافتتاح حتى الآن.';

  @override
  String get play_mode => 'العب';

  @override
  String get move_limit_reached =>
      'بلغت حد النقلات والإعلان غير جاهز. انتظر قليلًا أو أعد ضبط الرقعة.';

  @override
  String get search_limit_body =>
      'استخدمت نقلاتك المجانية لهذا البحث. شاهد إعلانًا قصيرًا لفتح 5 نقلات إضافية.';

  @override
  String get notifications => 'إشعارات';

  @override
  String get daily_trap_reminder => 'تذكير يومي';

  @override
  String get daily_trap_reminder_subtitle => 'تنبيه لمشاهدة فخ اليوم';

  @override
  String get reminder_time => 'وقت التذكير';

  @override
  String get notification_trap_ready_title => 'فخ اليوم جاهز';

  @override
  String get notification_trap_ready_body => 'تعلّمه قبل مباراتك القادمة ♟️';

  @override
  String get trapNotFound => 'لم يتم العثور على الفخ';

  @override
  String get practiceModeActive => 'وضع التدريب: العب النقلات الصحيحة.';

  @override
  String canYouSurvive(String trapName, String link) {
    return 'هل تستطيع تجنب هذا الفخ؟ جرّب $trapName.\n$link';
  }

  @override
  String get exitPractice => 'الخروج من التدريب';

  @override
  String get practiceMode => 'وضع التدريب';

  @override
  String get exitAvoidMode => 'الخروج من وضع التجنب';

  @override
  String get avoidTrapMode => 'تجنّب الفخ';

  @override
  String get stopAutoPlay => 'إيقاف';

  @override
  String get autoPlay => 'تشغيل تلقائي';

  @override
  String get flipBoard => 'اقلب الرقعة';

  @override
  String get markedAsLearned => 'تم التعلّم';

  @override
  String get markAsLearned => 'تحديد كمتعلَّم';

  @override
  String get shareTrap => 'مشاركة الفخ';

  @override
  String get settings => 'إعدادات';

  @override
  String get engineStarting => 'جارٍ تشغيل المحرك…';

  @override
  String get engineUnavailable => 'المحرك غير متوفر';

  @override
  String depthLabel(int depth) {
    return 'العمق: $depth';
  }

  @override
  String get analysisSettings => 'التحليل';

  @override
  String get engineBestMoves => 'أسهم المحرك';

  @override
  String eloLabel(int elo) {
    return 'إيلو: $elo';
  }

  @override
  String stockfishLabel(int elo) {
    return 'ستوكفيش ($elo)';
  }

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get trapsLearned => 'الفخاخ التي تعلّمتها';

  @override
  String learnedProgress(int learned, int total) {
    return '$learned من $total';
  }

  @override
  String get soundAndHaptics => 'الصوت والاهتزاز';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get hapticFeedback => 'الاهتزاز اللمسي';

  @override
  String get vsStockfish => 'ضد ستوكفيش';

  @override
  String get vsFriend => 'ضد صديق';

  @override
  String get passAndPlayHint => 'لاعبان وهاتف واحد. بالتناوب.';

  @override
  String get whiteWins => 'فاز الأبيض';

  @override
  String get blackWins => 'فاز الأسود';

  @override
  String get toMove => 'دور اللعب';

  @override
  String get opponentResigned => 'استسلم الخصم';

  @override
  String get gameHistoryTitle => 'سجل المباريات';

  @override
  String get allGames => 'الكل';

  @override
  String get noSavedGames => 'لا توجد مباريات محفوظة بعد';

  @override
  String get viewAllGames => 'عرض كل المباريات';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في Trapster';

  @override
  String get onboardingWelcomeBody => 'تعلّم الافتتاحيات وأوقع خصومك في الفخ.';

  @override
  String get onboardingPlayTitle => 'العب ضد ستوكفيش';

  @override
  String get onboardingPlayBody => 'جرّب فخاخك الجديدة ضد ستوكفيش.';

  @override
  String get onboardingStreakTitle => 'واصل سلسلتك';

  @override
  String get onboardingStreakBody =>
      'عد يوميًا لمواصلة سلسلة دخولك واحفظ فخاخك المفضلة.';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get trapForWhite => 'فخ للأبيض';

  @override
  String get trapForBlack => 'فخ للأسود';

  @override
  String get language => 'اللغة';

  @override
  String get thePawn => 'البيدق';

  @override
  String get theKnight => 'الحصان';

  @override
  String get theBishop => 'الفيل';

  @override
  String get theRook => 'الرخ';

  @override
  String get theQueen => 'الوزير';

  @override
  String get theKing => 'الملك';

  @override
  String explainPawnMove(String piece) {
    return 'يتقدم $piece.';
  }

  @override
  String explainQuietMove(String piece) {
    return 'يحرك $piece.';
  }

  @override
  String get whiteResigned => 'استسلم الأبيض';

  @override
  String get blackResigned => 'استسلم الأسود';

  @override
  String get boardThemeBrown => 'بني';

  @override
  String get boardThemeBlue => 'أزرق';

  @override
  String get boardThemeGreen => 'أخضر';

  @override
  String get boardThemeWood => 'خشب';

  @override
  String get boardThemeWood2 => 'خشب 2';

  @override
  String get boardThemeMetal => 'معدني';

  @override
  String get boardThemeMarble => 'رخام';

  @override
  String get boardThemeHorsey => 'Horsey';

  @override
  String get boardThemePurple => 'بنفسجي';
}
