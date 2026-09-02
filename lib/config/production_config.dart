/// Production Configuration for ぬりパズ動物園
///
/// This file centralizes all production environment settings:
/// - Firebase project IDs and API keys
/// - RevenueCat production API key
/// - Google Mobile Ads configuration
/// - Feature flags and limits
///
/// IMPORTANT: Never commit actual API keys. Use environment variables instead.

class FirebaseConfigProd {
  /// Firebase Project ID (Production)
  /// Can be found in: Firebase Console > Project Settings
  static const String projectId = 'nuripazu-prod';

  /// Firebase Web API Key
  /// From: Firebase Console > Project Settings > Web API Key
  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY_PROD',
    defaultValue: '', // Empty in development
  );

  /// Firebase App ID (iOS)
  /// From: GoogleService-Info.plist > GOOGLE_APP_ID
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID_PROD',
    defaultValue: '',
  );

  /// Firebase Messaging Sender ID
  /// From: GoogleService-Info.plist > GCM_SENDER_ID
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID_PROD',
    defaultValue: '',
  );

  /// Firebase Emulator Host (for local testing)
  /// Leave empty for production
  static const String emulatorHost = '';
  static const int emulatorPort = 5001;
}

class RevenueCatConfigProd {
  /// RevenueCat API Key (Public)
  /// From: RevenueCat Dashboard > Project Settings > API Keys
  /// Format: appl_xxxxxxxxxxxxxxxxxxxxx
  static const String apiKey = String.fromEnvironment(
    'REVENUE_CAT_API_KEY_PROD',
    defaultValue: '',
  );

  /// RevenueCat Secret Key (Server-side only)
  /// From: RevenueCat Dashboard > Project Settings > API Keys
  /// Use in Cloud Functions via GitHub Secrets
  /// NOT used in frontend
  static const String secretKey = String.fromEnvironment(
    'REVENUE_CAT_SECRET_KEY_PROD',
    defaultValue: '',
  );

  /// RevenueCat Offering ID
  /// Default offering for all users
  static const String defaultOfferingId = 'default';

  /// RevenueCat Offering ID for Trial
  static const String trialOfferingId = 'trial';

  /// RevenueCat Offering ID for Launch Promo
  static const String launchPromoOfferingId = 'launch_promo';
}

class GoogleAdsConfigProd {
  /// Google Mobile Ads App ID
  /// From: Google AdMob Console > Apps & settings > App ID
  /// Format: ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
  static const String appId = String.fromEnvironment(
    'ADMOB_APP_ID_PROD',
    defaultValue: '',
  );

  /// AdMob Banner Ad Unit ID
  /// From: Google AdMob Console > Ad Units > Banner
  static const String bannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_ID_PROD',
    defaultValue: '',
  );

  /// AdMob Rewarded Ad Unit ID
  /// From: Google AdMob Console > Ad Units > Rewarded
  static const String rewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_ID_PROD',
    defaultValue: '',
  );

  /// AdMob Interstitial Ad Unit ID
  /// From: Google AdMob Console > Ad Units > Interstitial
  static const String interstitialAdUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID_PROD',
    defaultValue: '',
  );

  /// Test Device IDs (for development)
  /// Empty in production
  static const List<String> testDeviceIds = [];

  /// Enable personalized ads
  static const bool enablePersonalizedAds = true;
}

class FeatureFlagsProd {
  /// Maximum number of free animals a user can collect
  /// After this, players must use the paywall to get more
  static const int maxFreeAnimals = 1;

  /// Number of days before affection level decreases by 1
  /// If user doesn't interact for 3 days, affection drops
  static const int affectionLevelDecayDays = 3;

  /// Duration of herd bonus celebration in milliseconds
  static const int herdBonusCelebrationDurationMs = 5000;

  /// Enable legacy version support (iOS 13, etc)
  static const bool enableLegacySupport = false;

  /// Minimum iOS version for this app
  static const String minimumIOSVersion = '14.0';

  /// Enable analytics data collection
  static const bool enableAnalytics = true;

  /// Enable crash reporting
  static const bool enableCrashlytics = true;

  /// Enable remote config
  static const bool enableRemoteConfig = true;
}

class AppInfoProd {
  /// App Display Name
  static const String appName = 'ぬりパズ動物園';

  /// App Bundle ID
  static const String bundleId = 'com.yourwish.nuripazu';

  /// App Version
  static const String version = '0.1.0';

  /// App Build Number
  static const String buildNumber = '1';

  /// App Locale
  static const String defaultLocale = 'ja_JP';

  /// Support Email
  static const String supportEmail = 'support@yourwish.dev';

  /// Privacy Policy URL
  static const String privacyPolicyUrl =
    'https://yourwish.dev/privacy/ja';

  /// Terms of Service URL
  static const String termsOfServiceUrl =
    'https://yourwish.dev/terms/ja';
}

class APIEndpointsProd {
  /// Firebase Cloud Functions Base URL
  /// Example: https://us-central1-nuripazu-prod.cloudfunctions.net
  static const String cloudFunctionsBase =
    'https://us-central1-nuripazu-prod.cloudfunctions.net';

  /// Function: Increase affection level
  static String get increaseAffectionUrl =>
    '$cloudFunctionsBase/increaseAffection';

  /// Function: Decrease affection level
  static String get decreaseAffectionUrl =>
    '$cloudFunctionsBase/decreaseAffection';

  /// Function: Unlock herd bonus
  static String get unlockHerdBonusUrl =>
    '$cloudFunctionsBase/unlockHerdBonus';

  /// Function: Log analytics event
  static String get logAnalyticsUrl =>
    '$cloudFunctionsBase/logAnalyticsEvent';
}

class SecurityConfigProd {
  /// API Request Timeout (seconds)
  static const Duration requestTimeout = Duration(seconds: 10);

  /// API Retry Attempts
  static const int maxRetries = 3;

  /// Enable SSL Certificate Pinning
  static const bool enableCertificatePinning = true;

  /// Minimum TLS Version
  /// 1.2 or higher
  static const String minimumTLSVersion = '1.2';

  /// Enable HTTPS only
  static const bool enforceHttps = true;

  /// Session timeout (minutes)
  static const int sessionTimeoutMinutes = 60;

  /// Data encryption at rest
  static const bool encryptDataAtRest = true;

  /// Enable two-factor authentication (future)
  static const bool enable2FA = false;
}

/// Unified configuration class for production
class ProductionConfig {
  static const firebase = FirebaseConfigProd();
  static const revenueCat = RevenueCatConfigProd();
  static const googleAds = GoogleAdsConfigProd();
  static const features = FeatureFlagsProd();
  static const appInfo = AppInfoProd();
  static const endpoints = APIEndpointsProd();
  static const security = SecurityConfigProd();

  /// Validate that all required production keys are set
  static void validateConfiguration() {
    final missingKeys = <String>[];

    if (firebase.webApiKey.isEmpty) {
      missingKeys.add('FIREBASE_WEB_API_KEY_PROD');
    }
    if (firebase.projectId.isEmpty) {
      missingKeys.add('FIREBASE_PROJECT_ID_PROD');
    }
    if (revenueCat.apiKey.isEmpty) {
      missingKeys.add('REVENUE_CAT_API_KEY_PROD');
    }
    if (googleAds.appId.isEmpty) {
      missingKeys.add('ADMOB_APP_ID_PROD');
    }

    if (missingKeys.isNotEmpty) {
      throw Exception(
        'Missing production configuration keys: ${missingKeys.join(", ")}\n'
        'Please set these environment variables before building for production.'
      );
    }
  }
}
