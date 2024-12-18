import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/pegawai/dashboard.dart';
import 'package:seam_flutter/screens/pegawai/grown/index.dart';
import 'package:seam_flutter/screens/pegawai/spend/index.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class PegawaiLayout extends StatefulWidget {
  final String currentUser;
  const PegawaiLayout({super.key, this.currentUser = 'User'});

  @override
  State<PegawaiLayout> createState() => _PegawaiLayoutState();
}

class _PegawaiLayoutState extends State<PegawaiLayout> {
  int _selectedIndex = 1;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final userToDisplay =
        widget.currentUser.isNotEmpty ? widget.currentUser : 'User';

    _screens = [
      PencatatanIndexPage(currentUser: userToDisplay),
      PegawaiDashboard(currentUser: userToDisplay),
      SpendIndexPage(
        currentUser: userToDisplay,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: ColorTheme.white,
        unselectedItemColor: ColorTheme.blackFont,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_rounded),
            label: 'Note',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_rounded),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: ColorTheme.blackFont,
        selectedIconTheme: IconThemeData(color: ColorTheme.blackFont, shadows: [
          Shadow(
              blurRadius: 2,
              color: ColorTheme.black,
              offset: Offset.fromDirection(
                  CircularProgressIndicator.strokeAlignInside))
        ]),
        onTap: _onItemTapped,
      ),
    );
  }
}
