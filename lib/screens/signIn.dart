import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profile5/screens/profileScreen.dart';
import 'package:profile5/screens/signUp.dart';
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
        // await FirebaseAuth.instance.signInWithEmailAndPassword(
        //   email: email,
        //   password: password,
        //   );

        // Example POST request
        final data = {'email': email, 'password': password};
        final postResponse = await apiService.post('/auth/signin',null, data: data);
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
        Navigator.pushReplacement(
          context, // Use the context directly here
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );

        // Successful sign-in, navigate to the next screen
        // For example:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }  catch (e) {
        log(e.toString());
      } catch (error) {
        // Handle generic error
      }
    }
  }


  void _navigateToSignUp() {
    Navigator.push(
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
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
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
