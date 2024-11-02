import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:maarifa/core/database/hive/hive_manager.dart';
import 'package:maarifa/core/models/book_model/book.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/models/favoritehadithmodel/favorite_hadith.dart';
import 'package:maarifa/core/models/quran_model/ayah.dart';
import 'package:maarifa/core/models/quran_model/favoriteayah.dart';
import 'package:maarifa/core/models/quran_model/surah.dart';
import 'package:maarifa/core/models/quran_model/surah_detail.dart';
import 'package:maarifa/features/channels/for_users_channel/ui/users_channel_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/home/home_landing_page.dart';
import 'dart:io' show Platform;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool isNotificationsMuted = prefs.getBool('isNotificationsMuted') ?? false;

  if (!isNotificationsMuted) {
    String channelId = message.data['channelId'] ?? 'default_channel';
    String channelName = message.data['title'] ?? 'Default Channel';

    _showNotification(message, channelId, channelName);
  }
}

Future<void> _updateFcmTokenOnAppStart() async {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String? fcmToken = await firebaseMessaging.getToken();

  User? currentUser = firebaseAuth.currentUser;

  if (currentUser != null && fcmToken != null) {
    await firestore.collection('users').doc(currentUser.uid).update({
      'fcmToken': fcmToken,
    });
  }
}

Future<void> _updateFcmToken(String? fcmToken) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? currentUser = firebaseAuth.currentUser;

  if (currentUser != null && fcmToken != null) {
    await firestore.collection('users').doc(currentUser.uid).update({
      'fcmToken': fcmToken,
    });
  }
}

void _initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void _showNotification(RemoteMessage message, String channelId, String channelName) async {
  final notification = message.notification;
  final data = message.data;

  String content = data['content']?.isNotEmpty == true ? data['content'] : 'Sent a photo';

  NotificationDetails? platformChannelSpecifics;

  // Check the platform and set the appropriate sound file
  if (Platform.isAndroid) {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('notification_channels'),
      icon: '@mipmap/ic_launcher',
    );
    platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  } else if (Platform.isIOS || Platform.isMacOS) {
    DarwinNotificationDetails darwinPlatformChannelSpecifics = const DarwinNotificationDetails(
      sound: 'notification_channels.caf', // Use .caf for Darwin (iOS/macOS)
    );
    platformChannelSpecifics = NotificationDetails(iOS: darwinPlatformChannelSpecifics, macOS: darwinPlatformChannelSpecifics);
  }

  await flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification?.title ?? 'New Post in $channelName - maarifa',
    content,
    platformChannelSpecifics,
  );
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _updateFcmTokenOnAppStart();

  // Initializing Hive and registering the adapter
  await Hive.initFlutter();
  Hive.registerAdapter(SurahAdapter());
  Hive.registerAdapter(AyahAdapter());
  Hive.registerAdapter(SurahDetailAdapter());
  Hive.registerAdapter(FavoriteAyahAdapter());
  Hive.registerAdapter(FavoriteHadithAdapter());
  Hive.registerAdapter(BookAdapter());



  // Open Hive boxes
  await HiveBoxManager.getSurahBox();
  await HiveBoxManager.getSurahDetailBox();
  await HiveBoxManager.getFavoriteAyahBox();
  await HiveBoxManager.getFavoriteHadithBox();
  await HiveBoxManager.getBookBox();



  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {


  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);


    return MaterialApp(
      title: 'Maarifa',
      debugShowCheckedModeBanner: false,
      theme: isDarkTheme
          ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        textTheme:  GoogleFonts.robotoMonoTextTheme(Theme.of(context).textTheme),
      )
          : ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoMonoTextTheme(Theme.of(context).textTheme),
      ),
      home: const HomeLandingPage(),
    );
  }


  @override
  void initState() {
    super.initState();

    _initializeNotifications();

    FirebaseMessaging.instance.requestPermission();


    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _updateFcmToken(newToken);
    });

    _updateFcmTokenOnAppStart();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final prefs = await SharedPreferences.getInstance();
      bool isNotificationsMuted = prefs.getBool('isNotificationsMuted') ?? false;

      if (!isNotificationsMuted) {
        String channelId = message.data['channelId'] ?? 'default_channel';
        String channelName = message.data['title'] ?? 'Default Channel';
        _showNotification(message, channelId, channelName);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      String channelId = message.data['channelId'];

      DocumentSnapshot channelSnapshot = await FirebaseFirestore.instance
          .collection('channels')
          .doc(channelId)
          .get();

      if (channelSnapshot.exists) {
        Channel channel = Channel.fromFirestore(channelSnapshot);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserChannelDetailPage(channel: channel),
          ),
        );
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      if (message != null && message.data['channelId'] != null) {
        String channelId = message.data['channelId'];

        DocumentSnapshot channelSnapshot = await FirebaseFirestore.instance
            .collection('channels')
            .doc(channelId)
            .get();

        if (channelSnapshot.exists) {
          Channel channel = Channel.fromFirestore(channelSnapshot);

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserChannelDetailPage(channel: channel),
            ),
          );
        }
      }
    });
  }
}