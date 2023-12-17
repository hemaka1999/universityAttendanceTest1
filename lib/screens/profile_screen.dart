import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profile5/screens/sign_in.dart';

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

  void _logout() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
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

      final postResponse = await apiService
          .put('/user/profile', currentUser?['token'], data: data);

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
      body: Container(
        margin: EdgeInsets.only(top: 20, bottom: 20),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePictureURL != null
                      ? NetworkImage(profilePictureURL!)
                  as ImageProvider<Object>?
                      : AssetImage('assets/placeholder.png')
                  as ImageProvider<Object>?,
                ),
                const SizedBox(height: 20),
                if (_isEditing)
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) => setState(() => _name = value),
                  )
                else
                  Text(
                    'Name: $_name',
                    style: TextStyle(fontSize: 18),
                  ),
                const SizedBox(height: 15),
                if (_isEditing)
                  TextFormField(
                    initialValue: _registrationNumber,
                    decoration:
                    const InputDecoration(labelText: 'Registration Number'),
                    onChanged: (value) =>
                        setState(() => _registrationNumber = value),
                  )
                else
                  Text(
                    'Registration Number: $_registrationNumber',
                    style: TextStyle(fontSize: 18),
                  ),
                const SizedBox(height: 15),
                if (_isEditing)
                  TextFormField(
                    initialValue: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (value) => setState(() => _email = value),
                  )
                else
                  Text(
                    'Email: $_email',
                    style: TextStyle(fontSize: 18),
                  ),
                const SizedBox(height: 15),
                if (_isEditing)
                  TextFormField(
                    initialValue: _department,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                    ),
                    onChanged: (value) => setState(() => _department = value),
                  )
                else
                  Text(
                    'Department: $_department',
                    style: TextStyle(fontSize: 17),
                  ),
                const SizedBox(height: 25),
                if (_isEditing)
                  Material(
                    elevation: 5,
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                    child: MaterialButton(
                      child: Text(
                        'Save',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      onPressed: () {
                        _saveChanges();
                      },
                    ),
                  ),
                const SizedBox(height: 25),
                if (!_isEditing)
                  Material(
                    elevation: 5,
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                    child: MaterialButton(
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      onPressed: () {
                        _logout();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
