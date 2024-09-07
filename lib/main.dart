import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:maarifa/core/database/hive/hive_manager.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/ayah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/favoriteayah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah_detail.dart';
import 'package:maarifa/secrets/keys.dart';
import 'core/database/supabaseservice.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/sign_in/signin_page.dart';
import 'features/home/home_landing_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing Hive and registering the adapter
  await Hive.initFlutter();
  Hive.registerAdapter(SurahAdapter());
  Hive.registerAdapter(AyahAdapter());
  Hive.registerAdapter(SurahDetailAdapter());
  Hive.registerAdapter(FavoriteAyahAdapter());



  // Open Hive boxes
  await HiveBoxManager.getSurahBox();
  await HiveBoxManager.getSurahDetailBox();
  await HiveBoxManager.getFavoriteAyahBox();


  await Supabase.initialize(url: url, anonKey: anonKey);

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
      theme: isDarkTheme
          ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColorsDark.purpleColor),
        useMaterial3: true,
        textTheme:  GoogleFonts.robotoMonoTextTheme(Theme.of(context).textTheme),
      )
          : ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purpleColor),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoMonoTextTheme(Theme.of(context).textTheme),
      ),
      home: SplashPage(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeAndCheckUser(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return SignInPage();
        } else {
          final isUserLoggedIn = snapshot.data ?? false;
          return isUserLoggedIn ? HomeLandingPage() : SignInPage();
        }
      },
    );
  }

  Future<bool> _initializeAndCheckUser() async {
    final supabase = SupabaseService().supabaseClient;
    final user = supabase.auth.currentUser;

    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();

      if (response.isNotEmpty ) {
        return true; // User is logged in and profile exists
      }
    }

    return false; // No user logged in or no profile found
  }
}
