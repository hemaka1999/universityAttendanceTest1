import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:profile5/screens/sign_in.dart';

import '../apicalling/http.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Define a list of options for the dropdown
  List<String> departments = [
    'Computing & Information Systems',
    'Data Science',
    'Software Engineering'
  ];
  String? selectedDepartment; // Store the selected department
  final _formKey = GlobalKey<FormState>();
  final apiService = ApiService();
  String _name = '';
  String _email = '';
  String _department = '';
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
        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref();
        final userImageRef = storageRef.child('user_images/$_email.jpg');

        if (_selectedImage != null) {
          await userImageRef.putFile(File(_selectedImage!.path));
        }

        final imageUrl = await userImageRef.getDownloadURL();
        print(imageUrl);

        // full_name, email, password, department, reg_no

        // Example POST request
        final data = {
          'full_name': _name,
          'email': _email,
          'password': _password,
          'department': _department,
          'reg_no': _registrationNumber,
          'avatar': imageUrl,
        };
        final postResponse =
            await apiService.post('/auth/signup', null, data: data);
        if (postResponse.statusCode == 201) {
          final responseData = postResponse.data;
          // Process the response data
        } else {
          // Handle errors
        }

        // Create user account with Firebase Authentication
        // UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        //   email: _email,
        //   password: _password,
        // );
        //
        // User? user = userCredential.user;
        // if (user != null) {
        // Upload image to Firebase Storage
        // if (_selectedImage != null) {
        //   final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(user.uid).child('user_image.jpg');
        //   await storageRef.putFile(File(_selectedImage!.path));
        //   final imageUrl = await storageRef.getDownloadURL();

        // Save user data to Firestore
        // await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        //   'profilePictureUrl': imageUrl,
        //   'firstName': _firstName,
        //   'lastName': _lastName,
        //   'department': _department,
        //   'email': _email,
        //   'registrationNumber': _registrationNumber,
        //   'phoneNumber': _phoneNumber,
        // });

        // Sign-up and data saving successful, navigate to sign-in screen

        // }
        //}
        // } on FirebaseAuthException catch (e) {
        // Handle FirebaseAuthException (e.g., display error messages)
      } catch (error) {
        // Handle other errors
      }
    }
  }

  void _navigateToSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
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
      appBar: AppBar(
          title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
        ),
      ),
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

              const SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: "Name",
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onChanged: (value) => _name = value,
              ),
              // Other TextFormFields
              // TextFormField(
              //   decoration: const InputDecoration(labelText: 'Last Name'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your last name';
              //     }
              //     return null;
              //   },
              //   onChanged: (value) => _lastName = value,
              // ),
              const SizedBox(
                height: 16,
              ),
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
                onChanged: (value) => _email = value,
              ),
              const SizedBox(
                height: 16,
              ),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 10,
                style: const TextStyle(color: Colors.deepPurple),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDepartment = newValue;
                    _department =
                        newValue ?? ''; // Update the _department variable
                  });
                },
                items:
                    departments.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: 'Department',
                    prefixIcon: const Icon(Icons.cabin_outlined),
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 0, 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(
                height: 16,
              ),

              TextFormField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.numbers_outlined),
                    hintText: "Registration Number",
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your registration number';
                  }
                  return null;
                },
                onChanged: (value) => _registrationNumber = value,
              ),
              // TextFormField(
              //   decoration: const InputDecoration(labelText: 'Phone Number'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your phone number';
              //     }
              //     return null;
              //   },
              //   onChanged: (value) => _phoneNumber = value,
              // ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_rounded),
                    hintText: "Password",
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
                onChanged: (value) => _password = value,
              ),

              const SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_rounded),
                    hintText: "Confirm Password",
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value != _password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onChanged: (value) => _confirmPassword = value,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: _navigateToSignIn,
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
