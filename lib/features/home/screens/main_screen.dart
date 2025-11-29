//main_screen
import 'package:fieldsync/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/config/resources/images.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../profile/screens/profile_screen.dart';
import '../../project/screens/project_list_screen.dart';

class MainScreen extends StatefulWidget {
  static const route = '/main-screen';
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  Widget buildPageView(List<Widget> bottomBarPages) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: bottomBarPages,
    );
  }


  @override
  Widget build(BuildContext context) {
    final bottomBarPages = [
      const HomeScreen(),
      const ProjectListScreen(),
      const ProfileScreen()
    ];
    return Scaffold(
      body: buildPageView(bottomBarPages),
      bottomNavigationBar: CustomFBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class CustomFBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomFBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: AppColor.white,
      // backgroundColor: const Color(0xFFFEFCF3), // Very light cream background
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColor.black,
      // selectedItemColor: const Color(0xFF004D40), // Dark green
      unselectedItemColor: const Color(0xFF898989), // Muted gold
      selectedLabelStyle: AppFonts.lightSmall.copyWith(fontWeight: FontWeight.w600),
      // const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle:  AppFonts.lightSmall.copyWith(fontWeight: FontWeight.w600),
      // const TextStyle(fontWeight: FontWeight.w600),
      items: [
        buildNavItem(index: 0, filledIcon: Images.homeFilledIcon, outlinedIcon: Images.homeIcon, label: 'Home'),
        buildNavItem(index: 1, filledIcon: Images.projectFilledIcon, outlinedIcon: Images.projectIcon, label: 'Project'),
        buildNavItem(index: 2, filledIcon: Images.profileFilledIcon, outlinedIcon: Images.profileIcon, label: 'Account'),
      ],
    );
  }

  BottomNavigationBarItem buildNavItem({
    required int index,
    required String filledIcon,
    required String outlinedIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        selectedIndex == index ? filledIcon : outlinedIcon,
        height: 22,
        width: 22,
      ),
      label: label,
    );
  }

}