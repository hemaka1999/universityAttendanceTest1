import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:profile5/screens/QRCodeScreen.dart';
import 'package:profile5/screens/profileScreen.dart';

class AttendanceHistoryScreen extends StatelessWidget {
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const QrCodeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error fetching data');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final attendanceDocs = snapshot.data?.docs ?? [];

          if (attendanceDocs.isEmpty) {
            return const Center(child: Text('No attendance data available'));
          }

          return ListView.builder(
            itemCount: attendanceDocs.length,
            itemBuilder: (context, index) {
              final attendanceData =
              attendanceDocs[index].data() as Map<String, dynamic>;

              final subjectName = attendanceDocs[index].reference
                  .parent // attendance document
                  .parent ;// lecture document
                  // ?.parent // lectures collection
                  // .parent; // subject document reference

              print("Subject document reference: $subjectName");
              print("Subject document ID: ${subjectName?.id}");



              return ListTile(
                title: Text('Subject: $subjectName'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SubjectAttendanceScreen('subjectName'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SubjectAttendanceScreen extends StatelessWidget {
  final String subjectName;

  SubjectAttendanceScreen(this.subjectName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subject $subjectName Attendance History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .doc(subjectName)
            .collection('attendance')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error fetching data');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final attendanceDocs = snapshot.data?.docs ?? [];

          if (attendanceDocs.isEmpty) {
            return const Center(child: Text('No attendance data available'));
          }

          return ListView.builder(
            itemCount: attendanceDocs.length,
            itemBuilder: (context, index) {
              final attendanceData =
              attendanceDocs[index].data() as Map<String, dynamic>;

              final lectureId = attendanceDocs[index].reference
                  .parent // lectures
                  .parent // subjects
                  ?.id ?? '';

              final attendanceDate =
              attendanceData['timestamp'] as Timestamp?;
              final formattedDate = attendanceDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(attendanceDate.toDate())
                  : 'N/A';

              return ListTile(
                title: Text('Lecture: $lectureId'),
                subtitle: Text('Date: $formattedDate'),
                trailing: attendanceData['attended']
                    ? const Icon(Icons.check)
                    : const Icon(Icons.close),
              );
            },
          );
        },
      ),
    );
  }
}
