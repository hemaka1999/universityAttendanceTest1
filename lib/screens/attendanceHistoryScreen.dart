import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
import 'package:profile5/screens/QRCodeScreen.dart';
import 'package:profile5/screens/profileScreen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Stream<QuerySnapshot> _attendanceStream;
  final _attendanceCollection =
  FirebaseFirestore.instance.collection('attendance');

  @override
  void initState() {
    super.initState();
    // Initialize the attendance stream with documents filtered by user ID
    _attendanceStream = _attendanceCollection
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QrCodeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _attendanceStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error fetching data');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final attendanceDocs = snapshot.data?.docs ?? [];

              return Expanded(
                child: ListView.builder(
                  itemCount: attendanceDocs.length,
                  itemBuilder: (context, index) {
                    final attendanceData =
                    attendanceDocs[index].data() as Map<String, dynamic>;

                    final attendanceDate = attendanceData['timestamp'] as Timestamp?;
                    final formattedDate = attendanceDate != null
                        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(attendanceDate.toDate())
                        : 'N/A';

                    return ListTile(
                      title: Text('Lecture: ${attendanceData['lectureId']}'),
                      subtitle: Text('Date: $formattedDate'),
                      trailing: attendanceData['attended']
                          ? const Icon(Icons.check)
                          : const Icon(Icons.close),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
