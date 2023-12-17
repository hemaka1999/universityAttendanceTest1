import 'package:flutter/material.dart';
import 'package:profile5/screens/home_screeen.dart';
import 'package:profile5/screens/profile_screen.dart';
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

  String _userId = '';
  String _course = '';

  List data = [];

  final List<AttendanceData> attendanceDataList = [
    AttendanceData(
      lectureDateTime:
      DateTime(2023, 9, 15, 10, 0), // Replace with actual date and time
      hall: 'Hall A', // Replace with actual hall name
      firstVerification: true,
      secondVerification: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
    //print(_course);
  }

  Future<void> fetchData() async {
    try {
      final currentUser = await tokenjwt.getCurrentUser();
      print(currentUser);
      if (currentUser != null) {
        final postResponse = await apiService.get(
          '/attendance/history/$_userId/$_course',
          currentUser['token'],
        );
        print(_course);

        if (postResponse.statusCode == 200) {
          final responseData = postResponse.data['attendance'];
          setState(() {
            data =
                responseData; // Assuming 'attendanceHistory' is the correct key
          });
        } else {
          print(_course);
          // Handle API error
        }
      }
    } catch (e) {
      print(e.toString());
      // Handle exceptions
    }
  }

  List<String> courseList = ['Course A', 'Course B', 'Course C'];
  String selectedCourse = 'Course A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
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
