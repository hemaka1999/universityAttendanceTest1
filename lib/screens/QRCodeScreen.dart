import 'package:flutter/material.dart';
import 'package:profile5/screens/profileScreen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profile5/screens/attendanceHistoryScreen.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({Key? key}) : super(key: key);

  @override
  _QrCodeScreenState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  late String userId;
  bool attendanceMarked = false; // Flag to track attendance marking

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _markAttendance(String userId, String lectureId) {
    if (attendanceMarked) return; // Check if attendance is already marked

    CollectionReference attendanceCollection =
    FirebaseFirestore.instance.collection('attendance');

    // Create a unique document ID for the attendance using userId and lectureId
    String documentId = '$userId-$lectureId';

    // Check if the attendance has already been marked
    attendanceCollection.doc(documentId).get().then((DocumentSnapshot snapshot) {
      if (!snapshot.exists) {
        // If no attendance entry exists, mark attendance
        attendanceCollection.doc(documentId).set({
          'userId': userId,
          'attended': true,
          'lectureId': lectureId,
          'timestamp': FieldValue.serverTimestamp(),
        }).then((value) {
          print('Attendance marked successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance marked successfully')),
          );
          attendanceMarked = true; // Mark attendance as already marked
          controller.toggleFlash();
          controller.pauseCamera();
        }).catchError((error) {
          print('Error marking attendance: $error');
        });
      } else {
        // Attendance already marked
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance already marked')),
        );
        attendanceMarked = true; // Mark attendance as already marked
        controller.toggleFlash();
        controller.pauseCamera();
      }
    }).catchError((error) {
      print('Error checking attendance: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AttendanceHistoryScreen()));
          }
        },
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  // Call the function to store attendance data
                  _markAttendance(userId, scanData.code!);
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  controller.toggleFlash();
                },
                child: const Text('Toggle Flash'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
