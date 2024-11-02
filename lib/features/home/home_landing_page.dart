
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/bottom_navbar.dart';
import 'package:maarifa/features/admin/ui/admin_joined_channels.dart';
import 'package:maarifa/features/asmaulhusna/asma_ul_husna.dart';
import 'package:maarifa/features/auth/view/sign_in_page.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';
import 'package:maarifa/features/channels/for_users_channel/ui/users_joined_channels.dart';
import 'package:maarifa/features/hadith/hadith_section.dart';
import 'package:maarifa/features/knowledge/view/mainpage/knowledge_page.dart';
import 'package:maarifa/features/quran/quran_surah_listing/view/quran_list_page.dart';

import 'package:maarifa/features/settings/settings_page.dart';
import 'dart:math' as math;


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
    final authView = ref.watch(authViewModelProvider);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        automaticallyImplyLeading: false,
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isDarkTheme: isDarkTheme,
      ),
      body: _selectedIndex == 0
          ? _buildHomePageContent(isDarkTheme)
          : _selectedIndex == 1
          ? FutureBuilder<bool>(
        future: authView.isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data == true ? const AdminJoinedChannelsPage() : const UsersJoinedChannelsPage();
          } else {
            return const UsersJoinedChannelsPage();
          }
        },
      )
          : _selectedIndex == 2
          ? const UsersJoinedChannelsPage()
          : const SettingsPage(),
    );
  }

  Widget _buildHomePageContent(bool isDarkTheme) {
    return Column(
      children: [
         GestureDetector(child: const Text('Sign In'), onTap: () {
           Navigator.of(context).push(
             MaterialPageRoute(
               builder: (context) =>  const SignInPage(),
             ),
           );
         }, ),

        // Main card with dynamic height
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(16),
                  color: isDarkTheme ? Colors.grey[600] : Colors.white,
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
                      if (index == 1) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>  const HadithSection(),
                          ),
                        );
                      }

                      if (index == 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>  const AsmaUlHusna(),
                          ),
                        );
                      }

                      if (index == 3) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>  const KnowledgePage(),
                          ),
                        );
                      }
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

