# Flutter IOS AdMob Implementation Guide

This README provides a step-by-step guide on how to implement Google AdMob ads in your ios Flutter application using the included example code.

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Project Structure](#project-structure)
4. [Ad Units Setup](#ad-units-setup)
5. [Implementation Details](#implementation-details)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

## Overview

This project demonstrates how to implement all major AdMob ad formats in a Flutter application:
- Banner ads
- Interstitial ads
- Rewarded ads
- App Open ads

The implementation uses a singleton pattern for the AdMob service, making it easy to access from anywhere in your app.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Google AdMob account
- Android Studio or VS Code

### Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_mobile_ads: ^5.2.0 # Or latest version
  http: ^1.1.0
```

### Installation

1. Clone this repository or copy the necessary files to your project
2. Run `flutter pub get` to install dependencies
3. Configure your iOS and Android projects as described below

## Project Structure

The key files for AdMob implementation are:

- `lib/networks/admob.dart` - Main AdMob implementation class
- `lib/utils/constants.dart` - Ad unit IDs storage
- `lib/screens/splash_screen.dart` - Initializes ads on app start
- `lib/screens/home_screen.dart` - Example of ad usage

## Ad Units Setup

### Set Up Ad Units in Constants

Create a `constants.dart` file similar to the one below:

```dart
class Constants {
  // AdMob
  static String admobBanner = "ca-app-pub-3940256099942544/2934735716";
  static String admobInter = "ca-app-pub-3940256099942544/4411468910";
  static String admobReward = "ca-app-pub-3940256099942544/1712485313";
  static String admobAppOpen = "ca-app-pub-3940256099942544/5575463023";
  
  // JSON configuration keys
  static const String jsonAds = "ads";
  static const String jsonAdsAdmob = "admob";
  static const String jsonAdsAdmobBanner = "banner";
  static const String jsonAdsAdmobInter = "inter";
  static const String jsonAdsAdmobReward = "reward";
  static const String jsonAdsAdmobAppOpen = "appOpen";
  
  // Replace with your app's actual link for promotions
  static const String appLink = "https://play.google.com/store/apps/details?id=your.app.id";
}
```

Note: The ad unit IDs provided above are Google's test IDs. Replace with your actual ad unit IDs in production.

### Platform Configuration

#### iOS (Info.plist)

Add the following to your `Info.plist` file:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~3347511713</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

Replace the GADApplicationIdentifier with your actual AdMob app ID.

#### Android (AndroidManifest.xml)

Add the following inside the `<application>` tag of your `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

Replace the value with your actual AdMob app ID.

## Implementation Details

### Initialize AdMob

The AdMob SDK is initialized in the `initialize()` method of the `AdmobAds` class:

```dart
Future<void> initialize() async {
  if (_isInitialized) return;

  try {
    final status = await MobileAds.instance.initialize();
    _isInitialized = true;
    debugPrint('==> Admob Initialization complete: ${status.adapterStatuses}');

    await Future.wait([
      _loadAdBanner(),
      _loadAdInter(),
      _loadAdReward(),
      _loadAppOpenAd(),
    ]);
  } catch (e) {
    debugPrint('==> Admob Initialization failed: $e');
    _isInitialized = false;
  }
}
```

Call this method from your splash screen or app initialization:

```dart
@override
void initState() {
  super.initState();
  admobAds.initialize();
}
```

### Remote Configuration (Optional)

The example code includes the ability to load ad unit IDs from a remote JSON file:

```dart
Future<void> _fetchJsonConfiguration() async {
  try {
    final response = await http.get(Uri.parse(Config.jsonLink));
    if (response.statusCode != 200) {
      throw Exception('Failed to load configuration');
    }
    final parsedJson = convert.jsonDecode(response.body) as Map<String, dynamic>;
    Constants.admobBanner = parsedJson[Constants.jsonAds][Constants.jsonAdsAdmob][Constants.jsonAdsAdmobBanner];
    Constants.admobInter = parsedJson[Constants.jsonAds][Constants.jsonAdsAdmob][Constants.jsonAdsAdmobInter];
    Constants.admobReward = parsedJson[Constants.jsonAds][Constants.jsonAdsAdmob][Constants.jsonAdsAdmobReward];
    Constants.admobAppOpen = parsedJson[Constants.jsonAds][Constants.jsonAdsAdmob][Constants.jsonAdsAdmobAppOpen];
  } catch (e) {
    throw Exception('Failed to initialize configuration');
  }
}
```

JSON format example:
```json
{
  "ads": {
    "admob": {
      "banner": "ca-app-pub-3940256099942544/2934735716",
      "inter": "ca-app-pub-3940256099942544/4411468910",
      "reward": "ca-app-pub-3940256099942544/1712485313",
      "appOpen": "ca-app-pub-3940256099942544/5575463023"
    }
  }
}
```

### Using Ads in Your App

#### Banner Ads

To display a banner ad at the bottom of a page:

```dart
Container(
  width: double.infinity,
  child: admobAds.showBannerAd(),
)
```

#### Interstitial Ads

To show an interstitial ad:

```dart
admobAds.showInterstitialAd();
```

#### Rewarded Ads

To show a rewarded ad with a callback for when the user earns a reward:

```dart
admobAds.showRewardedAd(() {
  // Do something when user earns a reward
  setState(() {
    _rewardedAdCount++;
  });
});
```

#### App Open Ads

To show an app open ad (typically used when the app is opened):

```dart
admobAds.showAppOpenAdIfAvailable();
```

Call this in your splash screen or when resuming the app.

## Testing

During development, use Google's test ad unit IDs:

- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`
- App Open: `ca-app-pub-3940256099942544/5575463023`

These IDs will always return test ads, so you can test your implementation without risking your AdMob account.

## Troubleshooting

### Common Issues

1. **Ads not showing**
   - Check if initialization was successful in logs
   - Verify correct ad unit IDs are being used
   - Ensure device has internet connection

2. **Initialization fails**
   - Verify correct app ID in AndroidManifest.xml and Info.plist
   - Check if Google Play Services is updated on test device (Android)

3. **App crashes when showing ads**
   - Make sure to handle null cases when ads fail to load
   - Check logs for specific error messages

4. **Ad loading is slow**
   - Preload ads in advance (as shown in the example)
   - Implement proper error handling with retries

### Best Practices

1. Always dispose ads when they're no longer needed
2. Preload the next ad after the current one is shown
3. Handle failures gracefully with appropriate user feedback
4. Don't show too many ads in a short period (avoid ad fatigue)
5. Test thoroughly with both test and production ad IDs before release

---

This implementation follows Google's recommended practices for AdMob in Flutter apps. For more details, refer to the [Google Mobile Ads Flutter plugin documentation](https://pub.dev/packages/google_mobile_ads).
