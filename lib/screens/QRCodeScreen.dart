import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profile5/screens/profileScreen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profile5/screens/attendanceHistoryScreen.dart';

import '../apicalling/http.dart';
import '../jwtoken/jwtoken.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({Key? key}) : super(key: key);

  @override
  _QrCodeScreenState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final apiService = ApiService();
  final tokenjwt = TokenJWT();
  late QRViewController controller;
  late String userId;
  bool attendanceMarked = false; // Flag to track attendance marking

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }
  //
  // void _markAttendance(String userId, String subjectId, String lectureId) {
  //   if (attendanceMarked) return;
  //
  //   CollectionReference attendanceCollection =
  //   FirebaseFirestore.instance
  //       .collection('subjects')
  //       .doc(subjectId)
  //       .collection('lectures')
  //       .doc(lectureId)
  //       .collection('attendance');
  //
  //   String documentId = userId;
  //
  //   attendanceCollection.doc(documentId).get().then((DocumentSnapshot snapshot) {
  //     if (!snapshot.exists) {
  //       attendanceCollection.doc(documentId).set({
  //         'attended': true,
  //         'timestamp': FieldValue.serverTimestamp(),
  //       }).then((value) {
  //         print('Attendance marked successfully');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Attendance marked successfully')),
  //         );
  //         setState(() {
  //           attendanceMarked = true;
  //         });
  //         controller.toggleFlash();
  //         controller.pauseCamera();
  //       }).catchError((error) {
  //         print('Error marking attendance: $error');
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Attendance already marked')),
  //       );
  //       setState(() {
  //         attendanceMarked = true;
  //       });
  //       controller.toggleFlash();
  //       controller.pauseCamera();
  //     }
  //   }).catchError((error) {
  //     print('Error checking attendance: $error');
  //   });
  // }

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
                  builder: (context) => AttendanceHistoryScreen(),
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
                    builder: (_) => AttendanceHistoryScreen()));
          }
        },
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller)  {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) async {
                  final List<dynamic> decodedData = jsonDecode(scanData.code.toString());

    if (decodedData.length == 2) {
      final String otp = decodedData[0].toString();
      final int index = decodedData[1] as int;

      final data = {
        'otp': otp,
      };

      final currentUser = await tokenjwt.getCurrentUser();
      final postResponse = await apiService.post(
          '/attendance/verify-otp/${index}',
          currentUser?['token'], data: data);
      controller.toggleFlash();
      controller.pauseCamera();
      // if (qrData.length == 2) {
      //   String subjectId = qrData[0];
      //   String lectureId = qrData[1];
      //   _markAttendance(userId, subjectId, lectureId);
      // }
    }
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


