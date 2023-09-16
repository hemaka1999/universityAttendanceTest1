import 'package:flutter/material.dart';
import 'package:profile5/screens/QRCodeScreen.dart';
import 'package:profile5/screens/attendanceHistoryScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profile5/screens/signIn.dart';

import '../apicalling/http.dart';
import '../jwtoken/jwtoken.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final apiService = ApiService();
  final tokenjwt = TokenJWT();
  String _userId = '';
  String _name = '';
  String _email = '';
  String _department = '';
  String _registrationNumber = '';
  bool _isEditing = false;
  String? profilePictureURL;
  XFile? _newProfileImage;

  void _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final currentUser = await tokenjwt.getCurrentUser();
      if (currentUser != null) {
        final postResponse =
        await apiService.get('/user/profile', currentUser['token']);
        if (postResponse.statusCode == 200) {
          final responseData = postResponse.data['user'];
          setState(() {
            _name = responseData['full_name'];
            _email = responseData['email'];
            _department = responseData['department'];
            _registrationNumber = responseData['reg_no'];
            profilePictureURL = responseData['avatar'];
          });
        } else {
          // Handle API error
        }
      }
    } catch (e) {
      // Handle exceptions
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    if (_isEditing) {
      final currentUser = await tokenjwt.getCurrentUser();
      final data = {
        'full_name': _name,
        'email': _email,
        'department': _department,
        'reg_no': _registrationNumber,
        'avatar': profilePictureURL,
      };

      final postResponse =
      await apiService.put('/user/profile', currentUser?['token'], data: data);

      if (postResponse.statusCode == 200) {
        final responseData = postResponse.data['user'];
        _name = responseData['full_name'];
        _email = responseData['email'];
        _department = responseData['department'];
        _registrationNumber = responseData['reg_no'];
        _toggleEditing();
      } else {
        // Handle API error
      }
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
                context, MaterialPageRoute(builder: (_) => AttendanceHistoryScreen()));
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 50,
                backgroundImage: profilePictureURL != null
                    ? NetworkImage(profilePictureURL!) as ImageProvider<Object>?
                    : AssetImage('assets/placeholder.png') as ImageProvider<Object>?,
              ),

              const SizedBox(height: 16),
              if (_isEditing)
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) => setState(() => _name = value),
                )
              else
                Text('Name: $_name'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextFormField(
                  initialValue: _registrationNumber,
                  decoration: const InputDecoration(labelText: 'Registration Number'),
                  onChanged: (value) => setState(() => _registrationNumber = value),
                )
              else
                Text('Registration Number: $_registrationNumber'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) => setState(() => _email = value),
                )
              else
                Text('Email: $_email'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextFormField(
                  initialValue: _department,
                  decoration: const InputDecoration(labelText: 'Department'),
                  onChanged: (value) => setState(() => _department = value),
                )
              else
                Text('Department: $_department'),
              const SizedBox(height: 16),
              if (_isEditing)
                ElevatedButton(
                  onPressed: () {
                    _saveChanges();
                  },
                  child: const Text('Save Changes'),
                ),
              const SizedBox(height: 16),
              if (!_isEditing)
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
