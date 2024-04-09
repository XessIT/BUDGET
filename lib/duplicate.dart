import 'dart:developer';

import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'monthlyDahboard.dart';

class BottomNavigatorExample extends StatefulWidget {
  const BottomNavigatorExample({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomNavigatorExample> createState() => _BottomNavigatorExampleState();
}

class _BottomNavigatorExampleState extends State<BottomNavigatorExample> {
  bool circleButtonToggle = false;
  List<Color> listOfColor = [
    const Color(0xFFF2B5BA),
    Colors.orange,
    Colors.amber,
    Colors.deepOrangeAccent
  ];
  int index = 2;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              elevation: 3,
              leading: IconButton(
                icon: const Icon(Icons.navigate_before),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MonthlyDashboard(
                                uid: '',
                              )));
                },
              ),
            ),
            backgroundColor: listOfColor[index],
            floatingActionButton: const SizedBox(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: AnimatedBottomNavigationBar(
              barColor: Colors.white,
              controller: FloatingBottomBarController(initialIndex: 1),
              bottomBar: [
                BottomBarItem(
                  icon: const Icon(Icons.home, size: 10),
                  iconSelected: const Icon(Icons.home,
                      color: AppColors.cherryRed, size: 10),
                  dotColor: AppColors.cherryRed,
                  onTap: (value) {
                    setState(() {
                      index = value;
                    });
                    log('Home $value');
                  },
                ),
                BottomBarItem(
                  icon: const Icon(Icons.photo, size: 16),
                  iconSelected: const Icon(Icons.photo,
                      color: AppColors.cherryRed, size: 14),
                  dotColor: AppColors.cherryRed,
                  onTap: (value) {
                    setState(() {
                      index = value;
                    });
                    log('Search $value');
                  },
                ),
                BottomBarItem(
                  icon: const Icon(Icons.photo, size: 16),
                  iconSelected: const Icon(Icons.photo,
                      color: AppColors.cherryRed, size: 14),
                  dotColor: AppColors.cherryRed,
                  onTap: (value) {
                    setState(() {
                      index = value;
                    });
                    log('Search $value');
                  },
                ),
                BottomBarItem(
                  icon: const Icon(Icons.photo, size: 16),
                  iconSelected: const Icon(Icons.photo,
                      color: AppColors.cherryRed, size: 14),
                  dotColor: AppColors.cherryRed,
                  onTap: (value) {
                    setState(() {
                      index = value;
                    });
                    log('Search $value');
                  },
                ),
              ],
              bottomBarCenterModel: BottomBarCenterModel(
                centerBackgroundColor: AppColors.cherryRed,
                centerIcon: const FloatingCenterButton(
                  child: Icon(
                    Icons.add,
                    color: AppColors.white,
                  ),
                ),
                centerIconChild: [
                  FloatingCenterButtonChild(
                    child: const Icon(
                      Icons.home,
                      color: AppColors.white,
                    ),
                    onTap: () => log('Item1'),
                  ),
                  FloatingCenterButtonChild(
                    child: const Icon(
                      Icons.access_alarm,
                      color: AppColors.white,
                    ),
                    onTap: () => log('Item2'),
                  ),
                  FloatingCenterButtonChild(
                    child: const Icon(
                      Icons.ac_unit_outlined,
                      color: AppColors.white,
                    ),
                    onTap: () => log('Item3'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
