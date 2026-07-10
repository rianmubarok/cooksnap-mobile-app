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
      if (prefs.getBool('meal_reminders_enabled') == true) {
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
    );

    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    final r0 = recipes[0];
    final r1 = recipes.length > 1 ? recipes[1] : recipes[0];
    final r2 = recipes.length > 2 ? recipes[2] : recipes[0];
    final r3 = recipes.length > 3 ? recipes[3] : recipes[0];

    final historyList = [
      {
        'id': 1,
        'mealType': 'Sarapan Pagi',
        'emoji': '🍳',
        'timeString': '07:00',
        'timestamp': DateTime(now.year, now.month, now.day, 7, 0).toIso8601String(),
        'title': bTitle,
        'body': bBody,
        'isRead': false,
        'recipeId': r0.id,
        'recipeName': r0.recipeName,
        'description': r0.description,
        'imageUrl': r0.imageUrl,
        'thumbnailUrl': r0.thumbnailUrl,
        'recipe': r0.toMap(),
      },
      {
        'id': 2,
        'mealType': 'Makan Malam',
        'emoji': '🌙',
        'timeString': '18:30',
        'timestamp': DateTime(yesterday.year, yesterday.month, yesterday.day, 18, 30).toIso8601String(),
        'title': dinnerTitles[1],
        'body': dinnerBodies[1].replaceAll('[RECIPE]', r1.recipeName),
        'isRead': true,
        'recipeId': r1.id,
        'recipeName': r1.recipeName,
        'description': r1.description,
        'imageUrl': r1.imageUrl,
        'thumbnailUrl': r1.thumbnailUrl,
        'recipe': r1.toMap(),
      },
      {
        'id': 3,
        'mealType': 'Makan Siang',
        'emoji': '🍱',
        'timeString': '12:15',
        'timestamp': DateTime(yesterday.year, yesterday.month, yesterday.day, 12, 15).toIso8601String(),
        'title': lunchTitles[1],
        'body': lunchBodies[1].replaceAll('[RECIPE]', r2.recipeName),
        'isRead': true,
        'recipeId': r2.id,
        'recipeName': r2.recipeName,
        'description': r2.description,
        'imageUrl': r2.imageUrl,
        'thumbnailUrl': r2.thumbnailUrl,
        'recipe': r2.toMap(),
      },
      {
        'id': 4,
        'mealType': 'Sarapan Pagi',
        'emoji': '🍳',
        'timeString': '07:30',
        'timestamp': DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 7, 30).toIso8601String(),
        'title': breakfastTitles[1],
        'body': breakfastBodies[1].replaceAll('[RECIPE]', r3.recipeName),
        'isRead': true,
        'recipeId': r3.id,
        'recipeName': r3.recipeName,
        'description': r3.description,
        'imageUrl': r3.imageUrl,
        'thumbnailUrl': r3.thumbnailUrl,
        'recipe': r3.toMap(),
      },
    ];
    await prefs.setString('notification_history_log', jsonEncode(historyList));
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
  }) async {
    final payload = jsonEncode({
      'recipe_id': recipe.id,
      'recipe': recipe.toMap(),
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
