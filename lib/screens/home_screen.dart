import 'package:flutter/material.dart';
import 'package:hix_admob_example/networks/admob.dart';

AdmobAds admobAds = AdmobAds();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _rewardedAdCount = 0;

  @override
  void initState() {
    super.initState();
    admobAds.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AdMob Test Page',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'AdMob Test Interface',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            // Interstitial Ad Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                minimumSize: Size(250, 60),
              ),
              onPressed: () => admobAds.showInterstitialAd(),
              child: Text(
                'Show Interstitial Ad',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            SizedBox(height: 20),

            // Rewarded Ad Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                minimumSize: Size(250, 60),
              ),
              onPressed: () {
                admobAds.showRewardedAd(() {
                  setState(() {
                    _rewardedAdCount++;
                  });
                });
              },
              child: Text(
                'Show Rewarded Ad',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            SizedBox(height: 10),

            // Display rewards count
            Text(
              'Rewards received: $_rewardedAdCount',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),

            // App Open Ad Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                minimumSize: Size(250, 60),
              ),
              onPressed: () => admobAds.showAppOpenAdIfAvailable(),
              child: Text(
                'Show App Open Ad',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            // Push content up to make room for banner at bottom
            Spacer(),

            // Banner Ad
            Container(
              width: double.infinity,
              child: admobAds.showBannerAd(),
            ),
          ],
        ),
      ),
    );
  }
}
