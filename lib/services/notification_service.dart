import 'dart:convert';
import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

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

    _isInitialized = true;
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        final recipeId = data['recipe_id'];
        if (recipeId != null) {
          final recipe = Recipe.fromMap(data['recipe']);
          AppRoutes.navigatorKey.currentState?.pushNamed(
            AppRoutes.recipeDetail,
            arguments: recipe,
          );
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  Future<bool> requestPermissions() async {
    bool granted = false;
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      granted = await androidImplementation.requestNotificationsPermission() ?? false;
      await androidImplementation.requestExactAlarmsPermission();
    }

    final iOSImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iOSImplementation != null) {
      granted = await iOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }

    return granted;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyMealReminders() async {
    final recipes = await _fetchRandomRecipes(3);
    if (recipes.length < 3) return; 

    await cancelAllNotifications();

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

    await _scheduleMeal(
      id: 1,
      title: breakfastTitles[rand.nextInt(breakfastTitles.length)],
      body: breakfastBodies[rand.nextInt(breakfastBodies.length)].replaceAll('[RECIPE]', recipes[0].recipeName),
      recipe: recipes[0],
      scheduledTime: _nextInstanceOfTime(7, 0, now),
    );

    await _scheduleMeal(
      id: 2,
      title: lunchTitles[rand.nextInt(lunchTitles.length)],
      body: lunchBodies[rand.nextInt(lunchBodies.length)].replaceAll('[RECIPE]', recipes[1].recipeName),
      recipe: recipes[1],
      scheduledTime: _nextInstanceOfTime(12, 0, now),
    );

    await _scheduleMeal(
      id: 3,
      title: dinnerTitles[rand.nextInt(dinnerTitles.length)],
      body: dinnerBodies[rand.nextInt(dinnerBodies.length)].replaceAll('[RECIPE]', recipes[2].recipeName),
      recipe: recipes[2],
      scheduledTime: _nextInstanceOfTime(18, 0, now),
    );
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
