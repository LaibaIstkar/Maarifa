import 'package:flutter/material.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';



class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool isDarkTheme;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: isDarkTheme ? AppColorsDark.spaceCadetColor : AppColors.spaceCadetColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.chat_rounded, "Channels", 1),
              _buildNavItem(Icons.bar_chart_sharp, "Stats", 2),
              _buildNavItem(Icons.settings, "Settings", 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData iconData, String label, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isSelected ? 10 : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 8),
          decoration: BoxDecoration(
            color: isSelected ? (isDarkTheme ? AppColorsDark.primaryColorPlatinum : AppColors.primaryColorPlatinum) : Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isSelected
                    ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontFamily: 'PoppinsBold'),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
