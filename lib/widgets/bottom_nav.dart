import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/data_murid_page.dart';
import '../pages/catatan_page.dart';
import '../pages/sanksi_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    DataMuridPage(),
    CatatanPage(),
    SanksiPage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Murid'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Catatan'),
          BottomNavigationBarItem(icon: Icon(Icons.rule), label: 'Sanksi'),
        ],
      ),
    );
  }
}
