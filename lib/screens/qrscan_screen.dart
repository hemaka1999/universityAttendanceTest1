import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) async {
                  final List<dynamic> decodedData =
                      jsonDecode(scanData.code.toString());
                  print(decodedData);

                  if (decodedData.length == 2) {
                    final String otp = decodedData[0].toString();
                    final int index = decodedData[1] as int;

                    final data = {
                      'otp': otp,
                    };

                    print(otp);

                    final currentUser = await tokenjwt.getCurrentUser();
                    final postResponse = await apiService.post(
                        '/attendance/verify-otp/${index}',
                        currentUser?['token'],
                        data: data);
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
