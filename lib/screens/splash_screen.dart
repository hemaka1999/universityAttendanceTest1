import 'dart:async';
import 'package:flutter/material.dart';
import 'package:profile5/screens/sign_in.dart';

void main(){runApp(const MaterialApp(home: SplashScreen()));}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Add any initialization code here.

    // After a delay, navigate to the main screen.
    Timer(Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const SignInScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
              child: Image.asset('assets/splash.png'), ),// Replace with your logo image path
            SizedBox(height: 20), // Add spacing between the logo and other elements if needed

          ],
        ),
      ),
    );
  }
}