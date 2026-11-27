/// Central configuration for Algerian payment gateways, BaridiMob / CCP accounts,
/// and automated platform commission calculations.
class PlatformPaymentConfig {
  /// Official platform BaridiMob Relevé d'Identité Postale (RIP)
  static const String rip = '00799999004147536876';

  /// Standard formatted RIP for visual readability
  static const String formattedRip = '007 99999 0041475368 76';

  /// Postal CCP account number
  static const String ccpAccountNumber = '0041475368';

  /// CCP Key
  static const String ccpKey = '76';

  /// Official account holder name displayed to students in BaridiMob
  static const String accountHolderName = 'منصة بيندو فيوتشر للتعليم (Pindo Future)';

  /// Bank / Postal provider
  static const String bankProvider = 'بريد الجزائر (Algérie Poste)';

  // --- Platform Commission Rates (Admin & Teacher Split Analytics) ---
  /// Platform commission rate on live / in-person sessions (15%)
  static const double liveSessionsCommissionRate = 0.15;

  /// Platform commission rate on digital library access (10%)
  static const double libraryCommissionRate = 0.10;

  /// Fallback base price for live sessions in DZD
  static const int baseLiveSessionPriceDzd = 2500;

  /// Canonical package type constants matching backend `StudyCohort::PACKAGE_*`
  static const String packageLiveOnly = 'live_only';
  static const String packageLibraryOnly = 'library_only';
  static const String packageFullBundle = 'full_bundle';

  /// Calculates exact platform commission and net teacher payout for:
  /// - `live_only`: 15% platform cut (85% teacher payout)
  /// - `library_only`: 10% platform cut (90% teacher payout)
  /// - `full_bundle`: proportional 15% on live portion + 10% on library portion
  static CommissionBreakdown calculateCommission({
    required int totalPriceDzd,
    required String packageName,
    String? packageType,
    int? livePriceDzd,
    int? libraryPriceDzd,
  }) {
    final resolvedType = packageType ?? _inferPackageType(packageName, totalPriceDzd);

    int livePart = 0;
    int libraryPart = 0;

    if (resolvedType == packageLiveOnly) {
      livePart = totalPriceDzd;
      libraryPart = 0;
    } else if (resolvedType == packageLibraryOnly) {
      livePart = 0;
      libraryPart = totalPriceDzd;
    } else {
      // Integrated bundle: split proportionally using explicit livePriceDzd & libraryPriceDzd when given
      final liveRef = livePriceDzd ?? baseLiveSessionPriceDzd;
      final libRef = libraryPriceDzd ??
          (totalPriceDzd > liveRef ? totalPriceDzd - liveRef : (totalPriceDzd * 0.35).round());
      final refSum = liveRef + libRef;

      if (refSum > 0 && libRef > 0) {
        livePart = ((totalPriceDzd * liveRef) / refSum).round();
        libraryPart = totalPriceDzd - livePart;
      } else {
        livePart = totalPriceDzd;
        libraryPart = 0;
      }
    }

    final liveCommission = (livePart * liveSessionsCommissionRate).round();
    final libraryCommission = (libraryPart * libraryCommissionRate).round();
    final totalCommission = liveCommission + libraryCommission;
    final teacherPayout = totalPriceDzd - totalCommission;

    return CommissionBreakdown(
      grossPriceDzd: totalPriceDzd,
      liveGrossDzd: livePart,
      libraryGrossDzd: libraryPart,
      liveCommissionDzd: liveCommission,
      libraryCommissionDzd: libraryCommission,
      platformCommissionDzd: totalCommission,
      teacherPayoutDzd: teacherPayout,
      packageType: resolvedType,
      isLibraryIncluded: resolvedType != packageLiveOnly,
    );
  }

  static String _inferPackageType(String packageName, int totalPriceDzd) {
    final lower = packageName.toLowerCase();
    final hasLiveWord = packageName.contains('حصص') ||
        packageName.contains('حضور') ||
        lower.contains('live') ||
        packageName.contains('متكاملة') ||
        lower.contains('bundle');
    final hasLibWord = packageName.contains('مكتبة') ||
        packageName.contains('تسجيلات') ||
        lower.contains('library');

    if (hasLibWord && !hasLiveWord) {
      return packageLibraryOnly;
    }
    if (hasLibWord || packageName.contains('متكاملة') || totalPriceDzd > baseLiveSessionPriceDzd) {
      return packageFullBundle;
    }
    return packageLiveOnly;
  }
}

class CommissionBreakdown {
  final int grossPriceDzd;
  final int liveGrossDzd;
  final int libraryGrossDzd;
  final int liveCommissionDzd;
  final int libraryCommissionDzd;
  final int platformCommissionDzd;
  final int teacherPayoutDzd;
  final String packageType;
  final bool isLibraryIncluded;

  const CommissionBreakdown({
    required this.grossPriceDzd,
    this.liveGrossDzd = 0,
    this.libraryGrossDzd = 0,
    this.liveCommissionDzd = 0,
    this.libraryCommissionDzd = 0,
    required this.platformCommissionDzd,
    required this.teacherPayoutDzd,
    this.packageType = PlatformPaymentConfig.packageLiveOnly,
    required this.isLibraryIncluded,
  });
}
