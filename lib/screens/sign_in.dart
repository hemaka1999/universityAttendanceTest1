import 'package:flutter/material.dart';
import 'package:profile5/screens/home_screeen.dart';
import 'package:profile5/screens/sign_up.dart';
import 'dart:developer';
import 'package:profile5/jwtoken/jwtoken.dart';

import '../apicalling/http.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final apiService = ApiService();
  final tokenjwt = TokenJWT();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _signIn(String email, String password) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        // Example POST request
        final data = {'email': email, 'password': password};
        final postResponse =
            await apiService.post('/auth/signin', null, data: data);
        if (postResponse.statusCode == 200) {
          final responseData = postResponse.data;
          // final decodedData = jsonDecode(responseData); // Convert to a Map
          // final jsonString = jsonEncode(decodedData); // Convert Map to JSON string
          // print(jsonString); // Log the JSON string
          tokenjwt.storeCurrentUser(responseData);
          // Process the response data
        } else {
          // Handle errors
        }

        // Navigate to the profile screen after successful sign-in
        Navigator.push(
          context, // Use the context directly here
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        log(e.toString());
      } catch (error) {
        // Handle generic error
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/splash.png'),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 25.0),
              TextFormField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail),
                    hintText: "Email",
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_rounded),
                    hintText: "Password",
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _signIn(_email.trim(), _password);
                },
                child: const Text('Sign In'),
              ),
              TextButton(
                onPressed: _navigateToSignUp,
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
