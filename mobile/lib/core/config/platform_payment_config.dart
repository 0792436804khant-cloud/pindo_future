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

  // --- Platform Commission Rates (Admin Only) ---
  /// Platform commission rate on live sessions (15%)
  static const double liveSessionsCommissionRate = 0.15;

  /// Platform commission rate on digital library access (10%)
  static const double libraryCommissionRate = 0.10;

  /// Base price for live sessions in DZD
  static const int baseLiveSessionPriceDzd = 2500;

  /// Calculates the platform cut and net teacher payout.
  /// - Live sessions: 15% platform cut (85% teacher payout)
  /// - Digital Library add-on: 10% platform cut (90% teacher payout)
  static CommissionBreakdown calculateCommission({
    required int totalPriceDzd,
    required String packageName,
  }) {
    final isLibraryIncluded = packageName.contains('مكتبة') ||
        packageName.toLowerCase().contains('library') ||
        totalPriceDzd > baseLiveSessionPriceDzd;

    int livePart = baseLiveSessionPriceDzd;
    int libraryPart = 0;

    if (isLibraryIncluded && totalPriceDzd > baseLiveSessionPriceDzd) {
      livePart = baseLiveSessionPriceDzd;
      libraryPart = totalPriceDzd - baseLiveSessionPriceDzd;
    } else {
      livePart = totalPriceDzd;
    }

    final liveCommission = (livePart * liveSessionsCommissionRate).round();
    final libraryCommission = (libraryPart * libraryCommissionRate).round();
    final totalCommission = liveCommission + libraryCommission;
    final teacherPayout = totalPriceDzd - totalCommission;

    return CommissionBreakdown(
      grossPriceDzd: totalPriceDzd,
      platformCommissionDzd: totalCommission,
      teacherPayoutDzd: teacherPayout,
      isLibraryIncluded: isLibraryIncluded,
    );
  }
}

class CommissionBreakdown {
  final int grossPriceDzd;
  final int platformCommissionDzd;
  final int teacherPayoutDzd;
  final bool isLibraryIncluded;

  const CommissionBreakdown({
    required this.grossPriceDzd,
    required this.platformCommissionDzd,
    required this.teacherPayoutDzd,
    required this.isLibraryIncluded,
  });
}
