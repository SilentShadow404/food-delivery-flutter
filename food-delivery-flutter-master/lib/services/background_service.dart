import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'logger_service.dart';

/// Task name constants
const kCheckVendorOrdersTask = 'check_vendor_orders';
const kSyncCartTask = 'sync_cart_background';

/// Top-level callback executed by WorkManager in a separate isolate.
/// Must be a top-level function and annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
void workManagerCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    log.info('[WorkManager] Running task: $taskName');

    switch (taskName) {
      case kCheckVendorOrdersTask:
        await _checkForNewOrders(inputData);
        break;
      case kSyncCartTask:
        log.info('[WorkManager] Cart sync task executed.');
        break;
    }
    return Future.value(true); // true = success; false = retry
  });
}

/// Background task: poll the server for new pending orders.
/// In production this would be replaced by FCM push notifications.
Future<void> _checkForNewOrders(Map<String, dynamic>? data) async {
  try {
    final vendorId = data?['vendorId'] as String?;
    if (vendorId == null) return;

    const base = String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://192.168.109.131:3000/api');
    final uri = Uri.parse('$base/orders/vendor/$vendorId');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body) as Map<String, dynamic>;
      final orders = decoded['orders'] as List<dynamic>? ?? [];
      final pending = orders.where((o) {
        return (o as Map<String, dynamic>)['status'] == 'pending';
      }).length;
      log.info('[WorkManager] Vendor $vendorId has $pending pending orders.');
    }
  } catch (e, s) {
    log.error('[WorkManager] _checkForNewOrders failed', e, s);
  }
}

class BackgroundService {
  BackgroundService._();
  static final BackgroundService instance = BackgroundService._();

  /// Initialize WorkManager — call once in main().
  Future<void> init() async {
    if (kIsWeb) return;
    await Workmanager().initialize(
      workManagerCallbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    log.info('[WorkManager] Initialized.');
  }

  /// Register a periodic vendor order-check (runs ~every 15 minutes).
  Future<void> registerVendorOrderCheck(String vendorId) async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      'vendor_order_check_$vendorId',
      kCheckVendorOrdersTask,
      frequency: const Duration(minutes: 15),
      inputData: {'vendorId': vendorId},
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    log.info('[WorkManager] Registered order-check task for vendor $vendorId');
  }

  /// One-off task demonstrating compute isolate usage.
  /// Sorts orders by total (heavy computation) in a separate isolate.
  static Future<List<Map<String, dynamic>>> sortOrdersInIsolate(
      List<Map<String, dynamic>> orders) async {
    return compute(_sortByTotal, orders);
  }

  static List<Map<String, dynamic>> _sortByTotal(
      List<Map<String, dynamic>> orders) {
    final sorted = List<Map<String, dynamic>>.from(orders);
    sorted.sort((a, b) {
      final ta = (a['total'] as num?)?.toDouble() ?? 0;
      final tb = (b['total'] as num?)?.toDouble() ?? 0;
      return tb.compareTo(ta);
    });
    return sorted;
  }

  /// Cancel all background tasks.
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await Workmanager().cancelAll();
    log.info('[WorkManager] All tasks cancelled.');
  }
}

final backgroundService = BackgroundService.instance;
