import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traces_of_the_deep_reef/common/app_chrome.dart';
import 'package:traces_of_the_deep_reef/screens/compare_screen.dart';
import 'package:traces_of_the_deep_reef/screens/home_screen.dart';
import 'package:traces_of_the_deep_reef/screens/showcase_screen.dart';
import 'package:traces_of_the_deep_reef/screens/stats_screen.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int index;
  const MainNavigation({super.key, this.index = 0});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  static const _tabs = [
    ReefNavTab(Icons.grid_view_rounded, 'Archive'),
    ReefNavTab(Icons.compare_arrows_rounded, 'Compare'),
    ReefNavTab(Icons.layers_outlined, 'Ocean map'),
    ReefNavTab(Icons.bar_chart_rounded, 'Logbook'),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    CompareScreen(),
    ShowcaseScreen(),
    StatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom,
            child: ReefFloatingNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              tabs: _tabs,
            ),
          ),
        ],
      ),
    );
  }
}
