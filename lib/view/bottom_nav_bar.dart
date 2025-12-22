// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:time_trace/config/theme/extension/app_colors.dart';
import 'package:time_trace/config/theme/extension/app_theme_extension.dart';
import 'package:time_trace/config/theme/theme_getter.dart';

class BottomNavBar extends StatelessWidget {
  final Widget child;

  const BottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: _buildGnav(context, appColors),
      ),
      body: child,
    );
  }

  Widget _buildGnav(BuildContext context, AppColors appColors) {
    return GNav(
      onTabChange: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/category');
            break;
          case 2:
            context.go('/report');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      tabBorderRadius: 8,
      tabActiveBorder: Border.all(
        color: appColors.primary,
        width: 1,
      ), // tab button border
      tabBorder: Border.all(
        color: Colors.transparent,
        width: 1,
      ), // tab button border
      curve: Curves.bounceIn, // tab animation curves
      duration: Duration(milliseconds: 300), // tab animation duration
      gap: 8, // the tab button gap between icon and text
      color: appColors.primary, // unselected icon color
      activeColor: appColors.primary, // selected icon and text color
      iconSize: 24, // tab button icon size
      tabBackgroundColor: appColors.primary.withOpacity(
        0.1,
      ), // selected tab background color
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ), // navigation bar padding
      tabs: [
        GButton(
          leading: Icon(Icons.home_filled),
          icon: Icons.circle, // Plug
          text: 'Home',
          textStyle: TextStyle(color: appColors.primary),
        ),
        GButton(
          leading: Icon(Icons.category_rounded),
          icon: Icons.circle, // Plug
          text: 'Categories',
          textStyle: TextStyle(color: appColors.primary),
        ),
        GButton(
          leading: Icon(Icons.bar_chart_rounded),
          icon: Icons.circle, // Plug
          text: 'Report',
          textStyle: TextStyle(color: appColors.primary),
        ),
        GButton(
          leading: Icon(Icons.settings_rounded),
          icon: Icons.circle, // Plug
          text: 'Settings',
          textStyle: TextStyle(color: appColors.primary),
        ),
      ],
    );
  }
}
