import 'package:flutter/material.dart';

import '../apicalling/http.dart';
import '../jwtoken/jwtoken.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final apiService = ApiService();
  final tokenjwt = TokenJWT();

  String? _course;

  List data = [];

  // Sample data for demonstration purposes. You should replace this with actual data from your database.
  final List<AttendanceData> attendanceDataList = [
    AttendanceData(
      lectureDateTime:
          DateTime(2023, 9, 15, 10, 0), // Replace with actual date and time
      hall: 'Hall A', // Replace with actual hall name
      firstVerification: true,
      secondVerification: true,
    ),
    // Add more attendance data entries here
  ];

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
            await apiService.get('/courses', currentUser['token']);
        if (postResponse.statusCode == 200) {
          final responseData = postResponse.data['courses'];
          setState(() {
            _course = responseData['name'];
          });
          print(responseData);
        } else {
          // Handle API error
        }
      }
    } catch (e) {
      // Handle exceptions
    }
  }

  // Dropdown menu items for course selection
  List<String> courseList = ['Course A', 'Course B', 'Course C'];
  String selectedCourse = 'Course A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _course,
              items: data.map((list) {
                return DropdownMenuItem<String>(
                  child: Text(list['name']),
                  value: list['id'].toString(),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _course = newValue!;
                  // Fetch attendance data for the selected course from your database here
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Attendance Details for $selectedCourse', // Display the selected course
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceDataList.length,
                itemBuilder: (BuildContext context, int index) {
                  final attendanceData = attendanceDataList[index];
                  return ListTile(
                    title: Text(
                        'Lecture Date & Time: ${attendanceData.lectureDateTime}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lecture Hall: ${attendanceData.hall}'),
                        Text(
                            'First Verification: ${attendanceData.firstVerification ? 'True' : 'False'}'),
                        Text(
                            'Second Verification: ${attendanceData.secondVerification ? 'True' : 'False'}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceData {
  final DateTime lectureDateTime;
  final String hall;
  final bool firstVerification;
  final bool secondVerification;

  AttendanceData({
    required this.lectureDateTime,
    required this.hall,
    required this.firstVerification,
    required this.secondVerification,
  });
}
