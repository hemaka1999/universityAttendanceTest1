import 'package:flutter/material.dart';
import 'package:profile5/screens/history_screen.dart';
import 'package:profile5/screens/profile_screen.dart';

import 'qrscan_screen.dart';
import '../apicalling/http.dart';
import '../jwtoken/jwtoken.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List data = [];
  final navItems = [
    const QrCodeScreen(),
    const ProfileScreen(),
    AttendanceHistoryScreen()
  ];
  int currentindex = 1;
  String? _course;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentindex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code),
                label: 'QR Code',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
            ],
            onTap: (index) {
              currentindex = index;
              setState(() {});
            },
          ),
          body: navItems[currentindex]),
    );
  }
}
