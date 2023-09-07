import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profile5/screens/QRCodeScreen.dart';
import 'package:profile5/screens/attendanceHistoryScreen.dart';
import 'dart:io';

import 'package:profile5/screens/signIn.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userId = '';
  String _profilePictureUrl = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _registrationNumber = '';
  String _phoneNumber = '';
  bool _isEditing = false;
  XFile? _newProfileImage;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_userId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
          setState(() {
            _firstName = docSnapshot['firstName'];
            _lastName = docSnapshot['lastName'];
            _email = docSnapshot['email'];
            _registrationNumber = docSnapshot['registrationNumber'];
            _phoneNumber = docSnapshot['phoneNumber'];
          });
        }
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(_userId)
          .child('user_image.jpg');
      storageRef.getDownloadURL().then((url) {
        setState(() {
          _profilePictureUrl = url;
        });
      }).catchError((error) {
        print("Error fetching profile picture: $error");
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(_userId);

    if (_isEditing) {
      await userRef.update({
        'firstName': _firstName,
        'lastName': _lastName,
        'phoneNumber': _phoneNumber,
      });

      if (_newProfileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(_userId)
            .child('user_image.jpg');

        final imageFile = File(_newProfileImage!.path);
        await storageRef.putFile(imageFile);

        final imageUrl = await storageRef.getDownloadURL();
        setState(() {
          _profilePictureUrl = imageUrl;
        });
      }
    }

    _toggleEditing();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _newProfileImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _isEditing ? _saveChanges : _toggleEditing,
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const QrCodeScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => AttendanceHistoryScreen()));
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(File(_newProfileImage!.path))
                          as ImageProvider<Object>?
                      : (_profilePictureUrl.isNotEmpty
                              ? NetworkImage(_profilePictureUrl)
                              : const AssetImage(
                                  'assets/default_profile_picture.png'))
                          as ImageProvider<Object>?,
                ),
              ),
              const SizedBox(height: 16),
              if (_isEditing)
                TextFormField(
                  initialValue: _firstName,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  onChanged: (value) => setState(() => _firstName = value),
                )
              else
                Text('Name: $_firstName $_lastName'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextFormField(
                  initialValue: _lastName,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  onChanged: (value) => setState(() => _lastName = value),
                ),
              const SizedBox(height: 8),
              Text('Registration Number: $_registrationNumber'),
              const SizedBox(height: 8),
              Text('Email: $_email'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextFormField(
                  initialValue: _phoneNumber,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  onChanged: (value) => setState(() => _phoneNumber = value),
                )
              else
                Text('Phone Number: $_phoneNumber'),
              const SizedBox(height: 16),
              if (_isEditing)
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              const SizedBox(height: 16),
              if (!_isEditing) // Render logout button only when not editing
                ElevatedButton(
                  onPressed: _logout, // Add this line to trigger logout
                  child: const Text('Logout'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
