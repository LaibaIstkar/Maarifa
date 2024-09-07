import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/bottom_navbar.dart';
import 'package:maarifa/features/quran/quran_surah_listing/view/quran_list_page.dart';

import 'package:maarifa/features/settings/settings_page.dart';
import 'package:maarifa/features/user_profile/user_profile.dart';
import 'dart:math' as math;

import 'package:maarifa/features/user_profile/viewmodel/user_notifier.dart';

class HomeLandingPage extends ConsumerStatefulWidget {
  const HomeLandingPage({super.key});

  @override
  ConsumerState<HomeLandingPage> createState() => _HomeLandingPageState();
}

class _HomeLandingPageState extends ConsumerState<HomeLandingPage> {
  int _selectedIndex = 0;

  final List<String> cardLabels = ['Quran', 'Hadeeth', 'Asma ul Husna', 'Knowledge'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final usernameAsyncValue = ref.watch(userNotifierProvider);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        automaticallyImplyLeading: false,
        title: usernameAsyncValue.when(
          data: (userdata) => Text(userdata.username, style: TextStyle(fontSize: 17, color: isDarkTheme ? Colors.white : Colors.black)),
          loading: () => Text('Loading...', style: TextStyle(fontSize: 17, color: isDarkTheme ? Colors.white : Colors.black)),
          error: (error, _) => Text('Error: $error', style: TextStyle(fontSize: 17, color: isDarkTheme ? Colors.white : Colors.black)),
        ),
        actions:  [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserProfile(),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/profile_pic.png'),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: _selectedIndex == 0
          ? _buildHomePageContent(isDarkTheme)
          : _selectedIndex == 1
          ? const SettingsPage()
          : _selectedIndex == 2
          ? const SettingsPage()
          : const SettingsPage(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isDarkTheme: isDarkTheme,
      ),
    );
  }

  Widget _buildHomePageContent(bool isDarkTheme) {
    return Column(
      children: [
        // Main card with dynamic height
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(16),
                  color: isDarkTheme ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leave space for the quote icon
                        const SizedBox(height: 20),
                        Text(
                          "When the exception was thrown, this was the stack PlatformAssetBundle.loadBuffer...",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: isDarkTheme ? AppColorsDark.text : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -16,
                  left: 16,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: Icon(
                      Icons.format_quote,
                      size: MediaQuery.of(context).size.width * 0.2,
                      color: isDarkTheme
                          ? AppColorsDark.primaryColorPlatinum.withOpacity(0.90)
                          : AppColors.purpleColor.withOpacity(0.90),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Grid of smaller cards
        Expanded(
          flex: 3,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const QuranListPage(),
                          ),
                        );
                      }
                      // You can handle other indexes similarly or leave them for future use
                    },

                    child: Column(
                      children: [
                        Card(
                          elevation: 10,
                          color: isDarkTheme ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isDarkTheme
                                  ? AppColorsDark.primaryColorPlatinum
                                  : AppColors.purpleColor,
                              width: 2,
                            ),
                          ),
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: !isDarkTheme
                                ? SvgPicture.asset(
                              'assets/cards/image$index.svg',
                              fit: BoxFit.scaleDown,
                            )
                                : SvgPicture.asset(
                              'assets/cards/imagewhite$index.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cardLabels[index],
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkTheme ? AppColorsDark.text : AppColors.spaceCadetColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

