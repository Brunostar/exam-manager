import 'package:flutter/material.dart';

import '../authentication/add_course.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Initialize a list of courses for the selected department
  // List<Course> _courses = List<Course>.empty(growable: true);

  final List<Course> _courses = [
    Course(department: 'Department A', code: 'A101', title: 'Course A1', classLevel: 100, date: DateTime(2023, 5, 20), startTime: TimeOfDay(hour: 10, minute: 0), endTime: TimeOfDay(hour: 12, minute: 0)),
    Course(department: 'Department A', code: 'A102', title: 'Course A2', classLevel: 200, date: DateTime(2023, 5, 21), startTime: TimeOfDay(hour: 14, minute: 0), endTime: TimeOfDay(hour: 16, minute: 0)),
    Course(department: 'Department A', code: 'A103', title: 'Course A3', classLevel: 300, date: DateTime(2023, 5, 22), startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 11, minute: 0)),
    Course(department: 'Department B', code: 'B101', title: 'Course B1', classLevel: 100, date: DateTime(2023, 5, 23), startTime: TimeOfDay(hour: 11, minute: 0), endTime: TimeOfDay(hour: 13, minute: 0)),
    Course(department: 'Department B', code: 'B102', title: 'Course B2', classLevel: 200, date: DateTime(2023, 5, 24), startTime: TimeOfDay(hour: 13, minute: 30), endTime: TimeOfDay(hour: 15, minute: 30)),
    Course(department: 'Department B', code: 'B103', title: 'Course B3', classLevel: 300, date: DateTime(2023, 5, 25), startTime: TimeOfDay(hour: 9, minute: 0), endTime: TimeOfDay(hour: 11, minute: 0)),
    Course(department: 'Department C', code: 'C101', title: 'Course C1', classLevel: 100, date: DateTime(2023, 5, 26), startTime: TimeOfDay(hour: 10, minute: 30), endTime: TimeOfDay(hour: 12, minute: 30)),
  ];

  // Initialize the currently selected department
  String _selectedDepartment = 'Department A';

  @override
  Widget build(BuildContext context) {
    // Filter the list of courses to only include courses for the selected department
    List<Course> departmentCourses = _courses.where((course) => course.department == _selectedDepartment).toList();

    // Sort the list of courses by class level
    departmentCourses.sort((a, b) => a.classLevel.compareTo(b.classLevel));

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Admin Home'),
      //   actions: [
      //     // Upload button
      //     // IconButton(
      //     //   icon: Icon(Icons.upload_file),
      //     //   onPressed: () {
      //     //     // _uploadCourses();
      //     //   },
      //     // ),
      //   ],
      // ),
      body: Column(
        children: [
          // Department selection dropdown
          DropdownButton<String>(
            value: _selectedDepartment,
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value!;
              });
            },
            items: const [
              DropdownMenuItem(
                value: 'Department A',
                child: Text('Department A'),
              ),
              DropdownMenuItem(
                value: 'Department B',
                child: Text('Department B'),
              ),
              DropdownMenuItem(
                value: 'Department C',
                child: Text('Department C'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: departmentCourses.length,
              itemBuilder: (BuildContext context, int index) {
                Course course = departmentCourses[index];

                // Check if this is the first course in a new class level
                bool isNewLevel = false;
                if (index == 0 || course.classLevel != departmentCourses[index - 1].classLevel) {
                  isNewLevel = true;
                }

                return Column(
                  children: [
                    // Class level title
                    if (isNewLevel)
                      ListTile(
                        title: Text('Level ${course.classLevel}'),
                        onTap: () {
                          setState(() {
                            // Toggle the visibility of courses in this level
                            course.isVisible = !course.isVisible;
                          });
                        },
                      ),

                    // Course tile
                    if (course.isVisible) // Check if the course should be visible
                      ListTile(
                        title: Text(course.title),
                        subtitle: Text('${course.code} - ${course.date} ${course.startTime}-${course.endTime}'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // TODO: Add code to edit the course
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 48,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddCoursePage()),
              );
            },
            child: const Text(
              'Add Department',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) =>
      //           AddCoursePage()),
      //     );
      //   },
      // ),
    );
  }
}

class Course {
  String department;
  String title;
  String code;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  int classLevel;
  bool isVisible;

  Course({
    required this.department,
    required this.title,
    required this.code,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.classLevel,
    this.isVisible = true,
  });
}