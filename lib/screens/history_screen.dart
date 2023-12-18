import 'package:flutter/material.dart';
import 'package:profile5/screens/home_screeen.dart';
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

  int _courseId = 0;
  List<Course> courseList = [
    Course(id: 1, name: 'RAD'),
    Course(id: 2, name: 'SE'),
    Course(id: 3, name: 'ADBMS'),
  ];

  Course? _selectedCourse;

  List<AttendanceData> attendanceDataList = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData() async {
    try {
      final currentUser = await tokenjwt.getCurrentUser();
      if (currentUser != null) {
        int userId = currentUser['id'];
        final postResponse = await apiService.get(
          '/attendance/history/$userId/$_courseId',
          currentUser['token'],
        );

        if (postResponse.statusCode == 200) {
          final responseData = postResponse.data['attendanceHistory'];
          if (responseData != null && responseData.isNotEmpty) {
            // Clear previous attendance data
            setState(() {
              attendanceDataList = [];
            });

            for (var attendance in responseData) {
              DateTime dateandtime =
                  DateTime.parse(attendance['date_time']) ?? DateTime.now();
              String hall = attendance['hall'] ?? 'No Hall';
              bool v1 = attendance['verification_one'] ?? false;
              bool v2 = attendance['verification_two'] ?? false;

              setState(() {
                attendanceDataList.add(AttendanceData(
                  lectureDateTime: dateandtime,
                  hall: hall,
                  firstVerification: v1,
                  secondVerification: v2,
                ));
              });
            }
          } else {
            // If no attendance data is found, clear the list
            setState(() {
              attendanceDataList = [];
            });
          }
        } else {
          print('Error: ${postResponse.statusCode}');
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.push(
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
            DropdownButtonFormField<Course>(
              value: _selectedCourse,
              items: courseList.map((course) {
                return DropdownMenuItem<Course>(
                  child: Text(course.name),
                  value: course,
                );
              }).toList(),
              onChanged: (Course? newValue) async {
                setState(() {
                  _selectedCourse = newValue;
                  _courseId = newValue?.id ?? 0;
                });
                // Trigger API call when the user selects a course
                await fetchData();
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Attendance Details for Course ID: $_courseId',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            if (attendanceDataList.isNotEmpty)
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
                              'First Verification: ${attendanceData.firstVerification}'),
                          Text(
                              'Second Verification: ${attendanceData.secondVerification}'),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Text('Attendance not found.'),
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

class Course {
  final int id;
  final String name;

  Course({
    required this.id,
    required this.name,
  });
}
