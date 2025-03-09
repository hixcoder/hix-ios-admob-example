import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hix_admob_example/networks/admob.dart';
import 'package:hix_admob_example/screens/home_screen.dart';
import 'package:hix_admob_example/utils/config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hix_admob_example/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool visibility = true;
  String errorMessage = "Try again";
  // final AdmobAds _admobAds = AdmobAds();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Keeping your existing logic methods unchanged
  Future<void> _initializeApp() async {
    if (!mounted) return;
    try {
      print("dd");
      final List<ConnectivityResult> connectivityResult =
          (await (Connectivity().checkConnectivity()));
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _handleError("No Internet");
        return;
      }
      await _fetchJsonConfiguration();

      // Add a small delay to ensure ad is loaded
      await Future.delayed(const Duration(seconds: 1));

      // Try to show app open ad
      try {
        // await _admobAds.showAppOpenAdIfAvailable();
      } catch (adError) {
        // If ad fails, just log it and continue
        if (kDebugMode) {
          print('App Open Ad error: $adError');
        }
      }

      // Add a small delay after showing ad
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Initialization error: $e');
      }
      _handleError("Something went wrong");
    }
  }

  Future<void> _fetchJsonConfiguration() async {
    try {
      final response = await http.get(Uri.parse(Config.jsonLink));
      if (response.statusCode != 200) {
        throw Exception('Failed to load configuration');
      }
      final parsedJson =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      Constants.admobBanner = parsedJson[Constants.jsonAds]
          [Constants.jsonAdsAdmob][Constants.jsonAdsAdmobBanner];
      Constants.admobInter = parsedJson[Constants.jsonAds]
          [Constants.jsonAdsAdmob][Constants.jsonAdsAdmobInter];
      Constants.admobReward = parsedJson[Constants.jsonAds]
          [Constants.jsonAdsAdmob][Constants.jsonAdsAdmobReward];
      Constants.admobAppOpen = parsedJson[Constants.jsonAds]
          [Constants.jsonAdsAdmob][Constants.jsonAdsAdmobAppOpen];
    } catch (e) {
      if (kDebugMode) {
        print('JSON fetch error: $e');
      }
      throw Exception('Failed to initialize configuration');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        visibility = false;
        errorMessage = message;
      });
    }
  }

  Future<void> _retry() async {
    if (mounted) {
      setState(() {
        visibility = true;
        errorMessage = "Try again";
      });
      await Future.delayed(
        const Duration(seconds: Config.splashTime),
        () => _initializeApp(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.router,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              "admob test",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (visibility)
              const CircularProgressIndicator(
                color: Colors.blue,
              )
            else
              ElevatedButton(
                onPressed: _retry,
                child: Text(errorMessage),
              ),
          ],
        ),
      ),
    );
  }
}
