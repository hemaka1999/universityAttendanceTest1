import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profile5/screens/signIn.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _registrationNumber = '';
  String _phoneNumber = '';
  String _password = '';
  String _confirmPassword = '';
  XFile? _selectedImage; // Holds the selected image file

  void _signUp() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      // Initialize FirebaseAuth instance
      FirebaseAuth auth = FirebaseAuth.instance;

      try {
        // Create user account with Firebase Authentication
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        User? user = userCredential.user;
        if (user != null) {
          // Upload image to Firebase Storage
          if (_selectedImage != null) {
            final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(user.uid).child('user_image.jpg');
            await storageRef.putFile(File(_selectedImage!.path));
            final imageUrl = await storageRef.getDownloadURL();

            // Save user data to Firestore
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'profilePictureUrl': imageUrl,
              'firstName': _firstName,
              'lastName': _lastName,
              'email': _email,
              'registrationNumber': _registrationNumber,
              'phoneNumber': _phoneNumber,
            });

            // Sign-up and data saving successful, navigate to sign-in screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()), // Replace with your sign-in screen class
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Handle FirebaseAuthException (e.g., display error messages)
      } catch (error) {
        // Handle other errors
      }
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Profile Picture'),
              ),
              _selectedImage != null
                  ? Image.file(File(_selectedImage!.path))
                  : Container(),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onChanged: (value) => _firstName = value,
              ),
              // Other TextFormFields
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onChanged: (value) => _lastName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Registration Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your registration number';
                  }
                  return null;
                },
                onChanged: (value) => _registrationNumber = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onChanged: (value) => _phoneNumber = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onChanged: (value) => _password = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value != _password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onChanged: (value) => _confirmPassword = value,
              ),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
