import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/audio_player_widget.dart';
import 'package:maarifa/features/asmaulhusna/service/audio_player_controller.dart';
import 'asma_ul_husna_data.dart';
import 'dart:math' as math;


class AsmaUlHusna extends ConsumerStatefulWidget {
  const AsmaUlHusna({super.key});

  @override
  ConsumerState<AsmaUlHusna> createState() => _AsmaUlHusnaState();
}

class _AsmaUlHusnaState extends ConsumerState<AsmaUlHusna> {
  late AudioPlayerController _audioPlayerController;
  int selectedNameIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayerController = AudioPlayerController();
  }

  @override
  void dispose() {
    _audioPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(
            "AsmaUl Husna",
            style: TextStyle(
              fontSize: 17,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontFamily: 'PoppinsBold',
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Challenge',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'PoppinsBold',
                  color: isDarkTheme
                      ? AppColorsDark.purpleColor
                      : AppColors.spaceCadetColor,
                ),
              ),
            ),
          ),
        ]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkTheme ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: Column(
        children: [
          // Text Views
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Replacing Expanded with Flexible or giving the Stack a fixed height
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.29, // 30% of the screen height
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
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive vertical spacing
                              Text(
                                "'And to Allah belong the best names, so invoke Him by them.. (Quran 7:180)'",
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.035, // Responsive text size
                                  fontFamily: 'PoppinsItalic',
                                  color: isDarkTheme ? AppColorsDark.text : Colors.black,
                                ),
                              ),
                              const Divider(),
                              Text(
                                "'Prophet Muhammad (ﷺ) said, “Allah has ninety-nine names, i.e. one-hundred minus one, and whoever knows them will go to Paradise.'",
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.035, // Responsive text size
                                  fontFamily: 'PoppinsItalic',
                                  color: isDarkTheme ? AppColorsDark.text : Colors.black,
                                ),
                              ),
                              Text(
                                "(Sahih Bukhari 54:23)",
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.03, // Smaller text size for the reference
                                  fontFamily: 'Poppins',
                                  color: isDarkTheme ? Colors.white60 : Colors.black54,
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
                            size: MediaQuery.of(context).size.width * 0.2, // Responsive icon size
                            color: isDarkTheme
                                ? AppColorsDark.primaryColorPlatinum.withOpacity(0.90)
                                : AppColors.purpleColor.withOpacity(0.90),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(),
                Text(
                  'Listen and Explore the Beautiful Names',
                  style: TextStyle(color: isDarkTheme ? AppColorsDark.text : Colors.black,fontSize: 15, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),

          const AudioPlayerWidget(),
          // PageView for 99 Names
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  selectedNameIndex = index;
                });
              },
              itemCount: AsmaUlHusnaData.data.length,
              itemBuilder: (context, index) {
                final nameData = AsmaUlHusnaData.data[index];
                bool isSelected = selectedNameIndex == index;

                double screenHeight = MediaQuery.of(context).size.height;

                double fontSize = isSelected ? screenHeight * 0.02 : screenHeight * 0.01; // Adjust based on the screen height
                double arabicFontSize = isSelected ? screenHeight * 0.06 : screenHeight * 0.05; // Arabic font size
                double transliterationFontSize = screenHeight * 0.03; // Transliteration font size
                double meaningFontSize = screenHeight * 0.025; // Meaning font size

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${nameData['number']}',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'PoppinsBold',
                          color:isDarkTheme ? isSelected ? Colors.white60 : Colors.black: isSelected ? Colors.black54 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        '${nameData['arabic']}',
                        style: TextStyle(
                          fontSize: arabicFontSize,
                          fontFamily: 'AmiriRegularNormal',
                          color: isDarkTheme ? isSelected ? AppColorsDark.primaryColorPlatinum : AppColors.purpleColor: isSelected ? AppColors.purpleColor : AppColorsDark.primaryColorPlatinum,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),

                      Text(
                        '${nameData['transliteration']}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: transliterationFontSize,
                          color: isDarkTheme ? isSelected ? Colors.white : Colors.black: isSelected ? Colors.black : Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),

                      Text(
                        '${nameData['meaning']}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: meaningFontSize,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
