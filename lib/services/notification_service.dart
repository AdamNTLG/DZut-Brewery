import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/batch_hop_addition.dart';

/// Service for scheduling local notifications (dry hop reminders, etc.)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'dry_hop_reminders';
  static const String _channelName = 'Dry Hop Reminders';
  static const String _channelDesc = 'Rappels pour ajouter les houblons en dry hop';

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedule dry hop reminders at 09:00 on the day each dry hop should be added.
  /// [fermentationEndDate] = expected end of fermentation.
  /// Each hop's [dryHopStartDay] = days before end of fermentation.
  Future<void> scheduleDryHopNotifications({
    required String batchId,
    required String batchName,
    required List<BatchHopAddition> dryHops,
    required DateTime fermentationEndDate,
  }) async {
    await initialize();

    for (final hop in dryHops) {
      if (hop.type != HopAdditionType.dryHop) continue;
      if (hop.addedAt != null) continue; // already done
      if (hop.dryHopStartDay == null) continue;

      // Calculate notification date: fermentationEnd - dryHopStartDay days, at 09:00
      final notifDate = fermentationEndDate
          .subtract(Duration(days: hop.dryHopStartDay!))
          .copyWith(hour: 9, minute: 0, second: 0, millisecond: 0, microsecond: 0);

      // Skip if the date is in the past
      if (notifDate.isBefore(DateTime.now())) continue;

      final notifId = _notificationId(batchId, hop.id);

      await _plugin.zonedSchedule(
        notifId,
        '🍃 Dry Hop — $batchName',
        'Ajouter ${hop.amountGrams.toStringAsFixed(0)}g de ${hop.hopName} dans le fermenteur.',
        tz.TZDateTime.from(notifDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Cancel all scheduled notifications for a given batch.
  Future<void> cancelBatchNotifications(String batchId, List<String> hopIds) async {
    await initialize();
    for (final hopId in hopIds) {
      await _plugin.cancel(_notificationId(batchId, hopId));
    }
  }

  /// Deterministic int ID from batchId + hopId (fits in 32-bit int).
  int _notificationId(String batchId, String hopId) {
    final combined = batchId + hopId;
    return combined.codeUnits.fold(0, (prev, e) => (prev * 31 + e) & 0x7FFFFFFF);
  }
}
