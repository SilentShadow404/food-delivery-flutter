import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zomato/app.dart';
import 'package:zomato/services/background_service.dart';
import 'package:zomato/services/logger_service.dart';
import 'package:zomato/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ────────────────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAPwmxs1Y-VA1fG9uaEGyoumw5131shRqA',
        appId: '1:176576859566:android:65afb0da55737825',
        messagingSenderId: '176576859566',
        projectId: 'zomato-101e9',
        storageBucket: 'zomato-101e9.appspot.com',
        databaseURL: 'https://zomato-101e9.firebaseio.com',
      ),
    );
    log.info('[main] Firebase initialized');
  } catch (e) {
    log.warning('[main] Firebase init failed: $e');
  }

  // ── Notifications ───────────────────────────────────────────────────────
  try {
    await notifications.init();
  } catch (e) {
    log.warning('[main] Notifications init failed: $e');
  }

  // ── AdMob ───────────────────────────────────────────────────────────────
  await MobileAds.instance.initialize();
  log.info('[main] AdMob initialized');

  // ── Background tasks ────────────────────────────────────────────────────
  await backgroundService.init();

  runApp(const FoodDeliveryApp());
}
