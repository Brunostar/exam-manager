import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

import '../settings/settings.dart';
import 'admin_home.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  _AdminAppState createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  final Color navigationBarColor = Colors.white;
  int selectedIndex = 0;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    /// [AnnotatedRegion<SystemUiOverlayStyle>] only for android black navigation bar. 3 button navigation control (legacy)

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // backgroundColor: Colors.grey,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: <Widget>[
            AdminHomePage(),
            // Container(
            //   alignment: Alignment.center,
            //   child: Icon(
            //     Icons.favorite_rounded,
            //     size: 56,
            //     color: Colors.red[400],
            //   ),
            // ),
            Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.bluetooth_rounded,
                size: 56,
                color: Colors.green[400],
              ),
            ),
            SettingsScreen()
          ],
        ),
        bottomNavigationBar: WaterDropNavBar(
          backgroundColor: navigationBarColor,
          onItemSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
            pageController.animateToPage(selectedIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad);
          },
          selectedIndex: selectedIndex,
          barItems: <BarItem>[
            BarItem(
              filledIcon: Icons.home_rounded,
              outlinedIcon: Icons.home_outlined,
            ),
            // BarItem(
            //     filledIcon: Icons.favorite_rounded,
            //     outlinedIcon: Icons.favorite_border_rounded),
            BarItem(
              filledIcon: Icons.bluetooth_rounded,
              outlinedIcon: Icons.bluetooth_outlined,
            ),
            BarItem(
              filledIcon: Icons.person_rounded,
              outlinedIcon: Icons.person_outlined,
            ),
          ],
        ),
      ),
    );
  }
}