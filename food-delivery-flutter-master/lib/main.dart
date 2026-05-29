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
  await Firebase.initializeApp();
  log.info('[main] Firebase initialized');

  // ── Notifications ───────────────────────────────────────────────────────
  await notifications.init();

  // ── AdMob ───────────────────────────────────────────────────────────────
  await MobileAds.instance.initialize();
  log.info('[main] AdMob initialized');

  // ── Background tasks ────────────────────────────────────────────────────
  await backgroundService.init();

  runApp(const FoodDeliveryApp());
}
