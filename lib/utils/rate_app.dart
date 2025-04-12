import 'package:flutter/material.dart';
import 'package:hix_admob_example/utils/config.dart';
import 'package:in_app_review/in_app_review.dart';

Future<void> rateApp() async {
  final InAppReview _inAppReview = InAppReview.instance;
  try {
    // Check if the store is available
    final bool isAvailable = await _inAppReview.isAvailable();

    if (isAvailable) {
      // Request a review
      await _inAppReview.requestReview();
    } else {
      // If store isn't available, try to open store page directly
      await _inAppReview.openStoreListing(
        appStoreId: Config.appStoreId, // Replace with your App Store ID
      );
    }
  } catch (e) {
    debugPrint('Error requesting review: $e');
    // if (mounted && context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Unable to open app store'),
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    // }
  }
}
