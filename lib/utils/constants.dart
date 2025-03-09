class Constants {
  static const String appName = 'Performance Monitor';
  static const int maxDataPoints = 60;
  static const Duration updateInterval = Duration(milliseconds: 1000);

  // app settings
  static String appLink = "";
  static String moreAppsLink = "";
  static String privacyLink = "";

  // ads:
  static String admobAppOpen = "";
  static String admobBanner = "";
  static String admobInter = "";
  static String admobReward = "";
  static String admobNative = "";

  // ============ json Tags =============

  // data
  static String jsonAds = 'ads';

  static String jsonAdsAdmob = 'admob';
  static String jsonAdsAdmobBanner = 'banner';
  static String jsonAdsAdmobInter = 'inter';
  static String jsonAdsAdmobAppOpen = 'appOpen';
  static String jsonAdsAdmobNative = 'native';
  static String jsonAdsAdmobReward = 'reward';
}
