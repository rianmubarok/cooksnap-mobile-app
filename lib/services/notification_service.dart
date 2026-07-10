import 'dart:convert';
import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/app_routes.dart';
import '../core/pocketbase_client.dart';
import '../models/recipe_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool isAppReady = false;
  Recipe? pendingRecipe;

  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      String rawTz = (await FlutterTimezone.getLocalTimezone()).toString();
      String tzName = rawTz;
      final ianaMatch = RegExp(r'([A-Za-z]+/[A-Za-z_]+)').firstMatch(rawTz);
      if (ianaMatch != null) {
        tzName = ianaMatch.group(1)!;
      } else if (tzName == 'SE Asia Standard Time' || tzName.contains('+07')) {
        tzName = 'Asia/Jakarta';
      } else if (tzName.contains('+08')) {
        tzName = 'Asia/Makassar';
      } else if (tzName.contains('+09')) {
        tzName = 'Asia/Jayapura';
      }
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e) {
      debugPrint('Could not set exact local timezone ($e), falling back to Asia/Jakarta');
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {}
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Cek detail launch jika aplikasi dibuka melalui notifikasi dari terminated state
    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp && details.notificationResponse != null) {
      _handleNotificationTap(details.notificationResponse!.payload);
    }

    _isInitialized = true;
    _refreshScheduleIfNeeded();
  }

  Future<void> _refreshScheduleIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('meal_reminders_enabled') == true;
      if (isEnabled) {
        // Do not await to avoid blocking app startup
        scheduleDailyMealReminders();
      }
    } catch (e) {
      debugPrint('Error refreshing schedule: $e');
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        final recipeId = data['recipe_id'];
        if (recipeId != null) {
          final recipe = Recipe.fromMap(data['recipe']);
          // Catat ke history saat notifikasi di-tap (bukan saat dijadwalkan)
          _appendToHistory(data, recipe);
          if (isAppReady && AppRoutes.navigatorKey.currentState != null) {
            AppRoutes.navigatorKey.currentState?.pushNamed(
              AppRoutes.recipeDetail,
              arguments: recipe,
            );
          } else {
            pendingRecipe = recipe;
          }
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Menambahkan satu entri ke history saat notifikasi di-tap.
  Future<void> _appendToHistory(
    Map<String, dynamic> data,
    Recipe recipe,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getNotificationHistory();

      // Hindari duplikat berdasarkan id notifikasi
      final notifId = data['notif_id'] as int? ?? dart_math.Random().nextInt(100000);
      if (existing.any((e) => e['id'] == notifId)) return;

      final entry = {
        'id': notifId,
        'mealType': data['meal_type'] ?? '',
        'emoji': data['emoji'] ?? '🔔',
        'timeString': data['time_string'] ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'title': data['title'] ?? '',
        'body': data['body'] ?? '',
        'isRead': true, // Langsung read karena user sudah tap
        'recipeId': recipe.id,
        'recipeName': recipe.recipeName,
        'description': recipe.description,
        'imageUrl': recipe.imageUrl,
        'thumbnailUrl': recipe.thumbnailUrl,
        'recipe': recipe.toMap(),
      };

      final updated = [entry, ...existing];
      await prefs.setString('notification_history_log', jsonEncode(updated));
    } catch (e) {
      debugPrint('Error appending notification history: $e');
    }
  }

  void processPendingNotification() {
    isAppReady = true;
    if (pendingRecipe != null) {
      final recipe = pendingRecipe!;
      pendingRecipe = null;
      Future.delayed(const Duration(milliseconds: 500), () {
        AppRoutes.navigatorKey.currentState?.pushNamed(
          AppRoutes.recipeDetail,
          arguments: recipe,
        );
      });
    }
  }

  Future<bool> checkPermissionStatus() async {
    try {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final enabled = await androidImplementation.areNotificationsEnabled();
        return enabled ?? true;
      }
    } catch (_) {}
    return true;
  }

  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final alreadyEnabled =
            await androidImplementation.areNotificationsEnabled();
        if (alreadyEnabled == true) {
          return true;
        }
        await androidImplementation.requestNotificationsPermission();
        final enabledAfter =
            await androidImplementation.areNotificationsEnabled();
        return enabledAfter ?? false;
      }

      final iOSImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iOSImplementation != null) {
        final granted = await iOSImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? true;
      }
    } catch (_) {}

    return true;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('meal_reminders_enabled', false);
  }

  Future<void> scheduleDailyMealReminders({bool forceResetHistory = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final existingLog = prefs.getString('notification_history_log');
    if (!forceResetHistory && existingLog != null && existingLog.isNotEmpty) {
      await prefs.setBool('meal_reminders_enabled', true);
      return;
    }

    final recipes = await _fetchRandomRecipes(3);
    if (recipes.length < 3) return; 

    await flutterLocalNotificationsPlugin.cancelAll();
    await prefs.setBool('meal_reminders_enabled', true);

    final now = tz.TZDateTime.now(tz.local);
    final rand = dart_math.Random();

    final breakfastTitles = ['Waktunya Sarapan! 🍳', 'Pagi yang Cerah! ☀️', 'Sudah Lapar? 😋', 'Awali Harimu! 🌅'];
    final breakfastBodies = [
      'Coba resep [RECIPE] untuk memulai harimu!',
      'Yuk bikin [RECIPE] buat sarapan pagi ini.',
      '[RECIPE] cocok banget nemenin ngopi pagimu.',
      'Energi ekstra dengan [RECIPE] pagi ini!',
    ];

    final lunchTitles = ['Makan Siang Spesial! 🍱', 'Istirahat Dulu Yuk! 🕛', 'Waktunya Isi Tenaga! 🔋', 'Makan Siang Tiba! 🍜'];
    final lunchBodies = [
      'Gimana kalau masak [RECIPE] siang ini?',
      'Menu siang ini: [RECIPE]. Pasti mantap!',
      'Lepas penat dengan menikmati [RECIPE].',
      '[RECIPE] siap menyelamatkan perut keronconganmu!',
    ];

    final dinnerTitles = ['Makan Malam Menarik! 🌙', 'Waktunya Bersantai! 🛋️', 'Malam Sempurna! ✨', 'Penutup Hari! 🌃'];
    final dinnerBodies = [
      'Tutup harimu dengan lezatnya [RECIPE].',
      'Makan malam hangat dengan [RECIPE] bareng keluarga.',
      'Menu lezat malam ini: [RECIPE].',
      'Manjakan lidahmu dengan [RECIPE] malam ini.',
    ];

    final t7 = _nextInstanceOfTime(7, 0, now);
    final bTitle = breakfastTitles[rand.nextInt(breakfastTitles.length)];
    final bBody = breakfastBodies[rand.nextInt(breakfastBodies.length)].replaceAll('[RECIPE]', recipes[0].recipeName);
    await _scheduleMeal(
      id: 1,
      title: bTitle,
      body: bBody,
      recipe: recipes[0],
      scheduledTime: t7,
      mealType: 'Sarapan Pagi',
      emoji: '🍳',
      timeString: '07:00',
    );

    final t12 = _nextInstanceOfTime(12, 0, now);
    final lTitle = lunchTitles[rand.nextInt(lunchTitles.length)];
    final lBody = lunchBodies[rand.nextInt(lunchBodies.length)].replaceAll('[RECIPE]', recipes[1].recipeName);
    await _scheduleMeal(
      id: 2,
      title: lTitle,
      body: lBody,
      recipe: recipes[1],
      scheduledTime: t12,
      mealType: 'Makan Siang',
      emoji: '🍱',
      timeString: '12:00',
    );

    final t18 = _nextInstanceOfTime(18, 0, now);
    final dTitle = dinnerTitles[rand.nextInt(dinnerTitles.length)];
    final dBody = dinnerBodies[rand.nextInt(dinnerBodies.length)].replaceAll('[RECIPE]', recipes[2].recipeName);
    await _scheduleMeal(
      id: 3,
      title: dTitle,
      body: dBody,
      recipe: recipes[2],
      scheduledTime: t18,
      mealType: 'Makan Malam',
      emoji: '🌙',
      timeString: '18:00',
    );
    // History TIDAK dibuat di sini — akan dicatat saat user men-tap notifikasi
  }

  Future<bool> isRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('meal_reminders_enabled') ?? false;
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('meal_reminders_enabled', enabled);
    if (enabled) {
      await scheduleDailyMealReminders();
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notification_history_log');
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDeliveredNotifications() async {
    final all = await getNotificationHistory();
    if (all.isEmpty) return [];
    all.sort((a, b) {
      final ta = DateTime.tryParse(a['timestamp']?.toString() ?? '') ?? DateTime(2000);
      final tb = DateTime.tryParse(b['timestamp']?.toString() ?? '') ?? DateTime(2000);
      return tb.compareTo(ta);
    });
    return all;
  }

  Future<void> markAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getNotificationHistory();
    final updated = all.map((item) {
      if (item['id'] == id) {
        final copy = Map<String, dynamic>.from(item);
        copy['isRead'] = true;
        return copy;
      }
      return item;
    }).toList();
    await prefs.setString('notification_history_log', jsonEncode(updated));
  }

  Future<bool> hasUnreadNotifications() async {
    final delivered = await getDeliveredNotifications();
    return delivered.any((item) => item['isRead'] != true);
  }

  Future<void> resetDebugUnread() async {
    await scheduleDailyMealReminders();
    final prefs = await SharedPreferences.getInstance();
    final all = await getNotificationHistory();
    final updated = all.asMap().entries.map((entry) {
      final copy = Map<String, dynamic>.from(entry.value);
      copy['isRead'] = entry.key != 0; // Item pertama false (belum dibuka), lainnya true
      return copy;
    }).toList();
    await prefs.setString('notification_history_log', jsonEncode(updated));
  }

  Future<void> _scheduleMeal({
    required int id,
    required String title,
    required String body,
    required Recipe recipe,
    required tz.TZDateTime scheduledTime,
    required String mealType,
    required String emoji,
    required String timeString,
  }) async {
    // Sertakan metadata di payload agar history bisa direkonstruksi saat notifikasi di-tap
    final payload = jsonEncode({
      'notif_id': id,
      'recipe_id': recipe.id,
      'recipe': recipe.toMap(),
      'title': title,
      'body': body,
      'meal_type': mealType,
      'emoji': emoji,
      'time_string': timeString,
    });

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Pengingat Waktu Makan',
          channelDescription: 'Notifikasi untuk resep sarapan, siang, dan malam',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, tz.TZDateTime now) {
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<List<Recipe>> _fetchRandomRecipes(int count) async {
    try {
      final pb = PocketBaseClient.instance;
      final records = await pb.collection('recipes').getList(
        page: 1,
        perPage: count,
        sort: '@random',
      );
      
      return records.items.map((r) {
        try {
          return Recipe.fromMap(r.toJson());
        } catch (_) {
          return null;
        }
      }).whereType<Recipe>().toList();
    } catch (e) {
      debugPrint('Error fetching random recipes for notification: $e');
      return [];
    }
  }
}
